import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/input_type.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/login_sheet.dart';
import '../widgets/menu_drawer.dart';
import '../services/chat_api_service.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  final List<ChatMessage> _messages = [];
  bool _isComposing = false;
  bool _isTyping = false; // AI typing indicator state
  final AudioPlayer _voicePlayer = AudioPlayer();
  InputType _input_type = InputType.text;
  bool _isLoggedIn = false;
  StreamSubscription<User?>? _authStateSubscription;

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _voicePlayer.dispose();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _isLoggedIn = FirebaseAuth.instance.currentUser != null;
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _isLoggedIn = user != null;
        });
      }
    });
  }

  void _startListening() async {
    if (!_speechEnabled) {
      await _voicePlayer.stop();

      _speechEnabled = await _speechToText.initialize();
      if (!_speechEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Speech recognition is not available or disabled via permissions",
              ),
            ),
          );
        }
        return;
      }
    }

    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _textController.text = result.recognizedWords;
      // Move cursor to end
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
      _isComposing = _textController.text.isNotEmpty;
    });
  }

  // Send message to backend
  void _handleSubmitted(String text) async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
      setState(() {});
    }
    _textController.clear();

    int aiMessageIndex = -1;
    // Show user message
    setState(() {
      _isTyping = true;
      _isComposing = false;
      _messages.add(ChatMessage(text: text, isUser: true));
      _messages.add(ChatMessage(text: "", isUser: false)); // placeholder AI message
      aiMessageIndex = _messages.length - 1;
    });
    _scrollToBottom();

    // Retrieve AI response
    try {
      final response = await ChatApiService.sendMessage(text, _input_type);

      String completeStreamedText = "";
      String displayResponseText = "";
      String language = "en";
      int lastQueuedLength = 0;
      final List<AudioSource> playlist = [];

      if (_input_type == InputType.speech) {
        // Initialize with empty playlist
        await _voicePlayer.setAudioSources(playlist);
      }

      response.stream.transform(utf8.decoder).transform(const LineSplitter()).listen((line) async {
        if (line.trim().isEmpty) return;

        try {
          final data = jsonDecode(line);

          // TEXT STREAM
          if (data["token"] != null) {
            completeStreamedText += data["token"];

            // Extract value of "response" from completeStreamedText
            final match = RegExp(r'"response"\s*:\s*"((?:\\.|[^"\\])*)').firstMatch(completeStreamedText);
            if (match != null) {
              String rawValue = match.group(1) ?? "";
              displayResponseText = rawValue.replaceAll(r'\"', '"').replaceAll(r'\\', '\\').replaceAll(r'\n', '\n');
            }

            if (displayResponseText.isNotEmpty && mounted) {
              if (_input_type == InputType.text) {
                // Create new message
                setState(() {
                  _isTyping = false;
                  _messages[aiMessageIndex] = _messages[aiMessageIndex].copyWith(
                    text: displayResponseText,
                  );
                });
                _scrollToBottom();
              }
            }
          }

          // SENTENCE FOR VOICE QUEUE
          if (_input_type == InputType.speech) {
            language = data["language"] ?? "en";
            String unprocessed = displayResponseText.substring(lastQueuedLength);
            
            // Look for sentences ending with . ! ? followed by whitespace or newline
            final Iterable<Match> matches = RegExp(r'([^.!?]+[.!?]+)(?=\s|\n)').allMatches(unprocessed);
            
            int localLast = 0;
            for (Match m in matches) {
              String sentence = m.group(1)!.trim();
              if (sentence.isNotEmpty) {
                ChatApiService.getSentence(sentence, language).then((uri) async {
                  playlist.add(AudioSource.uri(uri));
                  await _voicePlayer.setAudioSources(playlist);
                  if (!_voicePlayer.playing) {
                    _voicePlayer.play();
                  }
                });
              }
              localLast = m.end;
            }
            lastQueuedLength += localLast;
          }

              // FINAL MESSAGE
          if (data["done"] == true) {
            language = data["language"] ?? "en";
            
            // Queue any remaining text that didn't end in punctuation
            if (_input_type == InputType.speech) {
              String remainder = displayResponseText.substring(lastQueuedLength).trim();
              if (remainder.isNotEmpty) {
                ChatApiService.getSentence(remainder, language).then((uri) async {
                  playlist.add(AudioSource.uri(uri));
                  await _voicePlayer.setAudioSources(playlist);
                  if (!_voicePlayer.playing) {
                    _voicePlayer.play();
                  }
                });
              }
            }

            void showFinalText() {
              if (mounted && aiMessageIndex < _messages.length) {
                setState(() {
                  _isTyping = false;
                  _messages[aiMessageIndex] = _messages[aiMessageIndex].copyWith(
                    text: displayResponseText,
                    hasActionButtons: data["hasActionButtons"] == true,
                    learningConcepts: List<String>.from(data["learningConcepts"] ?? []),
                    language: language,
                  );
                });
                _scrollToBottom();
              }
            }

            if (_input_type == InputType.speech) {
              // Wait for playlist to finish playing properly
              if (_voicePlayer.sequence.isEmpty) {
                 showFinalText();
              } else {
                 _voicePlayer.playerStateStream.firstWhere(
                  (state) => state.processingState == ProcessingState.completed || state.processingState == ProcessingState.idle
                 ).then((_) {
                   // Adding a tiny delay guarantees JustAudio has cleaned up the stream end gracefully
                   Future.delayed(const Duration(milliseconds: 300), showFinalText);
                 });
              }
            } else {
              showFinalText();
            }
          }
        } catch (e) {
          print("Stream decode error: $e");
        }
      }, onError: (e) {
        if (mounted) {
          setState(() {
            _isTyping = false;
            _messages.last = _messages.last.copyWith(text: "Stream Connection Error: $e");
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.last = _messages.last.copyWith(text: "API Request Error: $e");
        });
      }
    }
  }

  void _showLoginSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LoginSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.transparent
            : const Color.fromARGB(0, 255, 251, 251),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'LINGUAMATE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isLoggedIn)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton(
                onPressed: _showLoginSheet,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Log In'),
              ),
            ),
        ],
      ),
      drawer: MenuDrawer(isLoggedIn: _isLoggedIn),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Start Practicing!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : const Color.fromARGB(255, 87, 87, 87),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 300,
                          child: Text(
                            "Type a sentence and I'll help you correct your grammar.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white60
                                  : const Color.fromARGB(255, 87, 87, 87),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      
                      // Show typing indicator instead of the empty placeholder
                      if (_isTyping && !message.isUser && message.text.isEmpty && index == _messages.length - 1) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Text(
                            _input_type == InputType.speech ? "Linguamate is speaking..." : "Linguamate is typing...",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      }

                      // For standard list view (not reversed), index 0 is top.
                      // I will use a simple mapping.
                      return ChatBubble(message: message);
                    },
                  ),
          ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  // Input field / Text composer
  Widget _buildTextComposer() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 26.0),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _textController,
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.isNotEmpty;
                  });
                },
                decoration: const InputDecoration.collapsed(
                  hintText: "Ask Linguamate...",
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(
                  _isComposing
                      ? Icons.send
                      : (_speechToText.isListening
                            ? Icons.mic
                            : Icons.mic_none),
                  color: _isComposing
                      ? (isDarkMode ? Colors.white : Colors.black)
                      : (_speechToText.isListening ? Colors.red : Colors.grey),
                ),
                onPressed: _isComposing
                    ? () => _handleSubmitted(_textController.text)
                    : () {
                        _input_type = InputType.speech;
                        if (_speechToText.isListening) {
                          _stopListening();
                        } else {
                          _startListening();
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

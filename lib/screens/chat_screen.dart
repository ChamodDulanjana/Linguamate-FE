import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/login_sheet.dart';
import '../widgets/menu_drawer.dart';
import '../services/chat_api_service.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

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

  @override
  void dispose() {
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
  }

  void _startListening() async {
    if (!_speechEnabled) {
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

  // Send message
  void _handleSubmitted(String text) async {
    print("Sending message to backend: $text");

    if (_speechToText.isListening) {
      await _speechToText.stop();
      setState(() {});
    }

    _textController.clear();

    setState(() {
      _isComposing = false;
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    // Retrieve AI response
    try {
      final data = await ChatApiService.sendMessage(text);

      setState(() {
        _messages.add(
          ChatMessage(
            text: data["response"],
            isUser: false,
            hasActionButtons: data["hasActionButtons"],
            learningConcepts: data["learningConcepts"],
            language: data["language"],
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Sorry 😔 I couldn't respond right now.",
            isUser: false,
          ),
        );
      });
    } finally {
      setState(() => _isTyping = false);
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
      drawer: MenuDrawer(),
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
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Adjust index for typing indicator if present
                      if (_isTyping && index == _messages.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Linguamate is typing...",
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      }

                      // For standard list view (not reversed), index 0 is top.
                      // I will use a simple mapping.
                      return ChatBubble(message: _messages[index]);
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

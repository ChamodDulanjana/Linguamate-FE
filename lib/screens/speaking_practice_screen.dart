import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'dart:ui';
import '../models/speaking_practice.dart';
import '../services/activity_api_service.dart';
import '../widgets/loading_widget.dart';

class SpeakingPracticeScreen extends StatefulWidget {
  final List<String> learningConcepts;
  final String language;

  const SpeakingPracticeScreen({
    super.key,
    required this.learningConcepts,
    required this.language,
  });

  @override
  State<SpeakingPracticeScreen> createState() => _SpeakingPracticeScreenState();
}

class _SpeakingPracticeScreenState extends State<SpeakingPracticeScreen>
    with SingleTickerProviderStateMixin {
  int _currentSentenceIndex = 0;
  int _score = 0;
  bool _isListening = false;
  bool _showFeedback = false;
  bool _isCorrect = false;
  List<dynamic> _heatmap = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  List<SpeakingPractice> _sentences = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isEvaluating = false;
  String _feedbackText = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadActivities();
  }

  //load activities from server
  Future<void> _loadActivities() async {
    try {
      final response = await ActivityApiService.generateActivity(
        widget.learningConcepts,
        'SPEAKING_PRACTICE',
        widget.language,
      );

      final List<dynamic> practicesData = response['sentences'] ?? [];

      setState(() {
        _sentences = practicesData
            .map((json) => SpeakingPractice.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  final _audioRecorder = AudioRecorder();
  String? _audioPath;

  @override
  void dispose() {
    _audioRecorder.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        setState(() {
          _isListening = true;
          _showFeedback = false;
        });

        // Start recording
        final directory = await getApplicationDocumentsDirectory();
        _audioPath =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            sampleRate: 44100,
            bitRate: 128000,
          ),
          path: _audioPath!,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error starting recording: $e')));
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _stopListening() async {
    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isListening = false;
        _isEvaluating = true;
      });

      if (path != null) {
        await _evaluateSpeaking(path);
      } else {
        setState(() {
          _isEvaluating = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error stopping recording: $e')));
      setState(() {
        _isListening = false;
        _isEvaluating = false;
      });
    }
  }

  Future<void> _evaluateSpeaking(String filePath) async {
    try {
      final sentence = _sentences[_currentSentenceIndex];
      final response = await ActivityApiService.evaluateSpeaking(
        filePath,
        sentence.sentence,
        widget.language,
      );

      final bool isCorrect = response['isCorrect'] ?? false;
      final List<dynamic> heatmap = response['heatmap'] ?? [];
      final String feedbackText = response['feedback'] ?? '';

      setState(() {
        _isCorrect = isCorrect;
        _showFeedback = true;
        _isEvaluating = false;
        _heatmap = heatmap;
        _feedbackText = feedbackText;
        if (_isCorrect) _score++;
      });
    } catch (e) {
      setState(() {
        _isEvaluating = false;
        _errorMessage = "Fail to evaluate audio: $e";
      });
    }
  }

  void _nextSentence() {
    if (_currentSentenceIndex < _sentences.length - 1) {
      setState(() {
        _currentSentenceIndex++;
        _showFeedback = false;
        _isCorrect = false;
        _heatmap = [];
        _feedbackText = '';
      });
    } else {
      _showScoreDialog();
    }
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mic, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              Text(
                "Great Speaking!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You pronounced",
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$_score / ${_sentences.length}",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "sentences correctly",
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to activities
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Done", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //loading screen
    if (_isLoading) {
      return Scaffold(
        body: const LoadingWidget(type: LoadingType.speaking),
      );
    }

    if (_errorMessage.isNotEmpty || _sentences.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Speaking Practice")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage.isNotEmpty
                      ? "Oops! Something went wrong:\n$_errorMessage"
                      : "No speaking practice sentences found.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = '';
                    });
                    _loadActivities();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final sentence = _sentences[_currentSentenceIndex];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Speaking Practice"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (_currentSentenceIndex + 1) / _sentences.length,
            backgroundColor: isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Read aloud:",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey.shade900
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _showFeedback ?
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: _heatmap.map((item) {

                            Color color;

                            switch(item["status"]) {
                              case "correct":
                                color = Colors.green;
                                break;
                              case "incorrect":
                                color = Colors.red;
                                break;
                              case "missing":
                                color = Colors.orange;
                                break;
                              default:
                                color = Colors.grey;
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                "${item["word"]} ",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            );

                          }).toList(),
                        )
                      : Text(
                          sentence.sentence,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                if (_showFeedback) ...[
                  Icon(
                    _isCorrect ? Icons.check_circle : Icons.error,
                    color: _isCorrect ? Colors.green : Colors.orange,
                    size: 60,
                  ),
                  const SizedBox(height: 16),

                  //feedback text
                  Text(
                    _feedbackText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _isCorrect ? Colors.green : Colors.orange,
                    ),
                  ),
                ] else if (_isListening) ...[
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                  child: const Icon(Icons.mic, color: Colors.green, size: 40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Listening...",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                ] else ...[
                  const Icon(Icons.mic_none, color: Colors.grey, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                "Tap microphone to speak",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  height: 60,
                  child: _showFeedback
                      ? ElevatedButton(
                          onPressed: _nextSentence,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            _currentSentenceIndex < _sentences.length - 1
                                ? "Next Sentence"
                                : "Finish",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : GestureDetector(
                      onTap: _isListening ? _stopListening : _startListening,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isListening
                                  ? Colors.grey.shade300
                                  : Colors.green,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isListening ? Icons.stop : Icons.mic,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // loading widget for evaluating
          if (_isEvaluating)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.5)
                      : Colors.white.withOpacity(0.5),
                  child: const SafeArea(
                    child: Center(
                      child: LoadingWidget(type: LoadingType.general),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

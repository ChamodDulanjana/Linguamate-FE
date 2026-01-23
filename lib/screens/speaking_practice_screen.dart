import 'package:flutter/material.dart';

class SpeakingPracticeScreen extends StatefulWidget {
  const SpeakingPracticeScreen({super.key});

  @override
  State<SpeakingPracticeScreen> createState() => _SpeakingPracticeScreenState();
}

class SpeakingSentence {
  final String sentence;
  final String phonetic;

  SpeakingSentence({required this.sentence, required this.phonetic});
}

class _SpeakingPracticeScreenState extends State<SpeakingPracticeScreen>
    with SingleTickerProviderStateMixin {
  int _currentSentenceIndex = 0;
  int _score = 0;
  bool _isListening = false;
  bool _showFeedback = false;
  bool _isCorrect = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<SpeakingSentence> _sentences = [
    SpeakingSentence(
      sentence: "The quick brown fox jumps over the lazy dog.",
      phonetic: "/ðə kwɪk braʊn fɒks dʒʌmps ˈəʊvə ðə ˈleɪzi dɒg/",
    ),
    SpeakingSentence(
      sentence: "I would like a cup of coffee.",
      phonetic: "/aɪ wʊd laɪk ə kʌp ɒv ˈkɒfi/",
    ),
    SpeakingSentence(
      sentence: "Where is the nearest train station?",
      phonetic: "/weər ɪz ðə ˈnɪərɪst treɪn ˈsteɪʃən/",
    ),
    SpeakingSentence(
      sentence: "It makes no difference to me.",
      phonetic: "/ɪt meɪks nəʊ ˈdɪfrəns tuː miː/",
    ),
    SpeakingSentence(
      sentence: "Better late than never.",
      phonetic: "/ˈbɛtə leɪt ðæn ˈnɛvə/",
    ),
  ];

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _showFeedback = false;
    });

    // Simulate listening duration
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _stopListening();
      }
    });
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
      _showFeedback = true;
      // Mock validation: 80% chance of success for demo
      _isCorrect = true; // For demo purposes, always Correct
      if (_isCorrect) _score++;
    });
  }

  void _nextSentence() {
    if (_currentSentenceIndex < _sentences.length - 1) {
      setState(() {
        _currentSentenceIndex++;
        _showFeedback = false;
        _isCorrect = false;
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
      body: Padding(
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
                color: isDarkMode ? Colors.grey.shade900 : Colors.green.shade50,
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
                  Text(
                    sentence.sentence,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    sentence.phonetic,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (_showFeedback) ...[
              Icon(
                _isCorrect ? Icons.check_circle : Icons.error,
                color: _isCorrect ? Colors.green : Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                _isCorrect ? "Perfect!" : "Try Again",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isCorrect ? Colors.green : Colors.red,
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
                      onTap: _isListening ? null : _startListening,
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
    );
  }
}

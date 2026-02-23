import 'package:flutter/material.dart';
import '../models/fill_in_the_blanks.dart';
import '../services/activity_api_service.dart';
import '../widgets/loading_widget.dart';

class FillInBlanksScreen extends StatefulWidget {
  final List<String> learningConcepts;
  final String language;

  const FillInBlanksScreen({
    super.key,
    required this.learningConcepts,
    required this.language,
  });

  @override
  State<FillInBlanksScreen> createState() => _FillInBlanksScreenState();
}

class _FillInBlanksScreenState extends State<FillInBlanksScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _isAnswerChecked = false;

  bool _isLoading = true;
  String? _errorMessage;
  List<FillInTheBlanks> _questions = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await ActivityApiService.generateActivity(
        widget.learningConcepts,
        "FILL_IN_THE_BLANKS",
        widget.language,
      );

      if (mounted) {
        setState(() {
          final questionsData = response['questions'] as List;
          _questions = questionsData
              .map((q) => FillInTheBlanks.fromJson(q))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _handleOptionSelect(int index) {
    if (_isAnswerChecked) return;
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _checkAnswer() {
    if (_selectedOptionIndex == null) return;

    setState(() {
      _isAnswerChecked = true;
      if (_selectedOptionIndex ==
          _questions[_currentQuestionIndex].correctOptionIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswerChecked = false;
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
              const Icon(Icons.star, color: Colors.orange, size: 60),
              const SizedBox(height: 16),
              Text(
                "Good Job!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You scored",
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$_score / ${_questions.length}",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
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
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Complete", style: TextStyle(fontSize: 16)),
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
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(type: LoadingType.fillInTheBlanks),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Fill in the Blanks")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  "Error loading activity",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _fetchData();
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Fill in the Blanks")),
        body: const Center(child: Text("No questions available.")),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fill in the Blanks"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Question ${_currentQuestionIndex + 1} of ${_questions.length}",
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade900 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 22,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: question.sentencePart1),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          _selectedOptionIndex != null
                              ? question.options[_selectedOptionIndex!]
                              : "   ?   ",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    TextSpan(text: question.sentencePart2),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: List.generate(question.options.length, (index) {
                  final isSelected = _selectedOptionIndex == index;
                  final isCorrect = question.correctOptionIndex == index;
                  final isWrong = isSelected && !isCorrect;

                  Color? borderColor;
                  Color? backgroundColor;

                  if (_isAnswerChecked) {
                    if (isCorrect) {
                      borderColor = Colors.green;
                      backgroundColor = Colors.green.withOpacity(0.1);
                    } else if (isWrong) {
                      borderColor = Colors.red;
                      backgroundColor = Colors.red.withOpacity(0.1);
                    } else {
                      borderColor = isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200;
                      backgroundColor = Colors.transparent;
                    }
                  } else {
                    if (isSelected) {
                      borderColor = Colors.blue;
                      backgroundColor = Colors.blue.withOpacity(0.1);
                    } else {
                      borderColor = isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200;
                      backgroundColor = Colors.transparent;
                    }
                  }

                  return InkWell(
                    onTap: () => _handleOptionSelect(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        border: Border.all(
                          color: borderColor,
                          width: isSelected || (_isAnswerChecked && isCorrect)
                              ? 2
                              : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        question.options[index],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedOptionIndex != null
                    ? (_isAnswerChecked ? _nextQuestion : _checkAnswer)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                  disabledForegroundColor: Colors.grey,
                ),
                child: Text(
                  _isAnswerChecked
                      ? (_currentQuestionIndex < _questions.length - 1
                            ? "Next Question"
                            : "Finish")
                      : "Check Answer",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

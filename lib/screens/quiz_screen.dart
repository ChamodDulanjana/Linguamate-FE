import 'package:flutter/material.dart';
import '../services/activity_api_service.dart';
import '../models/quiz.dart';
import '../widgets/loading_widget.dart';

class QuizScreen extends StatefulWidget {
  final List<String> learningConcepts;
  final String language;

  const QuizScreen({
    super.key,
    required this.learningConcepts,
    required this.language,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _isAnswerChecked = false;
  bool _isLoading = true;
  String? _errorMessage;
  List<Quiz> _questions = [];

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
  }

  //fetch quiz data from API
  Future<void> _fetchQuizData() async {
    try {
      final response = await ActivityApiService.generateActivity(
        widget.learningConcepts,
        "QUIZ",
        widget.language,
      );

      if (mounted) {
        setState(() {
          final questionsData = response['questions'] as List;
          _questions = questionsData.map((q) => Quiz.fromJson(q)).toList();
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
              const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
              const SizedBox(height: 16),
              Text(
                "Quiz Completed!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your score is",
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
                  color: Theme.of(context).colorScheme.primary,
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(type: LoadingType.quiz),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  "Error loading quiz",
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
                    _fetchQuizData();
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
        appBar: AppBar(title: const Text("Quiz")),
        body: const Center(child: Text("No questions available.")),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
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
            const SizedBox(height: 16),
            Text(
              question.question,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(question.options.length, (index) {
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
                  borderColor = Theme.of(context).colorScheme.primary;
                  backgroundColor = Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.05);
                } else {
                  borderColor = isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade200;
                  backgroundColor = Colors.transparent;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () => _handleOptionSelect(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isAnswerChecked && isCorrect
                                  ? Colors.green
                                  : _isAnswerChecked && isWrong
                                  ? Colors.red
                                  : isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                              width: 2,
                            ),
                            color: _isAnswerChecked && isCorrect
                                ? Colors.green
                                : _isAnswerChecked && isWrong
                                ? Colors.red
                                : isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                          ),
                          child: _isAnswerChecked && (isCorrect || isWrong)
                              ? Icon(
                                  isCorrect ? Icons.check : Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : isSelected
                              ? const Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            question.options[index],
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedOptionIndex != null
                    ? (_isAnswerChecked ? _nextQuestion : _checkAnswer)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                            : "Finish Quiz")
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

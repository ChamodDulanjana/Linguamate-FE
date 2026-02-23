import 'package:flutter/material.dart';

enum LoadingType { learning, quiz, fillInTheBlanks, speaking, general }

class LoadingWidget extends StatefulWidget {
  final LoadingType type;

  const LoadingWidget({super.key, this.type = LoadingType.general});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  late final List<String> _loadingPhrases;
  int _currentPhraseIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadingPhrases = _getPhrasesForType(widget.type);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _cyclePhrases();
  }

  List<String> _getPhrasesForType(LoadingType type) {
    switch (type) {
      case LoadingType.learning:
        return [
          "Analyzing grammar patterns...",
          "Extracting learning concepts...",
          "Preparing examples just for you...",
          "Almost there...",
        ];
      case LoadingType.quiz:
        return [
          "Generating challenging questions...",
          "Formulating possible answers...",
          "Crafting the perfect quiz...",
          "Getting things ready...",
        ];
      case LoadingType.fillInTheBlanks:
        return [
          "Creating context sentences...",
          "Hiding the keywords...",
          "Preparing the puzzle...",
          "Almost ready...",
        ];
      case LoadingType.speaking:
        return [
          "Setting up the conversation...",
          "Warming up the AI voice...",
          "Preparing pronunciation analysis...",
          "Just a moment...",
        ];
      case LoadingType.general:
        return [
          "Loading...",
          "Please wait...",
          "Getting things ready...",
          "Almost there...",
        ];
    }
  }

  void _cyclePhrases() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2, milliseconds: 500));
      if (mounted) {
        setState(() {
          _currentPhraseIndex =
              (_currentPhraseIndex + 1) % _loadingPhrases.length;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glowing logo
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isDarkMode ? Colors.blueAccent : Colors.blue)
                              .withOpacity(0.2 * _pulseAnimation.value),
                          blurRadius: 30 * _pulseAnimation.value,
                          spreadRadius: 8 * _pulseAnimation.value,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      isDarkMode
                          ? 'assets/images/linguamate_light_logo.png'
                          : 'assets/images/linguamate_logo.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 56),

          // Modern loading indicator
          // SizedBox(
          //   width: 40,
          //   height: 40,
          //   child: CircularProgressIndicator(
          //     strokeWidth: 3,
          //     valueColor: AlwaysStoppedAnimation<Color>(
          //       isDarkMode ? Colors.blueAccent : Colors.blue,
          //     ),
          //     backgroundColor: isDarkMode
          //         ? Colors.blueAccent.withOpacity(0.2)
          //         : Colors.blue.withOpacity(0.2),
          //   ),
          // ),
          // const SizedBox(height: 24),

          // Animated changing text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              _loadingPhrases[_currentPhraseIndex],
              key: ValueKey<int>(_currentPhraseIndex),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white70 : Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

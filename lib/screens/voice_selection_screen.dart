import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';
import '../services/user_service.dart';
import '../utils/voices_data.dart';

class VoiceSelectionScreen extends StatefulWidget {
  const VoiceSelectionScreen({super.key});

  @override
  State<VoiceSelectionScreen> createState() => _VoiceSelectionScreenState();
}

class _VoiceSelectionScreenState extends State<VoiceSelectionScreen> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  final AudioPlayer _audioPlayer = AudioPlayer();
  final UserService _userService = UserService();
  
  final List<Map<String, dynamic>> _voices = voiceList;

  int _currentIndex = 0;
  bool _isPlaying = false;
  String? _uid;

  int _playCounter = 0;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _initializeSelection();
  }

  Future<void> _initializeSelection() async {
    if (_uid != null) {
      final selectedVoice = await _userService.getUserVoice(_uid!);
      final index = _voices.indexWhere((v) => v["id"] == selectedVoice);
      if (index != -1 && index != 0) {
        setState(() => _currentIndex = index);
        // Jump to the selected page after the build is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pageController.jumpToPage(index);
        });
        return; // jumpToPage will trigger onPageChanged which calls _playVoicePreview
      } else {
        setState(() => _currentIndex = index != -1 ? index : 0);
        _playVoicePreview(_voices[_currentIndex]["id"]);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playVoicePreview(String voiceId) async {
    if (_uid == null) return;
    
    final currentPlay = ++_playCounter;
    setState(() => _isPlaying = true);
    
    try {
      final uri = await _userService.getVoicePreviewUri(_uid!, voiceId);
      if (currentPlay != _playCounter || !mounted) return;
      
      await _audioPlayer.stop(); // Stop any existing playback
      
      if (uri.scheme == 'file') {
        await _audioPlayer.setFilePath(uri.toFilePath());
      } else {
        await _audioPlayer.setAudioSource(AudioSource.uri(uri));
      }
      
      if (currentPlay != _playCounter || !mounted) return;
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error playing preview: $e");
    } finally {
      if (mounted && currentPlay == _playCounter) {
        setState(() => _isPlaying = false);
      }
    }
  }

  Future<void> _onSave() async {
    if (_uid != null) {
      final selectedVoice = _voices[_currentIndex]["id"];
      await _userService.updateUserVoice(_uid!, selectedVoice);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final fgColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Choose a voice",
          style: TextStyle(color: fgColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: fgColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  _playVoicePreview(_voices[index]["id"]);
                },
                itemCount: _voices.length,
                itemBuilder: (context, index) {
                  final voice = _voices[index];
                  final isSelected = index == _currentIndex;

                  return AnimatedScale(
                    scale: isSelected ? 1.0 : 0.8,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: voice["colors"] as List<Color>,
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: _isPlaying && isSelected 
                              ? const Center(
                                  child: Icon(Icons.volume_up, 
                                    size: 48, 
                                    color: Colors.white54
                                  )
                                )
                              : null,
                        ),
                        const SizedBox(height: 48),
                        Text(
                          voice["name"],
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: fgColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          voice["description"],
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Dots Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _voices.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index 
                          ? fgColor 
                          : (isDarkMode ? Colors.white24 : Colors.black12),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fgColor,
                    foregroundColor: bgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

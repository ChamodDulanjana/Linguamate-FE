class SpeakingPractice {
  final String id;
  final String sentence;
  final String phonetic;

  SpeakingPractice({
    required this.id,
    required this.sentence,
    required this.phonetic,
  });

  factory SpeakingPractice.fromJson(Map<String, dynamic> json) {
    return SpeakingPractice(
      id: json['id'] as String,
      sentence: json['sentence'] as String,
      phonetic: json['phonetic'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'sentence': sentence, 'phonetic': phonetic};
  }
}

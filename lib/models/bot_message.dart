class BotMessage {
  final String text;
  final DateTime timestamp;
  final String? imagePath;

  BotMessage({
    required this.text,
    required this.timestamp,
    this.imagePath,
  });
}

class UserMessage {
  final String text;
  final DateTime timestamp;
  final String? imagePath;

  UserMessage({required this.text, required this.timestamp, this.imagePath});
}
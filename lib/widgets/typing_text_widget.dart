import 'package:flutter/material.dart';

class TypingTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration typingSpeed;
  final VoidCallback? onTyping;  // Added callback

  const TypingTextWidget({
    Key? key,
    required this.text,
    this.style,
    this.typingSpeed = const Duration(milliseconds: 50),
    this.onTyping,  // Added parameter
  }) : super(key: key);

  @override
  State<TypingTextWidget> createState() => _TypingTextWidgetState();
}

class _TypingTextWidgetState extends State<TypingTextWidget> {
  String _displayedText = '';
  late final List<String> _characters;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _characters = widget.text.characters.toList();
    _startTyping();
  }

  void _startTyping() async {
    while (_currentIndex < _characters.length) {
      await Future.delayed(widget.typingSpeed);
      if (mounted) {
        setState(() {
          _displayedText += _characters[_currentIndex];
          _currentIndex++;
        });
        widget.onTyping?.call();  // Call the callback while typing
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
    );
  }
}
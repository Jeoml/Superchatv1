import 'package:flutter/material.dart';

class ExactBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: HigherCurvedLinePainter(),
        // No need for a child here unless you have interactive elements
      ),
    );
  }
}

class HigherCurvedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black.withOpacity(0.2) // Subtle white color for lines
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2; // Line thickness

    // Draw the curved lines in the lower part (bottom-right corner)
    for (int i = 0; i < 10; i++) {
      double spacing = i * 15.0; // Spacing between lines
      Path bottomPath = Path();
      bottomPath.moveTo(size.width, size.height - spacing); // Start from bottom-right
      bottomPath.quadraticBezierTo(
        size.width * 0.8, size.height - spacing - 150, // Control point
        0, size.height - spacing, // End point (bottom-left)
      );
      canvas.drawPath(bottomPath, paint);
    }

    // Draw the curved lines slightly above the middle, closer to the top
    for (int i = 0; i < 10; i++) {
      double spacing = i * 15.0; // Spacing between lines
      Path adjustedPath = Path();
      adjustedPath.moveTo(0, size.height * 0.35 + spacing); // Start slightly above middle-left
      adjustedPath.quadraticBezierTo(
        size.width * 0.5, size.height * 0.25 + spacing + 150, // Control point
        size.width, size.height * 0.25 + spacing, // End point
      );
      canvas.drawPath(adjustedPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No need to repaint for static design
  }
}

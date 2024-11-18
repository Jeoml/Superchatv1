import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SlidingSegmentControl extends StatefulWidget {
  final Function(String) onEndpointChanged;
  
  const SlidingSegmentControl({
    Key? key,
    required this.onEndpointChanged,
  }) : super(key: key);

  @override
  State<SlidingSegmentControl> createState() => _SlidingSegmentControlState();
}

class _SlidingSegmentControlState extends State<SlidingSegmentControl> {
  int selectedSegment = 0;
  String endpoint = 'chat';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CupertinoSlidingSegmentedControl<int>(
                backgroundColor: CupertinoColors.systemGrey6,
                thumbColor: CupertinoColors.white,
                groupValue: selectedSegment,
                children: {
                  0: buildSegment('Chat', 0),
                  1: buildSegment('PDF', 1),
                },
                onValueChanged: (value) {
                  setState(() {
                    selectedSegment = value!;
                    endpoint = value == 0 ? 'chat' : 'pdf';
                    widget.onEndpointChanged(endpoint);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSegment(String text, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: selectedSegment == index ? FontWeight.w600 : FontWeight.w400,
          color: selectedSegment == index 
              ? CupertinoColors.activeBlue
              : CupertinoColors.systemGrey,
        ),
      ),
    );
  }
}
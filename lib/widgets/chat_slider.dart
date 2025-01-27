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

  void _updateEndpoint(int? value) {
    if (value == null) return;
    
    setState(() {
      selectedSegment = value;
      switch (value) {
        case 0:
          endpoint = 'chat';
          break;
        case 1:
          endpoint = 'pdf';
          break;
        case 2:
          endpoint = 'csv';
          break;
      }
      print('Segment selected: $value, Endpoint: $endpoint'); // Debug print
      widget.onEndpointChanged(endpoint); // Make sure this is called
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CupertinoSlidingSegmentedControl<int>(
                backgroundColor: Colors.white,
                thumbColor: CupertinoColors.white,
                groupValue: selectedSegment,
                children: {
                  0: buildSegment('Chat', 0),
                  1: buildSegment('PDF', 1),
                  2: buildSegment('CSV', 2),
                },
                onValueChanged: _updateEndpoint,
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
              ? CupertinoColors.black 
              : CupertinoColors.systemGrey,
        ),
      ),
    );
  }
}
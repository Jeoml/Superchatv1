// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorder extends StatefulWidget {
  final void Function(String path) onStop;

  const AudioRecorder({super.key, required this.onStop});

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();
    final status = await Permission.microphone.request();
    print("Microphone permission status: $status"); // Log permission status
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _recorder?.openRecorder();
  }

  Future<void> _startRecording() async {
    if (_recorder == null) return;
    try {
      final directory = await getTemporaryDirectory();
      _recordingPath = '${directory.path}/temp_recording.wav';
      print("Starting recording at: $_recordingPath"); // Log recording path

      await _recorder!.startRecorder(
        toFile: _recordingPath,
        codec: Codec.pcm16WAV,
      );

      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting recording: $e'); // Log errors if any
    }
  }

  Future<void> _stopRecording() async {
    if (_recorder == null) return;
    try {
      await _recorder!.stopRecorder();
      setState(() {
        _isRecording = false;
      });

      if (_recordingPath != null) {
        print("Recording stopped, path: $_recordingPath"); // Log when recording stops
        widget.onStop(_recordingPath!);
      }
    } catch (e) {
      print('Error stopping recording: $e'); // Log errors if any
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
          iconSize: 48,
          color: _isRecording ? Colors.red : Colors.blue,
          onPressed: () {
            if (_isRecording) {
              _stopRecording();
            } else {
              _startRecording();
            }
          },
        ),
        const SizedBox(height: 8),
        Text(_isRecording ? 'Tap to stop' : 'Tap to record'),
      ],
    );
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    super.dispose();
  }
}

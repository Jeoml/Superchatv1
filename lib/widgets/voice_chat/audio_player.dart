import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class AudioPlayer extends StatefulWidget {
  final String source;
  final VoidCallback onDelete;

  const AudioPlayer({
    super.key,
    required this.source,
    required this.onDelete,
  });

  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  FlutterSoundPlayer? _player;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    print("Initializing audio player...");
    _player = FlutterSoundPlayer();
    try {
      await _player?.openPlayer();
      print("Audio player initialized successfully.");
    } catch (e) {
      print("Error initializing audio player: $e");
    }
  }

  Future<void> _playAudio() async {
    if (_player == null) return;
    try {
      print("Starting audio playback from source: ${widget.source}");
      await _player!.startPlayer(
        fromURI: widget.source,
        codec: Codec.pcm16WAV,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
          print("Audio playback finished.");
        },
      );
      setState(() {
        _isPlaying = true;
      });
      print("Audio playback started.");
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<void> _stopAudio() async {
    if (_player == null) return;
    try {
      print("Stopping audio playback.");
      await _player!.stopPlayer();
      setState(() {
        _isPlaying = false;
      });
      print("Audio playback stopped.");
    } catch (e) {
      print("Error stopping audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
          iconSize: 32,
          onPressed: _isPlaying ? _stopAudio : _playAudio,
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          iconSize: 32,
          onPressed: widget.onDelete,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _player?.closePlayer();
    print("Audio player disposed.");
    super.dispose();
  }
}

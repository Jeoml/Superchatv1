// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learnings1/services/token_service.dart';
import 'package:path_provider/path_provider.dart';
import './audio_player.dart';
import './audio_recorder.dart';
class VoiceChatBot extends StatefulWidget {
  final TextEditingController controller;

  const VoiceChatBot({
    super.key,
    required this.controller,
  });

  @override
  State<VoiceChatBot> createState() => _VoiceChatBotState();
}

class _VoiceChatBotState extends State<VoiceChatBot> {
  bool showPlayer = false;
  String? audioPath;
  bool isProcessing = false;

  Future<void> _processVoiceInput(String path) async {
    setState(() {
      isProcessing = true;
      widget.controller.text = 'Processing...';
    });

    try {
      print(
          "Processing voice input from path: $path"); // Log when starting voice input processing
      // Convert speech to text
      final transcription = await _sendAudioForTranscription(path);
      if (transcription != null) {
        widget.controller.text = transcription;
        print("Transcription: $transcription"); // Log transcription result

        // Get chatbot response
        final chatResponse = await _sendToChat(transcription);
        if (chatResponse != null) {
          print("Chatbot response: $chatResponse"); // Log chatbot response
          // Convert response to speech
          final audioResponse = await _convertTextToSpeech(chatResponse);
          if (audioResponse != null) {
            print(
                "Audio response saved at: $audioResponse"); // Log audio response path
            setState(() {
              audioPath = audioResponse;
              showPlayer = true;
            });
          }
        }
      }
    } catch (e) {
      print('Error in voice processing: $e'); // Log errors during processing
      widget.controller.text = 'Error processing voice input';
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<String?> _sendAudioForTranscription(String audioPath) async {
    try {
      print("Sending audio to transcription service..."); // Log sending audio
      final audioFile = File(audioPath);
      String? token = await requestToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://suitable-jolly-falcon.ngrok-free.app/transcript'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ' + token!,
      });

      request.files.add(
        await http.MultipartFile.fromPath('audio', audioFile.path),
      );

      final response = await request.send();
      final responseStr = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseStr);
      print(
          "Transcription response: $jsonResponse"); // Log transcription API response

      return jsonResponse['response'];
    } catch (e) {
      print('Error in transcription: $e'); // Log errors during transcription
      return null;
    }
  }

  Future<String?> _sendToChat(String userInput) async {
    try {
      print("Sending user input to chat: $userInput"); // Log user input to chat
      String? token = await requestToken();
      final response = await http.post(
        Uri.parse('http://suitable-jolly-falcon.ngrok-free.app/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'user_input': userInput}),
      );

      final jsonResponse = json.decode(response.body);
      print("Chat response: $jsonResponse"); // Log chat API response
      return jsonResponse['response'];
    } catch (e) {
      print('Error in chat: $e'); // Log errors during chat
      return null;
    }
  }

  Future<String?> _convertTextToSpeech(String text) async {
    try {
      print(
          "Converting text to speech: $text"); // Log text-to-speech conversion
      String? token = await requestToken();

      final response = await http.post(
        Uri.parse('http://suitable-jolly-falcon.ngrok-free.app/voice'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'user_input': text}),
      );

      final directory = await getTemporaryDirectory();
      final audioFile = File('${directory.path}/response_audio.wav');
      await audioFile.writeAsBytes(response.bodyBytes);
      print(
          "Audio saved at: ${audioFile.path}"); // Log the path where audio is saved
      return audioFile.path;
    } catch (e) {
      print('Error in text-to-speech: $e'); // Log errors during text-to-speech
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isProcessing ? 'Processing...' : 'Voice Chat',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            if (isProcessing)
              const CircularProgressIndicator()
            else if (showPlayer)
              AudioPlayer(
                source: audioPath!,
                onDelete: () {
                  setState(() {
                    showPlayer = false;
                    audioPath = null;
                  });
                },
              )
            else
              AudioRecorder(
                onStop: (path) => _processVoiceInput(path),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.controller.text = '';
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

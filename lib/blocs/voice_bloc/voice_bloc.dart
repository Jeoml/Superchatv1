import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

abstract class VoiceEvent {
  const VoiceEvent();
}

class StartVoiceCapture extends VoiceEvent {}

class SendTextToChatApi extends VoiceEvent {
  final String text;

  const SendTextToChatApi(this.text);
}

class ConvertTextToVoice extends VoiceEvent {
  final String responseText;

  const ConvertTextToVoice(this.responseText);
}

abstract class VoiceState {
  const VoiceState();
}

class VoiceInitial extends VoiceState {}

class VoiceProcessing extends VoiceState {}

class VoiceCompleted extends VoiceState {
  final String finalText;

  const VoiceCompleted(this.finalText);
}

class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
  final FlutterTts _flutterTts = FlutterTts();
  final String voiceApiUrl = 'https://your-voice-api-url.com/convert';
  final String chatApiUrl = 'https://your-chat-api-url.com/respond';

  VoiceBloc() : super(VoiceInitial()) {
    on<StartVoiceCapture>(_onStartVoiceCapture);
    on<SendTextToChatApi>(_onSendTextToChatApi);
    on<ConvertTextToVoice>(_onConvertTextToVoice);
  }

  Future<void> _onStartVoiceCapture(
      StartVoiceCapture event, Emitter<VoiceState> emit) async {
    emit(VoiceProcessing());

    try {
      final response = await http.post(
        Uri.parse(voiceApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"input": "voice data if any"}),
      );

      if (response.statusCode == 200) {
        final voiceText = jsonDecode(response.body)['text'];
        emit(VoiceCompleted(voiceText));
        add(SendTextToChatApi(voiceText));
      } else {
        throw Exception("Failed to convert voice to text");
      }
    } catch (e) {
      emit(VoiceCompleted("Error: ${e.toString()}"));
    }
  }

  Future<void> _onSendTextToChatApi(
      SendTextToChatApi event, Emitter<VoiceState> emit) async {
    emit(VoiceProcessing());

    try {
      final response = await http.post(
        Uri.parse(chatApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"message": event.text}),
      );

      if (response.statusCode == 200) {
        final chatResponse = jsonDecode(response.body)['response'];
        emit(VoiceCompleted(chatResponse));
        add(ConvertTextToVoice(chatResponse));
      } else {
        throw Exception("Failed to get chat API response");
      }
    } catch (e) {
      emit(VoiceCompleted("Error: ${e.toString()}"));
    }
  }

  Future<void> _onConvertTextToVoice(
      ConvertTextToVoice event, Emitter<VoiceState> emit) async {
    emit(VoiceProcessing());

    try {
      await _flutterTts.speak(event.responseText);
      emit(VoiceCompleted(event.responseText));
    } catch (e) {
      emit(VoiceCompleted("Error: ${e.toString()}"));
    }
  }
}

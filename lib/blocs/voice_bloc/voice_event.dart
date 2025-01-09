import 'package:equatable/equatable.dart';

abstract class VoiceEvent extends Equatable {
  const VoiceEvent();

  @override
  List<Object> get props => [];
}

class StartVoiceCapture extends VoiceEvent {}

class SendTextToChatApi extends VoiceEvent {
  final String text;

  const SendTextToChatApi(this.text);

  @override
  List<Object> get props => [text];
}

class ConvertTextToVoice extends VoiceEvent {
  final String responseText;

  const ConvertTextToVoice(this.responseText);

  @override
  List<Object> get props => [responseText];
}
       
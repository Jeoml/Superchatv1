import 'package:equatable/equatable.dart';

abstract class VoiceState extends Equatable {
  const VoiceState();

  @override
  List<Object> get props => [];
}

class VoiceInitial extends VoiceState {}

class VoiceProcessing extends VoiceState {}

class VoiceCompleted extends VoiceState {
  final String finalText;

  const VoiceCompleted(this.finalText);

  @override
  List<Object> get props => [finalText];
}

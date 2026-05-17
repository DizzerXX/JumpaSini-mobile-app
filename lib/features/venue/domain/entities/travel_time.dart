import 'package:equatable/equatable.dart';

class TravelTime extends Equatable {
  final int seconds;
  final String text;

  const TravelTime({required this.seconds, required this.text});

  @override
  List<Object?> get props => [seconds, text];
}

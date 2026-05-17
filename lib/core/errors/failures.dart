import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ServerFailure(super.message, {this.statusCode, this.errors});

  @override
  List<Object?> get props => [message, statusCode, errors];
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;

  const ValidationFailure(super.message, {this.errors});

  @override
  List<Object?> get props => [message, errors];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

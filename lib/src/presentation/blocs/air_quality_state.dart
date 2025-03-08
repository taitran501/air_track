part of 'air_quality_bloc.dart';

abstract class AirQualityState {}

class AirQualityInitial extends AirQualityState {}

class AirQualityLoading extends AirQualityState {}

class AirQualityLoaded extends AirQualityState {
  final AirQuality airQuality;
  final Position position;

  AirQualityLoaded(this.airQuality, this.position);
}

class AirQualityError extends AirQualityState {
  final String message;
  AirQualityError(this.message);
}

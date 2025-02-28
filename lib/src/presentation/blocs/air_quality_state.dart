part of 'air_quality_bloc.dart';

abstract class AirQualityState {}

class AirQualityInitial extends AirQualityState {}

class AirQualityLoading extends AirQualityState {}

class AirQualityLoaded extends AirQualityState { // Trạng thái khi dữ liệu đã được load
  final AirQuality airQuality;
  AirQualityLoaded(this.airQuality);
}

class AirQualityError extends AirQualityState { // Trạng thái khi xảy ra lỗi
  final String message;
  AirQualityError(this.message);
}

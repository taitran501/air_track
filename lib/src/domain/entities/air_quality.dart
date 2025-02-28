import 'package:equatable/equatable.dart';

class AirQuality extends Equatable {
  final int aqi;
  final double co;
  final double no2;
  final double o3;
  final double so2;
  final double pm25;
  final double pm10;
  final DateTime timestamp;

  const AirQuality({
    required this.aqi,
    required this.co,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm25,
    required this.pm10,
    required this.timestamp,
  });

  @override
  List<Object> get props => [aqi, co, no2, o3, so2, pm25, pm10, timestamp];
}

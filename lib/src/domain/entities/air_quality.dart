import 'package:equatable/equatable.dart';

class AirQuality extends Equatable {
  final double pm25;
  final double co2;
  final double temperature;
  final double humidity;

  const AirQuality({
    required this.pm25,
    required this.co2,
    required this.temperature,
    required this.humidity,
  });

  @override
  List<Object> get props => [pm25, co2, temperature, humidity]; // 2 đối tượng được coi là bằng nhau nếu chúng có cùng giá trị
  // ví dụ: AirQuality(pm25: 1, co2: 2, temperature: 3, humidity: 4) == AirQuality(pm25: 1, co2: 2, temperature: 3, humidity: 4) => true
  // AirQuality(pm25: 1, co2: 2, temperature: 3, humidity: 4) == AirQuality(pm25: 1, co2: 2, temperature: 3, humidity: 5) => false
}

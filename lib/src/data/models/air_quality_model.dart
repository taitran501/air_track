import '../../domain/entities/air_quality.dart';

class AirQualityModel extends AirQuality {
  const AirQualityModel({
    required double pm25,
    required double co2,
    required double temperature,
    required double humidity,
  }) : super(pm25: pm25, co2: co2, temperature: temperature, humidity: humidity);

  // Chuyển đổi từ JSON sang Model
  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    return AirQualityModel(
      pm25: (json['pm25'] as num).toDouble(),
      co2: (json['co2'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
    );
  }

  // Chuyển đổi từ Model sang JSON
  Map<String, dynamic> toJson() {
    return {
      'pm25': pm25,
      'co2': co2,
      'temperature': temperature,
      'humidity': humidity,
    };
  }
}

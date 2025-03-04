import '../../domain/entities/air_quality.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AirQualityModel extends AirQuality {
  const AirQualityModel({
    required int aqi,
    required double co,
    required double no2,
    required double o3,
    required double so2,
    required double pm25,
    required double pm10,
    required DateTime timestamp,
  }) : super(
          aqi: aqi,
          co: co,
          no2: no2,
          o3: o3,
          so2: so2,
          pm25: pm25,
          pm10: pm10,
          timestamp: timestamp,
        );

  /// **Chuyển đổi từ API OpenWeather**
  factory AirQualityModel.fromApi(Map<String, dynamic> json) {
    final data = json["list"][0];
    return AirQualityModel(
      aqi: data["main"]["aqi"] ?? 1,
      co: (data["components"]["co"] ?? 0.0).toDouble(),
      no2: (data["components"]["no2"] ?? 0.0).toDouble(),
      o3: (data["components"]["o3"] ?? 0.0).toDouble(),
      so2: (data["components"]["so2"] ?? 0.0).toDouble(),
      pm25: (data["components"]["pm2_5"] ?? 0.0).toDouble(),
      pm10: (data["components"]["pm10"] ?? 0.0).toDouble(),
      timestamp: DateTime.now(),
    );
  }

  /// **Chuyển đổi model thành Firestore**
  Map<String, dynamic> toFirestore() {
    return {
      "aqi": aqi,
      "co": co,
      "no2": no2,
      "o3": o3,
      "so2": so2,
      "pm25": pm25,
      "pm10": pm10,
      "timestamp": timestamp.toIso8601String(), // Chuyển DateTime thành String để lưu vào Firestore
    };
  }

/// **Tạo model từ Firestore**
factory AirQualityModel.fromFirestore(Map<String, dynamic> airQualityData) {
  return AirQualityModel(
    aqi: airQualityData["aqi"] ?? 1,
    co: (airQualityData["co"] ?? 0.0).toDouble(),
    no2: (airQualityData["no2"] ?? 0.0).toDouble(),
    o3: (airQualityData["o3"] ?? 0.0).toDouble(),
    so2: (airQualityData["so2"] ?? 0.0).toDouble(),
    pm25: (airQualityData["pm25"] ?? 0.0).toDouble(),
    pm10: (airQualityData["pm10"] ?? 0.0).toDouble(),
    timestamp: airQualityData["timestamp"] is Timestamp
        ? (airQualityData["timestamp"] as Timestamp).toDate()
        : DateTime.now(),
  );
}
}

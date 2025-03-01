import '../../domain/entities/air_quality.dart';

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

  // Thêm phương thức này để chuyển đổi model sang Firestore
  Map<String, dynamic> toFirestore() {
    return {
      "aqi": aqi,
      "co": co,
      "no2": no2,
      "o3": o3,
      "so2": so2,
      "pm25": pm25,
      "pm10": pm10,
      "timestamp": timestamp.toIso8601String(), // Chuyển DateTime thành String
    };
  }
}

import '../../../domain/entities/air_quality.dart';
import '../../models/air_quality_model.dart';

class SampleAirQuality {
  // Raw sample data for charts
  static List<double> get sampleData => [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];

  // Key-value pairs for air quality metrics
  static Map<String, double> get sampleValues => {
    "aqi": 50,
    "co": 0.4,
    "no2": 15.0,
    "o3": 25.0,
    "so2": 8.0,
    "pm25": 12.0,
    "pm10": 18.0,
  };
  
  // Get a complete AirQualityModel with sample data
  static AirQuality get airQuality => AirQualityModel(
    aqi: sampleValues["aqi"]!.toInt(), 
    co: sampleValues["co"]!,
    no2: sampleValues["no2"]!,
    o3: sampleValues["o3"]!,
    so2: sampleValues["so2"]!,
    pm25: sampleValues["pm25"]!,
    pm10: sampleValues["pm10"]!,
    timestamp: DateTime.now(),
  );
  
  // Get data formatted for charts
  static List<MapEntry<String, double>> get airQualityEntries => [
    MapEntry("AQI", sampleValues["aqi"]!),
    MapEntry("CO", sampleValues["co"]!),
    MapEntry("NO₂", sampleValues["no2"]!),
    MapEntry("O₃", sampleValues["o3"]!),
    MapEntry("SO₂", sampleValues["so2"]!),
    MapEntry("PM2.5", sampleValues["pm25"]!),
    MapEntry("PM10", sampleValues["pm10"]!),
  ];
}

import '../entities/air_quality.dart';

abstract class AirQualityRepository {
  /// Lấy dữ liệu chất lượng không khí theo thời gian thực
  Future<AirQuality> getAirQuality();
}

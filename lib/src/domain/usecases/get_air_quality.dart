import '../entities/air_quality.dart';
import '../repositories/air_quality_repository.dart';

class GetAirQuality {
  final AirQualityRepository repository;

  GetAirQuality(this.repository);

  Future<AirQuality> call() {
    return repository.getAirQuality(); // Gọi phương thức getAirQuality từ repository
  }
}

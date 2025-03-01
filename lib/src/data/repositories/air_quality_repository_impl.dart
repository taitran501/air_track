import 'package:cloud_firestore/cloud_firestore.dart';
import '../sources/remote/air_quality_api_service.dart';
import '../models/air_quality_model.dart';
import '../../domain/repositories/air_quality_repository.dart';
import '../../domain/entities/air_quality.dart';
import '../sources/local/location_service.dart';

class AirQualityRepositoryImpl implements AirQualityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AirQualityApiService _apiService = AirQualityApiService();

  @override
  Future<AirQuality> getAirQuality() async {
    try {
      // Lấy vị trí hiện tại của người dùng
      final position = await LocationService.getCurrentLocation();

      print("Lấy dữ liệu Air Quality từ OpenWeather API...");
      final data = await _apiService.fetchAirQuality(position.latitude, position.longitude);

      // Chuyển dữ liệu JSON thành model
      final airQuality = AirQualityModel.fromApi(data);

      // (Tuỳ chọn) Lưu vào Firestore để hỗ trợ caching dữ liệu
      await _firestore.collection("air_quality_data").doc("user_location").set(airQuality.toFirestore());

      return airQuality;
    } catch (e) {
      throw Exception("Lỗi khi lấy dữ liệu chất lượng không khí: $e");
    }
  }
}

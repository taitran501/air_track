import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import '../sources/remote/air_quality_api_service.dart';
import '../models/air_quality_model.dart';
import '../../domain/repositories/air_quality_repository.dart';
import '../../domain/entities/air_quality.dart';
import '../sources/local/location_service.dart';

class AirQualityRepositoryImpl implements AirQualityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AirQualityApiService _apiService = AirQualityApiService();

  @override
  Future<AirQuality> getAirQuality() async {
    final user = _auth.currentUser;

    // Nếu user là Guest, sử dụng dữ liệu mẫu ngay mà không cần gọi API
    if (user == null || user.isAnonymous) {
      print("👤 Guest Mode: Sử dụng dữ liệu mẫu (không gọi API)");
      
      // Return sample data immediately
      return AirQualityModel(
        aqi: 99, co: 0.3, no2: 10, o3: 15, so2: 5, pm25: 12, pm10: 20,
        timestamp: DateTime.now(),
      );
    }

    // User đã đăng nhập: Lấy dữ liệu từ API
    try {
      final position = await LocationService.getCurrentLocation();
      
      // Kiểm tra nếu không lấy được vị trí
      if (position == null) {
        print("⚠️ Không lấy được vị trí, dùng dữ liệu từ cache");
        
        // Thử lấy dữ liệu từ cache
        final cachedDoc = await _firestore.collection("air_quality_data").doc(user.uid).get();
        if (cachedDoc.exists) {
          return AirQualityModel.fromFirestore(cachedDoc.data()!);
        }
        
        // Nếu không có cache, dùng vị trí mặc định
        final data = await _apiService.fetchAirQuality(21.0278, 105.8342); // Hà Nội
        return AirQualityModel.fromApi(data);
      }
      
      print("📍 Lấy dữ liệu từ vị trí: ${position.latitude}, ${position.longitude}");
      final data = await _apiService.fetchAirQuality(position.latitude, position.longitude);
      final airQuality = AirQualityModel.fromApi(data);

      // Lưu vào Firestore để lấy lịch sử
      await _firestore.collection("air_quality_data").doc(user.uid).set(airQuality.toFirestore());

      return airQuality;
    } catch (e) {
      print("❌ Lỗi khi lấy dữ liệu từ API: $e");
      
      // Thử lấy từ cache
      try {
        final cachedDoc = await _firestore.collection("air_quality_data").doc(user.uid).get();
        if (cachedDoc.exists) {
          print("✅ Lấy dữ liệu từ cache");
          return AirQualityModel.fromFirestore(cachedDoc.data()!);
        }
      } catch (_) {}
      
      throw Exception("Không thể lấy dữ liệu chất lượng không khí.");
    }
  }
}

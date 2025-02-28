import 'package:cloud_firestore/cloud_firestore.dart';
import '../sources/remote/air_quality_api_service.dart';
import '../models/air_quality_model.dart';
import '../../domain/repositories/air_quality_repository.dart';
import '../../domain/entities/air_quality.dart';

class AirQualityRepositoryImpl implements AirQualityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AirQualityApiService _apiService = AirQualityApiService();

  @override
  Future<AirQuality> getAirQuality() async {
    try {
      print("Fetching Air Quality from Firestore...");
      DocumentSnapshot snapshot = await _firestore.collection("air_quality_data").doc("hcm").get();

      if (!snapshot.exists) {
        throw Exception("No data found in Firestore.");
      }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      print("Firestore Data: $data");

      return AirQualityModel(
        aqi: data["aqi"],
        co: data["co"],
        no2: data["no2"],
        o3: data["o3"],
        so2: data["so2"],
        pm25: data["pm2_5"],
        pm10: data["pm10"],
        timestamp: DateTime.fromMillisecondsSinceEpoch(data["timestamp"]),
      );
    } catch (e) {
      throw Exception("Error fetching Air Quality from Firestore: $e");
    }
  }
}

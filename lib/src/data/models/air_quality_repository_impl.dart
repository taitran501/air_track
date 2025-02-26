import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/air_quality.dart';
import '../../domain/repositories/air_quality_repository.dart';
import '../models/air_quality_model.dart';

class AirQualityRepositoryImpl implements AirQualityRepository {
  final FirebaseFirestore firestore;

  AirQualityRepositoryImpl(this.firestore);

  @override
  Future<AirQuality> getAirQuality() async {
    final snapshot = await firestore.collection('air_quality').doc('current').get(); // Lấy dữ liệu từ Firestore
    if (!snapshot.exists) {
      throw Exception("No data available");
    }
    return AirQualityModel.fromJson(snapshot.data()!); 
    // snapshot.data()! trả về dữ liệu của document hiện tại
    // AirQualityModel.fromJson chuyển đổi dữ liệu từ JSON sang Model
  }
}

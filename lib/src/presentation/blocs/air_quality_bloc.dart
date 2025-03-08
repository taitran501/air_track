import 'package:air_track/src/data/models/air_quality_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/air_quality_model.dart';
import 'package:air_track/src/data/sources/local/location_service.dart';
import '../../data/sources/remote/air_quality_api_service.dart';
import '../../domain/entities/air_quality.dart';

part 'air_quality_event.dart';
part 'air_quality_state.dart';

class AirQualityBloc extends Bloc<AirQualityEvent, AirQualityState> {
  final FirebaseFirestore firestore;
  final AirQualityApiService apiService = AirQualityApiService();

  AirQualityBloc({required this.firestore}) : super(AirQualityInitial()) {
    on<FetchAirQuality>((event, emit) async {
      emit(AirQualityLoading());

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(AirQualityError("Người dùng chưa đăng nhập"));
          return;
        }

        // 🔍 **Lấy vị trí hiện tại**
        final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        print("📍 Lấy vị trí: lat=${position.latitude}, lon=${position.longitude}");

        // 🔍 **Fetch dữ liệu từ API**
        final apiResponse = await apiService.fetchAirQuality(position.latitude, position.longitude);
        final airQuality = AirQualityModel.fromApi(apiResponse);

        // 🔍 **Lưu vào Firestore để caching**
        final collection = user.isAnonymous ? "guest_air_quality_data" : "air_quality_data";
        await firestore.collection(collection).doc(user.uid).set(airQuality.toFirestore());

        // 🔍 **Trả dữ liệu về UI**
        emit(AirQualityLoaded(airQuality, position));
      } catch (e) {
        emit(AirQualityError("Lỗi khi tải dữ liệu: $e"));
      }
    });
  }
}
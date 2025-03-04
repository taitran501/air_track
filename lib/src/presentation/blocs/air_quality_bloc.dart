import 'package:air_track/src/data/models/air_quality_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/air_quality.dart';
part 'air_quality_event.dart';
part 'air_quality_state.dart';

class AirQualityBloc extends Bloc<AirQualityEvent, AirQualityState> {
  final FirebaseFirestore firestore;
  AirQualityBloc({required this.firestore}) : super(AirQualityInitial()) {
    on<FetchAirQuality>((event, emit) async {
      emit(AirQualityLoading());

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(AirQualityError("Người dùng chưa đăng nhập"));
          return;
        }

        // Xác định collection dựa trên loại tài khoản (Guest/User)
        final collection = user.isAnonymous ? "guest_air_quality_data" : "air_quality_data";

        // Lấy dữ liệu từ Firestore
        final docRef = firestore.collection(collection).doc(user.uid);
        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          emit(AirQualityError("Không có dữ liệu cho tài khoản này"));
          return;
        }

        final airQualityData = docSnapshot.data() as Map<String, dynamic>;
        final airQuality = AirQualityModel.fromFirestore(airQualityData);

        emit(AirQualityLoaded(airQuality));
      } catch (e) {
        emit(AirQualityError("Lỗi khi tải dữ liệu: $e"));
      }
    });
  }
}

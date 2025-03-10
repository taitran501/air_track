import 'package:air_track/src/data/models/air_quality_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/air_quality_model.dart';
import 'package:air_track/src/data/sources/local/location_service.dart';
import '../../data/sources/remote/air_quality_api_service.dart';
import '../../domain/entities/air_quality.dart';
import '../../domain/usecases/get_air_quality.dart';
import '../../data/repositories/air_quality_repository_impl.dart';

part 'air_quality_event.dart';
part 'air_quality_state.dart';

class AirQualityBloc extends Bloc<AirQualityEvent, AirQualityState> {
  final FirebaseFirestore firestore;
  final AirQualityRepositoryImpl repository;

  AirQualityBloc({required this.firestore}) : 
    repository = AirQualityRepositoryImpl(),
    super(AirQualityInitial()) {
    
    on<FetchAirQuality>((event, emit) async {
      emit(AirQualityLoading());

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(AirQualityError("Người dùng chưa đăng nhập"));
          return;
        }

        // Get position only for authenticated users
        Position? position;
        if (!user.isAnonymous) {
          position = await LocationService.getCurrentLocation();
        }

        // Let repository handle the API fetching logic
        final airQuality = await repository.getAirQuality();
        
        // Emit with position (or default coordinates for guests)
        emit(AirQualityLoaded(
          airQuality, 
          position ?? Position(
            latitude: 21.0278, 
            longitude: 105.8342,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
            // Add required parameters based on your Position constructor
          )
        ));
      } catch (e) {
        emit(AirQualityError("Lỗi khi tải dữ liệu: $e"));
      }
    });
  }
}
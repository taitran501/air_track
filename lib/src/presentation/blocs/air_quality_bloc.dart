import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_air_quality.dart';
import '../../domain/entities/air_quality.dart';

part 'air_quality_event.dart';
part 'air_quality_state.dart';

class AirQualityBloc extends Bloc<AirQualityEvent, AirQualityState> {
  final GetAirQuality getAirQuality;

  AirQualityBloc(this.getAirQuality) : super(AirQualityInitial()) {
    on<FetchAirQuality>((event, emit) async {
      emit(AirQualityLoading());
      try {
        final airQuality = await getAirQuality.call();
        emit(AirQualityLoaded(airQuality));
      } catch (e) {
        emit(AirQualityError("Failed to load air quality data: $e"));
      }
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_air_quality.dart';
import '../../data/repositories/air_quality_repository_impl.dart';
import '../blocs/air_quality_bloc.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AirQualityBloc(GetAirQuality(AirQualityRepositoryImpl()))
        ..add(FetchAirQuality()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AirTrack - Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
        body: BlocBuilder<AirQualityBloc, AirQualityState>(
          builder: (context, state) {
            if (state is AirQualityLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AirQualityLoaded) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Chỉ số AQI: ${state.airQuality.aqi}",
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildAirQualityCard(state),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.bar_chart),
                      label: const Text("Xem biểu đồ"),
                      onPressed: () {
                        Navigator.pushNamed(context, '/chart');
                      },
                    ),
                  ],
                ),
              );
            } else if (state is AirQualityError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 50),
                    const SizedBox(height: 10),
                    Text("Lỗi tải dữ liệu: ${state.message}"),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AirQualityBloc>().add(FetchAirQuality());
                      },
                      child: const Text("Thử lại"),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text("Không có dữ liệu!"));
          },
        ),
      ),
    );
  }

  Widget _buildAirQualityCard(AirQualityLoaded state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAirQualityRow("CO", state.airQuality.co, "µg/m³"),
            _buildAirQualityRow("NO₂", state.airQuality.no2, "µg/m³"),
            _buildAirQualityRow("O₃", state.airQuality.o3, "µg/m³"),
            _buildAirQualityRow("PM2.5", state.airQuality.pm25, "µg/m³"),
            _buildAirQualityRow("PM10", state.airQuality.pm10, "µg/m³"),
          ],
        ),
      ),
    );
  }

  Widget _buildAirQualityRow(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          Text("$value $unit", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/sources/remote/air_quality_api_service.dart';
import '../../data/models/air_quality_model.dart';
import '../../data/sources/local/sample_air_quality.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bool isGuest = user == null || user.isAnonymous;
    final String collectionName = isGuest ? "guest_air_quality_data" : "air_quality_data";

    return Scaffold(
      appBar: AppBar(title: const Text('Biểu đồ chất lượng không khí')),
      body: isGuest ? _buildGuestChart() : _buildUserChart(),
    );
  }

  Widget _buildGuestChart() {
    // Use the centralized sample data
    final List<MapEntry<String, double>> chartData = SampleAirQuality.airQualityEntries;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value < chartData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(chartData[value.toInt()].key),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      chartData.length,
                      (index) => FlSpot(index.toDouble(), chartData[index].value),
                    ),
                    isCurved: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: true),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text("Dữ liệu mẫu (Chế độ khách)", 
                   style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildUserChart() {
    return FutureBuilder(
      future: _fetchAirQualityData(),
      builder: (context, AsyncSnapshot<List<double>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Không có dữ liệu để hiển thị"));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    snapshot.data!.length,
                    (index) => FlSpot(index.toDouble(), snapshot.data![index]),
                  ),
                  isCurved: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<double>> _fetchAirQualityData() async {
    try {
      final data = await AirQualityApiService().fetchAirQuality(21.0278, 105.8342); // Hà Nội làm fallback
      final airQuality = AirQualityModel.fromApi(data);
      return [
        airQuality.aqi.toDouble(),
        airQuality.co,
        airQuality.no2,
        airQuality.o3,
        airQuality.so2,
        airQuality.pm25,
        airQuality.pm10,
      ];
    } catch (e) {
      print("Lỗi khi lấy dữ liệu chất lượng không khí: $e");
      return [];
    }
  }
}

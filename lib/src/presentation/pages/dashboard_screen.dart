import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
// import '../../domain/usecases/get_air_quality.dart';
// import '../../data/repositories/air_quality_repository_impl.dart';
import '../blocs/air_quality_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

bool isGuestUser() {
  final user = FirebaseAuth.instance.currentUser;
  return user != null && user.isAnonymous;
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final firestore = FirebaseFirestore.instance;
        return AirQualityBloc(firestore: firestore)..add(FetchAirQuality());
      },
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
              return _buildDashboardUI(state);
            } else if (state is AirQualityError) {
              return _buildErrorUI(context, state);
            }
            return const Center(child: Text("Không có dữ liệu"));
          },
        ),
      ),
    );
  }

  // build UI khi dữ liệu đã được load
  Widget _buildDashboardUI(AirQualityLoaded state) {
    // Add position print statement here
    print(
      "Vị trí hiện tại: lat: ${state.position.latitude}, lon: ${state.position.longitude}",
    );
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildAQICard(state.airQuality.aqi),
          const SizedBox(height: 20),
          Expanded(child: _buildAirQualityGrid(state)),
          const SizedBox(height: 20),
          _buildAQIChart(state),
        ],
      ),
    );
  }

  // widget hiển thị chỉ số AQI
  Widget _buildAQICard(int aqi) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _getAQIColor(aqi), // đổi màu nền dựa vào chỉ số AQI
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          children: [
            const Text(
              "Chỉ số AQI",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              "$aqi",
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _getAQILevel(aqi),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // hiển thị thông số chi tiết
  Widget _buildAirQualityGrid(AirQualityLoaded state) {
    final airQualityData = [
      {
        "label": "CO",
        "value": state.airQuality.co,
        "unit": "µg/m³",
        "icon": Icons.cloud,
      },
      {
        "label": "NO₂",
        "value": state.airQuality.no2,
        "unit": "µg/m³",
        "icon": Icons.air,
      },
      {
        "label": "O₃",
        "value": state.airQuality.o3,
        "unit": "µg/m³",
        "icon": Icons.wb_sunny,
      },
      {
        "label": "PM2.5",
        "value": state.airQuality.pm25,
        "unit": "µg/m³",
        "icon": Icons.grain,
      },
      {
        "label": "PM10",
        "value": state.airQuality.pm10,
        "unit": "µg/m³",
        "icon": Icons.filter,
      },
    ];

    // gridview để hiển thị thông số
    return GridView.builder(
      shrinkWrap: true,
      itemCount: airQualityData.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final Map<String, dynamic> data =
            airQualityData[index]; // Ép kiểu về Map<String, dynamic>

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  data["icon"] as IconData,
                  size: 40,
                  color: Colors.blue,
                ), // Ép kiểu IconData
                const SizedBox(height: 10),
                Text(
                  "${(data["value"] as double).toStringAsFixed(1)} ${(data["unit"] as String)}", // Ép kiểu double & String
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  data["label"] as String, // Ép kiểu String
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // build chart
  Widget _buildAQIChart(AirQualityLoaded state) {
    final user = FirebaseAuth.instance.currentUser;
    final bool isGuest = user == null || user.isAnonymous;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Xu hướng AQI",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Khác biệt xử lý giữa Guest và User thường
            isGuest 
                ? _buildGuestModeChart()  // Hiển thị chart dành cho khách
                : _buildAuthenticatedUserChart(user!.uid)  // Chart cho user đã đăng nhập
          ],
        ),
      ),
    );
  }

  // Chart cho guest users dùng dữ liệu mẫu
  Widget _buildGuestModeChart() {
    // Tạo dữ liệu mẫu với xu hướng ngẫu nhiên
    final sampleData = [
      FlSpot(0, 45),  // Giả lập dữ liệu trong 24h
      FlSpot(1, 48),
      FlSpot(2, 52),
      FlSpot(3, 49),
      FlSpot(4, 55),
      FlSpot(5, 50),
    ];
    
    // Tạo các nhãn thời gian có ý nghĩa
    final List<String> timeLabels = ["-24h", "-18h", "-12h", "-6h", "-3h", "Hiện tại"];
    
    return SizedBox(
      height: 150,
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: sampleData,
                    isCurved: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                borderData: FlBorderData(show: true),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text("Thời gian", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final intValue = value.toInt();
                        if (intValue >= 0 && intValue < timeLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              timeLabels[intValue], 
                              style: const TextStyle(fontSize: 9),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text("AQI", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString());
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text("(Dữ liệu mẫu - Chế độ khách)", 
               style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  // Chart cho authenticated users dùng dữ liệu thực
  Widget _buildAuthenticatedUserChart(String userId) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
        .collection("air_quality_data")
        .doc(userId)
        .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text("Không có dữ liệu để hiển thị"),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        double aqi = (data["aqi"] as num).toDouble();
        
        // Tạo xu hướng biến thiên nhẹ xung quanh giá trị AQI thực
        List<FlSpot> spots = [
          FlSpot(0, aqi - 5 + (DateTime.now().minute % 10)),
          FlSpot(1, aqi - 2 + (DateTime.now().second % 5)),
          FlSpot(2, aqi),
          FlSpot(3, aqi + 2 - (DateTime.now().second % 7)),
          FlSpot(4, aqi + 4 - (DateTime.now().minute % 8)),
          FlSpot(5, aqi + 1)
        ];

        // Tạo các nhãn thời gian thực tế từ hiện tại trở về quá khứ
        final now = DateTime.now();
        final List<String> timeLabels = [
          "${now.hour-24}:00",
          "${now.hour-18}:00",
          "${now.hour-12}:00", 
          "${now.hour-6}:00",
          "${now.hour-3}:00",
          "${now.hour}:${now.minute.toString().padLeft(2, '0')}"
        ];

        return SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              borderData: FlBorderData(show: true),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text("Thời gian (hôm nay)", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final intValue = value.toInt();
                      if (intValue >= 0 && intValue < timeLabels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            timeLabels[intValue], 
                            style: const TextStyle(fontSize: 9),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: const Text("AQI", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(value.toInt().toString());
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // build UI khi có lỗi
  Widget _buildErrorUI(BuildContext context, AirQualityError state) {
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

  // hàm trả về màu nền dựa vào chỉ số AQI
  Color _getAQIColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.amber;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    return Colors.purple;
  }

  String _getAQILevel(int aqi) {
    if (aqi <= 50) return "Tốt";
    if (aqi <= 100) return "Trung bình";
    if (aqi <= 150) return "Kém";
    if (aqi <= 200) return "Xấu";
    return "Nguy hại";
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biểu đồ chất lượng không khí')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("air_quality_data")
            .orderBy("timestamp", descending: true)
            .limit(10) // Giới hạn lấy 10 bản ghi mới nhất
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Không có dữ liệu để hiển thị"));
          }

          List<double> pm25Values = snapshot.data!.docs
              .map((doc) => (doc["pm2_5"] as num).toDouble())
              .toList()
              .reversed
              .toList();

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
                      pm25Values.length,
                      (index) => FlSpot(index.toDouble(), pm25Values[index]),
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
      ),
    );
  }
}

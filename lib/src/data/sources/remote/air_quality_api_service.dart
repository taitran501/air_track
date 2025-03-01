import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AirQualityApiService {
  final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? "";
  final String baseUrl = "https://api.openweathermap.org/data/2.5/air_pollution";

  Future<Map<String, dynamic>> fetchAirQuality(double lat, double lon) async {
    final url = Uri.parse("$baseUrl?lat=$lat&lon=$lon&appid=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Không thể lấy dữ liệu chất lượng không khí: ${response.body}");
    }
  }
}

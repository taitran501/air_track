import 'dart:convert';
import 'package:http/http.dart' as http;

class AirQualityApiService {
  final String apiKey = "4486409d2c7a88df8cd511013544ee17";
  final String baseUrl = "https://api.openweathermap.org/data/2.5/air_pollution";

  Future<Map<String, dynamic>> fetchAirQuality(double lat, double lon) async {
    final response = await http.get(
      Uri.parse("$baseUrl?lat=$lat&lon=$lon&appid=$apiKey"),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch air quality data");
    }
  }
}

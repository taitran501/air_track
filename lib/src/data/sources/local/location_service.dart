import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra xem dịch vụ vị trí có được bật không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Vui lòng bật GPS.");
    }

    // Kiểm tra quyền truy cập vị trí
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Quyền truy cập vị trí bị từ chối.");
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Quyền truy cập vị trí bị từ chối vĩnh viễn. Vui lòng cấp quyền trong cài đặt.");
    }

    // Trả về vị trí hiện tại
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
  
  // Helper method to calculate distance between two positions
  static double calculateDistance(Position position1, Position position2) {
    return Geolocator.distanceBetween(
      position1.latitude,
      position1.longitude,
      position2.latitude,
      position2.longitude,
    );
  }
}
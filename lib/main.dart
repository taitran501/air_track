import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'src/presentation/pages/dashboard_screen.dart';
import 'src/domain/usecases/get_air_quality.dart';
import 'src/data/repositories/air_quality_repository_impl.dart';
import 'src/presentation/blocs/air_quality_bloc.dart';
import 'src/presentation/pages/chart_screen.dart';
import 'src/presentation/pages/setting_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load biến môi trường
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Đăng nhập ẩn danh trước khi vào ứng dụng
  Future<void> loginAnonymously() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("Signed in as: ${userCredential.user?.uid}");
    } catch (e) {
      print("Error signing in: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loginAnonymously(), // Đăng nhập ẩn danh trước khi vào ứng dụng
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            title: 'AirTrack',
            theme: ThemeData(primarySwatch: Colors.blue),
            initialRoute: '/',
            routes: {
              '/': (context) => DashboardScreen(),
              '/chart': (context) => ChartScreen(),
              '/settings': (context) => SettingsScreen(),
            },
          );

        }
        return MultiBlocProvider( // bloc provider cho toàn bộ ứng dụng
          providers: [
            BlocProvider(
              create: (context) => AirQualityBloc(GetAirQuality(AirQualityRepositoryImpl()))
                ..add(FetchAirQuality()),
            ),
          ],
          child: MaterialApp(
            title: 'AirTrack',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: DashboardScreen(),
          ),
        );
      },
    );
  }
}

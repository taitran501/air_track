// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'src/presentation/pages/dashboard_screen.dart';
import 'src/presentation/pages/login_screen.dart';
// import 'src/domain/usecases/get_air_quality.dart';
// import 'src/data/repositories/air_quality_repository_impl.dart';
import 'src/presentation/blocs/air_quality_bloc.dart';
import 'src/presentation/pages/chart_screen.dart';
import 'src/presentation/pages/setting_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'src/core/utils/platform_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'src/data/sources/local/location_service.dart';
void main() async { // async: hàm chạy bất đồng bộ
  WidgetsFlutterBinding.ensureInitialized(); // widgets flutter binding: khởi tạo môi trường chạy ứng dụng
  await dotenv.load();
  print("✅ .env file loaded successfully");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    final position = await LocationService.getCurrentLocation();
    print("📍 Vị trí khi mở app: ${position.latitude}, ${position.longitude}");
  } catch (e) {
    print("❌ Không thể lấy vị trí khi mở app: $e");
  }
  print("✅ Firebase initialized successfully");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
// Future: là một đối tượng giúp chúng ta thực hiện các tác vụ bất đồng bộ
// async: hàm chạy bất đồng bộ
// bất đồng bộ: không chờ kết quả trả về mà tiếp tục thực hiện các tác vụ khác
// await: chờ kết quả trả về từ một hàm bất đồng bộ
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return; // Người dùng hủy đăng nhập
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.isAnonymous) {
        await user.linkWithCredential(credential); // Liên kết với tài khoản Google
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account upgraded to Google successfully")));
      } else {
        await FirebaseAuth.instance.signInWithCredential(credential); // Đăng nhập với Google
      }
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      print("❌ Google Sign-In Failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Authentication Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => AirQualityBloc(firestore: FirebaseFirestore.instance)..add(FetchAirQuality()),
      ),
    ],
    child: MaterialApp(
      title: 'AirTrack',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasData && !snapshot.data!.isAnonymous) {
              return DashboardScreen();
            }
            return LoginScreen();
          },
        ),
        '/dashboard': (context) => DashboardScreen(),
        '/chart': (context) => ChartScreen(),
        '/settings': (context) => SettingsScreen(),
        '/login': (context) => LoginScreen(),
      },
    ),
  );
  }
}
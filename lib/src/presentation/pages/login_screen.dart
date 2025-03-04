import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

Future<void> _signInWithGoogle() async {
  if (!kIsWeb && Platform.isWindows) { // Kiểm tra nếu đang chạy trên Windows
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Google Sign-In is not supported on Windows. Please use anonymous login."),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    
    if (googleUser == null) {
      setState(() => _isLoading = false);
      return; // Người dùng hủy đăng nhập
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    print("Đăng nhập thành công: ${userCredential.user?.displayName}");

    // Chuyển đến Dashboard sau khi đăng nhập thành công
    Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (_) => DashboardScreen()),
    );
  } catch (e) {
    print("Google Sign-In Failed: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Google Authentication Failed: ${e.toString()}")),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

Future<void> _signInAnonymously() async {
  setState(() => _isLoading = true);
  try {
    final UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
    final String userId = userCredential.user!.uid;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final docRef = firestore.collection("guest_air_quality_data").doc(userId);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      await docRef.set({
        "pm2_5": 0.0,
        "co": 0.0,
        "no2": 0.0,
        "o3": 0.0,
        "so2": 0.0,
        "pm10": 0.0,
        "timestamp": FieldValue.serverTimestamp(),
      });
      print("✅ Đã tạo dữ liệu mặc định cho tài khoản Guest: $userId");

      // **Chờ Firestore cập nhật trước khi tiếp tục**
      await Future.delayed(Duration(seconds: 2));
    } else {
      print("✅ Dữ liệu Guest đã tồn tại.");
    }

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => DashboardScreen()));
  } catch (e) {
    print("❌ Anonymous Login Failed: $e");
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Anonymous Login Failed")));
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("AirTrack", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signInWithGoogle,
                    child: Text("Đăng nhập với Google"),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: _signInAnonymously,
                    child: Text("Tiếp tục với tư cách khách"),
                  ),
                ],
              ),
      ),
    );
  }
}

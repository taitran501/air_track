import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double alertThreshold = 50.0;
  bool notificationsEnabled = true;
  bool isGuest = true; // Mặc định là guest, kiểm tra sau

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
    _loadSettings();
  }

  Future<void> _checkUserStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      setState(() {
        isGuest = false; // Nếu là Google Account, cho phép chỉnh sửa
      });
    }
  }

  Future<void> _loadSettings() async {
    if (isGuest) return; // Guest không cần load cài đặt
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance
            .collection("settings")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();
    if (snapshot.exists) {
      setState(() {
        alertThreshold = snapshot["alert_threshold"].toDouble();
        notificationsEnabled = snapshot["notifications_enabled"];
      });
    }
  }

  Future<void> _saveSettings() async {
    if (isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please sign in to update settings")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection("settings")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
          "alert_threshold": alertThreshold,
          "notifications_enabled": notificationsEnabled,
        });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Cài đặt đã được lưu")));
  }

  Future<void> _logout() async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null && user.isAnonymous) {
        // Nếu là Guest, xóa tài khoản
        await user.delete();
        print("✅ Đã xóa tài khoản Guest thành công");
      } else {
        await FirebaseAuth.instance.signOut();
      }

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi đăng xuất: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("Ngưỡng cảnh báo PM2.5"),
              subtitle: Text("$alertThreshold µg/m³"),
              trailing:
                  isGuest
                      ? const Text("Guest Mode")
                      : SizedBox(
                        width: 150,
                        child: Slider(
                          min: 10,
                          max: 200,
                          divisions: 19,
                          value: alertThreshold,
                          onChanged: (value) {
                            if (!isGuest) {
                              setState(() {
                                alertThreshold = value;
                              });
                            }
                          },
                        ),
                      ),
            ),
            SwitchListTile(
              title: const Text("Nhận thông báo cảnh báo"),
              value: notificationsEnabled,
              onChanged:
                  isGuest
                      ? null
                      : (value) {
                        setState(() {
                          notificationsEnabled = value;
                        });
                      },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text("Lưu cài đặt"),
            ),
            const SizedBox(height: 20),
            // Đăng xuất ở dưới cùng
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white
              ),
              child: const Text("Đăng xuất"),
            ),
            if (isGuest)
              TextButton(
                onPressed: () {
                  // Chuyển hướng người dùng đến đăng nhập Google
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text("Upgrade to Google Account"),
              ),
          ],
        ),
      ),
    );
  }
}

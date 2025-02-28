import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double alertThreshold = 50.0;
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection("settings").doc("user_settings").get();
    if (snapshot.exists) {
      setState(() {
        alertThreshold = snapshot["alert_threshold"].toDouble();
        notificationsEnabled = snapshot["notifications_enabled"];
      });
    }
  }

  Future<void> _saveSettings() async {
    await FirebaseFirestore.instance.collection("settings").doc("user_settings").set({
      "alert_threshold": alertThreshold,
      "notifications_enabled": notificationsEnabled,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cài đặt đã được lưu")));
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
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  min: 10,
                  max: 200,
                  divisions: 19,
                  value: alertThreshold,
                  onChanged: (value) {
                    setState(() {
                      alertThreshold = value;
                    });
                  },
                ),
              ),
            ),
            SwitchListTile(
              title: const Text("Nhận thông báo cảnh báo"),
              value: notificationsEnabled,
              onChanged: (value) {
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
          ],
        ),
      ),
    );
  }
}

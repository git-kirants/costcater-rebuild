import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import 'package:costcater/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  // Function to request storage permission
  Future<void> requestStoragePermission() async {
    Timer(const Duration(seconds: 2), () async {
      PermissionStatus status;

      // Check device's Android version
      if (Platform.isAndroid && (await androidVersion()) >= 33) {
        // For Android 13+ request READ_MEDIA_IMAGES permission
        status = await Permission.photos.request();
      } else {
        // For Android 12 and below, request storage permissions
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        // Navigate to LoginPage if permission is granted
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else if (status.isDenied) {
        // Show permission explanation dialog
        showPermissionDialog();
      } else if (status.isPermanentlyDenied) {
        // Show a SnackBar for permanently denied permission
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is permanently denied.'),
          ),
        );
        openAppSettings(); // Direct the user to settings
      }
    });
  }

  // Function to display permission dialog
  void showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Storage Permission Required'),
          content: const Text(
            'This app needs access to your device storage to save invoices.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                openAppSettings(); // Open app settings
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Continue Without Permission'),
            ),
          ],
        );
      },
    );
  }

  // Helper to get the Android version
  Future<int> androidVersion() async {
    return int.tryParse(Platform.version.split(' ')[0]) ?? 30;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/logos/costcaterlogo.png',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AdhanScreen extends StatelessWidget {
  final String prayerName;

  const AdhanScreen({super.key, required this.prayerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.withOpacity(0.9),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "حان الآن موعد أذان",
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white.withOpacity(0.8),
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                prayerName,
                style: const TextStyle(
                  fontSize: 56,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal,
                ),
                onPressed: () {
                  // إغلاق الشاشة عند الضغط
                  Navigator.pop(context);
                },
                child: const Text('إغلاق'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: file_names
import 'package:flutter/material.dart';
import 'package:islamic_app/features/prayer_times/views/screens/prayer_times_screen.dart';
import 'package:islamic_app/features/quran/views/screens/surah_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // قائمة الشاشات التي سيتم التنقل بينها
  final List<Widget> _screens = [
    const PrayerTimesScreen(),
    const SurahListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // اعرض الشاشة المحددة
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_filled_rounded),
            label: 'أوقات الصلاة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'القرآن',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}

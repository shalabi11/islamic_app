import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/surah_model.dart'; // استيراد مودل السورة

class QuranPageViewerScreen extends StatefulWidget {
  final int startingPage;
  final List<Surah> allSurahs; // 1. استقبال قائمة السور الكاملة

  const QuranPageViewerScreen({
    super.key,
    required this.startingPage,
    required this.allSurahs,
  });

  @override
  State<QuranPageViewerScreen> createState() => _QuranPageViewerScreenState();
}

class _QuranPageViewerScreenState extends State<QuranPageViewerScreen> {
  late PageController _pageController;
  late int _currentPage;
  int? _bookmarkedPage; // 2. متغير لحفظ رقم الصفحة المحفوظة

  @override
  void initState() {
    super.initState();
    _currentPage = widget.startingPage;
    _pageController = PageController(initialPage: _currentPage - 1);
    _loadBookmark(); // 3. تحميل الإشارة المرجعية عند بدء الشاشة
  }

  // --- دالة لتحميل الإشارة المرجعية ---
  Future<void> _loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarkedPage = prefs.getInt('bookmarked_page');
    });
  }

  // --- دالة لحفظ أو حذف الإشارة المرجعية ---
  Future<void> _toggleBookmark(int page) async {
    final prefs = await SharedPreferences.getInstance();
    // إذا كانت الصفحة الحالية هي المحفوظة، قم بإزالتها
    if (_bookmarkedPage == page) {
      await prefs.remove('bookmarked_page');
      setState(() {
        _bookmarkedPage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إزالة الإشارة المرجعية')),
      );
    } else {
      // وإلا، قم بحفظها
      await prefs.setInt('bookmarked_page', page);
      setState(() {
        _bookmarkedPage = page;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ الإشارة المرجعية عند صفحة $page')),
      );
    }
  }

  // --- 4. دالة للبحث عن اسم السورة بناءً على رقم الصفحة ---
  String _getSurahNameForPage(int page) {
    // ابحث في كل السور
    for (var surah in widget.allSurahs) {
      // ابحث في كل الآيات داخل السورة
      for (var verse in surah.verses) {
        if (verse.page == page) {
          return surah
              .nameAr; // عند العثور على أول آية في الصفحة، أعد اسم السورة
        }
      }
    }
    return 'القرآن الكريم'; // قيمة افتراضية
  }

  @override
  Widget build(BuildContext context) {
    // 5. تحديد ما إذا كانت الصفحة الحالية هي المحفوظة
    final bool isBookmarked = _currentPage == _bookmarkedPage;

    return Scaffold(
      appBar: AppBar(
        // 6. عرض اسم السورة في شريط العنوان
        title: Text(_getSurahNameForPage(_currentPage)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black54,
        actions: [
          IconButton(
            // 7. تغيير شكل ولون الأيقونة بناءً على الحالة
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.teal : null,
            ),
            tooltip: 'حفظ إشارة مرجعية',
            onPressed: () {
              _toggleBookmark(_currentPage);
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: PageView.builder(
          controller: _pageController,
          reverse: false,
          itemCount: 604,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page + 1;
            });
          },
          itemBuilder: (context, index) {
            final pageNumber = index + 1;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset(
                'assets/quran_images/$pageNumber.png', // تأكد من أن الصور بصيغة png
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Text('خطأ في تحميل صفحة $pageNumber'));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

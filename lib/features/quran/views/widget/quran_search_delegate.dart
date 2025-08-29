import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/surah_model.dart';
import '../../data/models/verse_model.dart';
import '../../view_model/quran_cubit.dart';
import '../../view_model/quran_state.dart';
import '../screens/surah_detail_screen.dart';

// كلاس مساعد لتمثيل نتيجة البحث
class SearchResult {
  final Surah surah;
  final Verse? verse; // الآية قد تكون اختيارية (في حال البحث عن سورة)
  SearchResult({required this.surah, this.verse});
}

class QuranSearchDelegate extends SearchDelegate<SearchResult?> {
  // --- منطق البحث ---
  List<SearchResult> _performSearch(String query, List<Surah> allSurahs) {
    if (query.isEmpty) {
      return [];
    }

    // دالة لتنظيف النص للمقارنة
    String normalizeText(String text) {
      return text
          .replaceAll(RegExp(r'[\u064B-\u0652]'), '') // إزالة التشكيل
          .replaceAll('أ', 'ا')
          .replaceAll('إ', 'ا')
          .replaceAll('آ', 'ا')
          .replaceAll('ة', 'ه');
    }

    final normalizedQuery = normalizeText(query);
    final List<SearchResult> results = [];

    for (var surah in allSurahs) {
      // البحث في اسم السورة
      if (normalizeText(surah.nameAr).contains(normalizedQuery)) {
        results.add(SearchResult(surah: surah));
      }
      // البحث في الآيات
      for (var verse in surah.verses) {
        if (normalizeText(verse.textAr).contains(normalizedQuery)) {
          results.add(SearchResult(surah: surah, verse: verse));
        }
      }
    }
    return results;
  }

  // --- بناء واجهة البحث ---
  @override
  Widget buildResults(BuildContext context) {
    final quranState = context.read<QuranCubit>().state;
    if (quranState is QuranLoaded) {
      final results = _performSearch(query, quranState.surahs);
      return _buildResultsList(results);
    }
    return const Center(child: Text("لا يمكن إجراء البحث حالياً"));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // عرض النتائج بشكل فوري أثناء الكتابة
    return buildResults(context);
  }

  Widget _buildResultsList(List<SearchResult> results) {
    if (results.isEmpty) {
      return const Center(child: Text("لا توجد نتائج"));
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        bool isSurahResult = result.verse == null;

        if (isSurahResult) {
          // عرض نتيجة البحث عن سورة (لا تغيير هنا)
          return ListTile(
            leading: const Icon(Icons.book_outlined),
            title: Text(result.surah.nameAr),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (ctx) => SurahDetailScreen(surah: result.surah),
                ),
              );
            },
          );
        } else {
          // عرض نتيجة البحث عن آية
          return ListTile(
            title: Text(
              result.verse!.textAr,
              style: const TextStyle(fontFamily: 'Amiri', fontSize: 18),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "سورة ${result.surah.nameAr} - آية ${result.verse!.number}",
            ),
            onTap: () {
              // --- ✅ التعديل هنا ---
              // عند الضغط، انتقل إلى شاشة عرض الآيات
              // ومرر معها رقم الآية التي يجب تلوينها
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (ctx) => SurahDetailScreen(
                    surah: result.surah,
                    highlightVerseNumber:
                        result.verse!.number, // مرّر رقم الآية هنا
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  // ... (الأزرار والإعدادات الأخرى لواجهة البحث)
  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];
  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );
}

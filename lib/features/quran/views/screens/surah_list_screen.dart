import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/features/quran/views/widget/quran_search_delegate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../view_model/quran_cubit.dart';
import '../../view_model/quran_state.dart';
import '../../data/models/surah_model.dart';
import 'surah_detail_screen.dart';
import 'quran_page_viewer_screen.dart';

// تم تحويل الشاشة إلى StatefulWidget لحفظ اختيار المستخدم
class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  // متغير لحفظ حالة العرض الحالية (الافتراضي هو وضع المصحف/الصور)
  bool _isImageView = true;
  Future<void> _gotoBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    // اقرأ رقم الصفحة المحفوظة، إذا لم تكن موجودة، اذهب للصفحة 1
    final int bookmarkedPage = prefs.getInt('bookmarked_page') ?? 1;

    // تأكد من أن context ما زال صالحاً قبل الانتقال
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuranPageViewerScreen(
            startingPage: bookmarkedPage,
            allSurahs: [],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _gotoBookmark,
        label: const Text('العودة للقراءة'),
        icon: const Icon(Icons.bookmark_outlined),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        elevation: 1,
        // إضافة زر التبديل في شريط العنوان
        actions: [
          IconButton(
            tooltip: _isImageView
                ? 'التبديل إلى وضع القراءة (النص)'
                : 'التبديل إلى وضع المصحف (الصور)',
            icon: Icon(
              // تغيير الأيقونة بناءً على الوضع الحالي
              _isImageView
                  ? Icons.text_fields_rounded
                  : Icons.photo_library_outlined,
            ),

            onPressed: () {
              // عند الضغط، يتم تحديث الحالة لعكس اختيار المستخدم
              setState(() {
                _isImageView = !_isImageView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: QuranSearchDelegate());
            },
          ),
        ],
      ),
      body: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, state) {
          if (state is QuranLoading || state is QuranInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuranLoaded) {
            return ListView.separated(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.surahs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final Surah surah = state.surahs[index];
                // تمرير حالة العرض الحالية إلى الويدجت المسؤولة عن عرض السورة
                return SurahTile(surah: surah, isImageView: _isImageView);
              },
            );
          } else if (state is QuranError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const Center(child: Text("لا توجد بيانات لعرضها"));
        },
      ),
    );
  }
}

class SurahTile extends StatelessWidget {
  const SurahTile({super.key, required this.surah, required this.isImageView});

  final Surah surah;
  final bool isImageView;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            surah.number.toString(),
            style: const TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          surah.nameAr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Amiri',
          ),
        ),
        subtitle: Text(
          '${surah.nameTransliteration} (${surah.versesCount} verses)',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          surah.revelationPlaceAr,
          style: const TextStyle(
            color: Colors.teal,
            fontStyle: FontStyle.italic,
          ),
        ),
        onTap: () {
          if (isImageView) {
            final startingPage = surah.verses.isNotEmpty
                ? surah.verses[0].page
                : 1;
            final allSurahs = context.read<QuranCubit>().state as QuranLoaded;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuranPageViewerScreen(
                  startingPage: startingPage,
                  allSurahs: allSurahs.surahs, // ✅ مرّر القائمة الكاملة هنا
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahDetailScreen(surah: surah),
              ),
            );
          }
        },
      ),
    );
  }
}

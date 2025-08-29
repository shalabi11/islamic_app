import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:islamic_app/features/quran/data/models/surah_model.dart';

class QuranRepository {
  // هذه الدالة ستقوم بقراءة الملف وتحويله إلى قائمة من كائنات السور
  Future<List<Surah>> getAllSurahs() async {
    try {
      // 1. قراءة محتوى الملف كنص من مجلد assets
      final String jsonString = await rootBundle.loadString(
        'assets/data/mainDataQuran.json',
      );

      // 2. تحويل النص إلى قائمة يمكن التعامل معها
      final List<dynamic> jsonList = json.decode(jsonString);

      // 3. تحويل كل عنصر في القائمة إلى كائن Surah باستخدام الـ factory constructor
      // الذي أنشأناه سابقاً في المودل
      return jsonList.map((json) => Surah.fromJson(json)).toList();
    } catch (e) {
      // في حال حدوث خطأ أثناء قراءة الملف
      print("Error loading surahs from asset: $e");
      // أعد قائمة فارغة لتجنب انهيار التطبيق
      return [];
    }
  }
}

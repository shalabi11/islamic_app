import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repository/quran_repository.dart';
import 'quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  final QuranRepository _quranRepository;

  // عند إنشاء الكيوبت، نمرر له المستودع ونبدأ بالحالة الابتدائية
  QuranCubit(this._quranRepository) : super(QuranInitial()) {
    // نقوم باستدعاء الدالة لجلب السور فور إنشاء الكيوبت
    fetchAllSurahs();
  }

  // دالة لجلب كل السور من المستودع
  Future<void> fetchAllSurahs() async {
    try {
      // 1. أبلغ الواجهة أننا بدأنا التحميل
      emit(QuranLoading());

      // 2. اطلب البيانات من المستودع وانتظر النتيجة
      final surahs = await _quranRepository.getAllSurahs();

      // 3. إذا نجحت العملية، أرسل البيانات للواجهة
      emit(QuranLoaded(surahs));
    } catch (e) {
      // 4. إذا حدث خطأ، أرسل رسالة الخطأ للواجهة
      emit(QuranError("فشل تحميل قائمة السور: ${e.toString()}"));
    }
  }
}

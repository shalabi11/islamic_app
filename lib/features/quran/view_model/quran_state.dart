import 'package:equatable/equatable.dart';
import 'package:islamic_app/features/quran/data/models/surah_model.dart';

abstract class QuranState extends Equatable {
  const QuranState();

  @override
  List<Object> get props => [];
}

// الحالة الابتدائية قبل تحميل أي شيء
class QuranInitial extends QuranState {}

// حالة جاري التحميل (عندما يتم قراءة الملف)
class QuranLoading extends QuranState {}

// حالة النجاح بعد تحميل قائمة السور بنجاح
class QuranLoaded extends QuranState {
  final List<Surah> surahs;

  const QuranLoaded(this.surahs);

  @override
  List<Object> get props => [surahs];
}

// حالة الخطأ إذا فشلت عملية قراءة الملف
class QuranError extends QuranState {
  final String message;

  const QuranError(this.message);

  @override
  List<Object> get props => [message];
}

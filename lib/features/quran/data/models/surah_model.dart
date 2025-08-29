import 'verse_model.dart';
import 'audio_model.dart';

class Surah {
  final int number;
  final String nameAr;
  final String nameEn;
  final String nameTransliteration;
  final String revelationPlaceAr;
  final String revelationPlaceEn;
  final int versesCount;
  final int wordsCount;
  final int lettersCount;
  final List<Verse> verses;
  final List<Audio> audio;

  Surah({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.nameTransliteration,
    required this.revelationPlaceAr,
    required this.revelationPlaceEn,
    required this.versesCount,
    required this.wordsCount,
    required this.lettersCount,
    required this.verses,
    required this.audio,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    var versesList = json['verses'] as List;
    List<Verse> verses = versesList.map((v) => Verse.fromJson(v)).toList();

    var audioList = json['audio'] as List;
    List<Audio> audio = audioList.map((a) => Audio.fromJson(a)).toList();

    return Surah(
      number: json['number'],
      nameAr: json['name']['ar'],
      nameEn: json['name']['en'],
      nameTransliteration: json['name']['transliteration'],
      revelationPlaceAr: json['revelation_place']['ar'],
      revelationPlaceEn: json['revelation_place']['en'],
      versesCount: json['verses_count'],
      wordsCount: json['words_count'],
      lettersCount: json['letters_count'],
      verses: verses,
      audio: audio,
    );
  }
}

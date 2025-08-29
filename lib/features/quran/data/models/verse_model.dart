import 'sajda_model.dart';

class Verse {
  final int number;
  final String textAr;
  final String textEn;
  final int juz;
  final int page;
  final Sajda? sajda;

  Verse({
    required this.number,
    required this.textAr,
    required this.textEn,
    required this.juz,
    required this.page,
    this.sajda,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      number: json['number'],
      textAr: json['text']['ar'],
      textEn: json['text']['en'],
      juz: json['juz'],
      page: json['page'],
      sajda: json['sajda'] is Map<String, dynamic>
          ? Sajda.fromJson(json['sajda'])
          : null,
    );
  }
}

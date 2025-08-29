class Audio {
  final int id;
  final String reciterAr;
  final String reciterEn;
  final String rewayaAr;
  final String rewayaEn;
  final String server;
  final String link; // <-- الخاصية المفقودة

  Audio({
    required this.id,
    required this.reciterAr,
    required this.reciterEn,
    required this.rewayaAr,
    required this.rewayaEn,
    required this.server,
    required this.link, // <-- أضفناه هنا
  });

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      id: json['id'],
      reciterAr: json['reciter']['ar'],
      reciterEn: json['reciter']['en'],
      rewayaAr: json['rewaya']['ar'],
      rewayaEn: json['rewaya']['en'],
      server: json['server'],
      link: json['link'], // <-- وأضفناه هنا
    );
  }
}

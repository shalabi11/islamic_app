class Sajda {
  final int id;
  final bool recommended;
  final bool obligatory;

  Sajda({
    required this.id,
    required this.recommended,
    required this.obligatory,
  });

  factory Sajda.fromJson(Map<String, dynamic> json) {
    return Sajda(
      id: json['id'],
      recommended: json['recommended'],
      obligatory: json['obligatory'],
    );
  }
}

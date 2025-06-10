class LeaveSuggestion {
  final bool suggested;
  final DateTime? date;
  final String? suggestion;
  final String? motivation;

  LeaveSuggestion(
      {required this.suggested, this.date, this.suggestion, this.motivation});

  factory LeaveSuggestion.fromJson(Map<String, dynamic> json) {
    return LeaveSuggestion(
      suggested: json['suggested'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      suggestion: json['suggestion'],
      motivation: json['motivation'],
    );
  }
}

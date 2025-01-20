class Holiday {
  final String title;
  final String date;

  Holiday({
    required this.title,
    required this.date,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      title: json['name'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
    };
  }
}

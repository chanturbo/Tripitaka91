class TripitakaResult {
  final double score;
  final int tripitakaNo;
  final double tripitakaCode;
  final int tripitakaBook;
  final int tripitakaPage;
  final int tripitakaLine;
  final String content;

  TripitakaResult({
    required this.score,
    required this.tripitakaNo,
    required this.tripitakaCode,
    required this.tripitakaBook,
    required this.tripitakaPage,
    required this.tripitakaLine,
    required this.content,
  });

  factory TripitakaResult.fromJson(Map<String, dynamic> json) {
    return TripitakaResult(
      score: (json['score'] as num).toDouble(),
      tripitakaNo: json['tripitaka91_no'],
      tripitakaCode: (json['tripitaka91_code'] as num).toDouble(),
      tripitakaBook: json['tripitaka91_book'],
      tripitakaPage: json['tripitaka91_page'],
      tripitakaLine: json['tripitaka91_line'],
      content: json['content'],
    );
  }
}

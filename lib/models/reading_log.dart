class ReadingLog {
  final String id;
  final String userId;
  final String bookId;
  final String bookTitle;
  final int pagesRead;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final String? locationName;

  ReadingLog({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    required this.pagesRead,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'pagesRead': pagesRead,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
    };
  }

  factory ReadingLog.fromMap(Map<String, dynamic> map) {
    return ReadingLog(
      id: map['id'] as String,
      userId: map['userId'] as String? ?? '',
      bookId: map['bookId'] as String,
      bookTitle: map['bookTitle'] as String,
      pagesRead: map['pagesRead'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      locationName: map['locationName'] as String?,
    );
  }
}
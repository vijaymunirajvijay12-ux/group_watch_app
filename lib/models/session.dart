class Session {
  final String sessionId;
  final String hostId;
  final String videoUrl;
  final List<String> participants;
  final DateTime createdAt;
  final bool isActive;

  Session({
    required this.sessionId,
    required this.hostId,
    required this.videoUrl,
    required this.participants,
    required this.createdAt,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'hostId': hostId,
      'videoUrl': videoUrl,
      'participants': participants,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['sessionId'],
      hostId: json['hostId'],
      videoUrl: json['videoUrl'],
      participants: List<String>.from(json['participants']),
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'],
    );
  }
}

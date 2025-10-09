class Session {
  String sessionId;
  DateTime startTime;
  DateTime? endTime;
  int startSteps;
  int endSteps;
  int totalSteps; // endSteps - startSteps
  String endReason; // USER_STOP, REBOOT, DATE_CHANGE, CRASH

  Session({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    required this.startSteps,
    required this.endSteps,
    required this.totalSteps,
    this.endReason = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'startSteps': startSteps,
      'endSteps': endSteps,
      'totalSteps': totalSteps,
      'endReason': endReason,
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['sessionId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      startSteps: json['startSteps'],
      endSteps: json['endSteps'],
      totalSteps: json['totalSteps'],
      endReason: json['endReason'] ?? '',
    );
  }
}

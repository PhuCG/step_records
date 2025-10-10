import 'package:isar_community/isar.dart';

part 'step_record.g.dart';

@collection
class DailyStepRecord {
  Id id = Isar.autoIncrement;
  @Index()
  late DateTime date; // YYYY-MM-DD format for daily tracking
  late int steps; // Steps for this specific day
  late int lastKnownSteps; // Last known step count from pedometer
  @Index()
  late DateTime lastUpdateTime;
  late String sessionId;
  late bool synced; // For future server sync

  DailyStepRecord({
    required this.date,
    this.steps = 0,
    this.lastKnownSteps = 0,
    required this.lastUpdateTime,
    required this.sessionId,
    this.synced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'steps': steps,
      'lastKnownSteps': lastKnownSteps,
      'lastUpdateTime': lastUpdateTime.toIso8601String(),
      'sessionId': sessionId,
      'synced': synced,
    };
  }

  factory DailyStepRecord.fromJson(Map<String, dynamic> json) {
    return DailyStepRecord(
      date: DateTime.parse(json['date']),
      steps: json['steps'] ?? 0,
      lastKnownSteps: json['lastKnownSteps'] ?? 0,
      lastUpdateTime: DateTime.parse(json['lastUpdateTime']),
      sessionId: json['sessionId'],
      synced: json['synced'] ?? false,
    );
  }
}

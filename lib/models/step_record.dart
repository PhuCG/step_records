import 'package:hive/hive.dart';

part 'step_record.g.dart';

@HiveType(typeId: 0)
class StepRecord {
  @HiveField(0)
  String id;

  @HiveField(1)
  int steps;

  @HiveField(2)
  int delta;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String sessionId;

  @HiveField(5)
  bool synced; // For future server sync

  StepRecord({
    required this.id,
    required this.steps,
    required this.delta,
    required this.timestamp,
    required this.sessionId,
    this.synced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'steps': steps,
      'delta': delta,
      'timestamp': timestamp.toIso8601String(),
      'sessionId': sessionId,
      'synced': synced,
    };
  }

  factory StepRecord.fromJson(Map<String, dynamic> json) {
    return StepRecord(
      id: json['id'],
      steps: json['steps'],
      delta: json['delta'],
      timestamp: DateTime.parse(json['timestamp']),
      sessionId: json['sessionId'],
      synced: json['synced'] ?? false,
    );
  }
}

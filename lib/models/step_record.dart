import 'package:isar_community/isar.dart';

part 'step_record.g.dart';

@collection
class StepRecord {
  Id autoId = Isar.autoIncrement; // internal primary key for isar

  late String id; // external uuid
  late int steps;
  late int delta;
  late DateTime timestamp;
  late String sessionId;
  late bool synced; // For future server sync

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

import 'package:isar_community/isar.dart';

part 'step_record.g.dart';

@collection
class DailyStepRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;
  late int steps;
  late DateTime lastUpdateTime;

  DailyStepRecord({
    required this.date,
    this.steps = 0,
    required this.lastUpdateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'steps': steps,
      'lastUpdateTime': lastUpdateTime.toIso8601String(),
    };
  }

  factory DailyStepRecord.fromJson(Map<String, dynamic> json) {
    return DailyStepRecord(
      date: DateTime.parse(json['date']),
      steps: json['steps'] ?? 0,
      lastUpdateTime: DateTime.parse(json['lastUpdateTime']),
    );
  }
}

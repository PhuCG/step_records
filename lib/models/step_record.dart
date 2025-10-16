import 'package:isar_community/isar.dart';

part 'step_record.g.dart';

@collection
class DailyStepRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;
  int? startSteps;
  int? endSteps;
  DateTime? lastUpdateTime;

  int get steps => (endSteps ?? 0) - (startSteps ?? 0);
}

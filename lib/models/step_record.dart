import 'package:isar_community/isar.dart';

part 'step_record.g.dart';

@collection
class DailyStepRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;
  int? steps;
  DateTime? lastUpdateTime;

  int get stepsCount => steps ?? 0;
}

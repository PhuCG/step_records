import 'package:isar_community/isar.dart';

part 'step_log_entry.g.dart';

@collection
class StepLogEntry {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime time;
  late int stepNumber;
  late String name;
  late String vehicleId;
}

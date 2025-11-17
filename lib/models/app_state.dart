import 'package:isar_community/isar.dart';

part 'app_state.g.dart';

@collection
class AppState {
  Id id = 0;
  bool isServiceRunning = false;
  DateTime? startEventTime;
  String? driverName;
  String? vehicleId;
}

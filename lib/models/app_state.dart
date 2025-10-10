import 'package:isar_community/isar.dart';

part 'app_state.g.dart';

@collection
class AppState {
  Id id = 0;

  late bool isServiceRunning;

  AppState({this.isServiceRunning = false});

  Map<String, dynamic> toJson() {
    return {'isServiceRunning': isServiceRunning};
  }

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(isServiceRunning: json['isServiceRunning'] ?? false);
  }
}

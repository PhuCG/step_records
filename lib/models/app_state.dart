import 'package:isar_community/isar.dart';

part 'app_state.g.dart';

@collection
class AppState {
  Id id = 0; // always a single row with fixed id

  DateTime? serviceStartTime;
  int lastKnownSteps;
  String currentSessionId;
  bool isServiceRunning;
  DateTime? lastUpdateTime;

  AppState({
    this.serviceStartTime,
    this.lastKnownSteps = 0,
    this.currentSessionId = '',
    this.isServiceRunning = false,
    this.lastUpdateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceStartTime': serviceStartTime?.toIso8601String(),
      'lastKnownSteps': lastKnownSteps,
      'currentSessionId': currentSessionId,
      'isServiceRunning': isServiceRunning,
      'lastUpdateTime': lastUpdateTime?.toIso8601String(),
    };
  }

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      serviceStartTime: json['serviceStartTime'] != null
          ? DateTime.parse(json['serviceStartTime'])
          : null,
      lastKnownSteps: json['lastKnownSteps'] ?? 0,
      currentSessionId: json['currentSessionId'] ?? '',
      isServiceRunning: json['isServiceRunning'] ?? false,
      lastUpdateTime: json['lastUpdateTime'] != null
          ? DateTime.parse(json['lastUpdateTime'])
          : null,
    );
  }
}

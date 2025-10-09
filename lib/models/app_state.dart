import 'package:hive/hive.dart';

part 'app_state.g.dart';

@HiveType(typeId: 2)
class AppState {
  @HiveField(0)
  DateTime? serviceStartTime;

  @HiveField(1)
  int lastKnownSteps;

  @HiveField(2)
  String currentSessionId;

  @HiveField(3)
  bool isServiceRunning;

  @HiveField(4)
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

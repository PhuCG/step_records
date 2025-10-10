import 'package:isar_community/isar.dart';

part 'app_state.g.dart';

@collection
class AppState {
  Id id = Isar.autoIncrement;

  DateTime? serviceStartTime;
  @Index()
  late String currentSessionId;
  late bool isServiceRunning;
  DateTime? lastUpdateTime;
  DateTime? lastDateReset; // Track when we last reset daily counter

  AppState({
    this.serviceStartTime,
    this.currentSessionId = '',
    this.isServiceRunning = false,
    this.lastUpdateTime,
    this.lastDateReset,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceStartTime': serviceStartTime?.toIso8601String(),
      'currentSessionId': currentSessionId,
      'isServiceRunning': isServiceRunning,
      'lastUpdateTime': lastUpdateTime?.toIso8601String(),
      'lastDateReset': lastDateReset?.toIso8601String(),
    };
  }

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      serviceStartTime: json['serviceStartTime'] != null
          ? DateTime.parse(json['serviceStartTime'])
          : null,
      currentSessionId: json['currentSessionId'] ?? '',
      isServiceRunning: json['isServiceRunning'] ?? false,
      lastUpdateTime: json['lastUpdateTime'] != null
          ? DateTime.parse(json['lastUpdateTime'])
          : null,
      lastDateReset: json['lastDateReset'] != null
          ? DateTime.parse(json['lastDateReset'])
          : null,
    );
  }
}

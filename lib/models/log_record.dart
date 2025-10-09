import 'package:hive/hive.dart';

part 'log_record.g.dart';

@HiveType(typeId: 1)
class LogRecord {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  String level;

  @HiveField(3)
  String eventType;

  @HiveField(4)
  Map<String, dynamic> data;

  LogRecord({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.eventType,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'level': level,
      'eventType': eventType,
      'data': data,
    };
  }

  factory LogRecord.fromJson(Map<String, dynamic> json) {
    return LogRecord(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      level: json['level'],
      eventType: json['eventType'],
      data: Map<String, dynamic>.from(json['data']),
    );
  }
}

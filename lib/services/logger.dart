import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/log_record.dart';
import 'storage_service.dart';

enum LogLevel { debug, info, warn, error }

class Logger {
  static const String _tag = 'StepCounter';
  static final Uuid _uuid = const Uuid();

  static Future<void> log(
    LogLevel level,
    String eventType,
    Map<String, dynamic> data,
  ) async {
    try {
      final record = LogRecord(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        level: level.name,
        eventType: eventType,
        data: data,
      );

      // Store in database
      await StorageService.instance.addLogRecord(record);

      // Print to console in debug mode
      if (kDebugMode) {
        final message = '[$_tag] ${level.name}: $eventType - $data';
        print(message);
      }
    } catch (e) {
      // Fallback to console if database fails
      if (kDebugMode) {
        print('Logger error: $e');
      }
    }
  }

  static Future<void> debug(String eventType, Map<String, dynamic> data) async {
    await log(LogLevel.debug, eventType, data);
  }

  static Future<void> info(String eventType, Map<String, dynamic> data) async {
    await log(LogLevel.info, eventType, data);
  }

  static Future<void> warn(String eventType, Map<String, dynamic> data) async {
    await log(LogLevel.warn, eventType, data);
  }

  static Future<void> error(String eventType, Map<String, dynamic> data) async {
    await log(LogLevel.error, eventType, data);
  }
}

import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/step_record.dart';
import '../models/log_record.dart';
import '../models/app_state.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static StorageService get instance => _instance;
  StorageService._internal();

  static const String _stepRecordsBox = 'step_records';
  static const String _logRecordsBox = 'log_records';
  static const String _appStateBox = 'app_state';

  Box<StepRecord>? _stepRecordsBoxInstance;
  Box<LogRecord>? _logRecordsBoxInstance;
  Box<AppState>? _appStateBoxInstance;

  Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(StepRecordAdapter());
    Hive.registerAdapter(LogRecordAdapter());
    Hive.registerAdapter(AppStateAdapter());

    // Open boxes
    _stepRecordsBoxInstance = await Hive.openBox<StepRecord>(_stepRecordsBox);
    _logRecordsBoxInstance = await Hive.openBox<LogRecord>(_logRecordsBox);
    _appStateBoxInstance = await Hive.openBox<AppState>(_appStateBox);

    // Cleanup old data
    await _cleanupOldData();
  }

  // Step Records
  Future<void> addStepRecord(StepRecord record) async {
    await _stepRecordsBoxInstance?.put(record.id, record);
  }

  Future<List<StepRecord>> getStepRecords(DateTime from, DateTime to) async {
    final records =
        _stepRecordsBoxInstance?.values.where((record) {
          return record.timestamp.isAfter(from) &&
              record.timestamp.isBefore(to);
        }).toList() ??
        [];

    records.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return records;
  }

  Future<List<StepRecord>> getAllStepRecords() async {
    final records = _stepRecordsBoxInstance?.values.toList() ?? [];
    records.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return records;
  }

  Future<StepRecord?> getLatestStepRecord() async {
    final records = await getAllStepRecords();
    return records.isNotEmpty ? records.last : null;
  }

  // Log Records
  Future<void> addLogRecord(LogRecord record) async {
    await _logRecordsBoxInstance?.put(record.id, record);
  }

  Future<List<LogRecord>> getLogRecords(DateTime from, DateTime to) async {
    final records =
        _logRecordsBoxInstance?.values.where((record) {
          return record.timestamp.isAfter(from) &&
              record.timestamp.isBefore(to);
        }).toList() ??
        [];

    records.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return records;
  }

  Future<List<LogRecord>> getAllLogRecords() async {
    final records = _logRecordsBoxInstance?.values.toList() ?? [];
    records.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return records;
  }

  // App State
  Future<void> saveAppState(AppState state) async {
    await _appStateBoxInstance?.put('current', state);
  }

  Future<AppState> getAppState() async {
    final state = _appStateBoxInstance?.get('current');
    return state ?? AppState();
  }

  // Data cleanup
  Future<void> _cleanupOldData() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // Cleanup step records older than 30 days
    final oldStepRecords =
        _stepRecordsBoxInstance?.values
            .where((record) => record.timestamp.isBefore(thirtyDaysAgo))
            .map((record) => record.id)
            .toList() ??
        [];

    for (final id in oldStepRecords) {
      await _stepRecordsBoxInstance?.delete(id);
    }

    // Cleanup log records older than 7 days
    final oldLogRecords =
        _logRecordsBoxInstance?.values
            .where((record) => record.timestamp.isBefore(sevenDaysAgo))
            .map((record) => record.id)
            .toList() ??
        [];

    for (final id in oldLogRecords) {
      await _logRecordsBoxInstance?.delete(id);
    }
  }

  // Export data
  Future<Map<String, dynamic>> exportData(DateTime from, DateTime to) async {
    final stepRecords = await getStepRecords(from, to);
    final logRecords = await getLogRecords(from, to);
    final appState = await getAppState();

    return {
      'export_date': DateTime.now().toIso8601String(),
      'date_range': {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      },
      'app_state': appState.toJson(),
      'step_records': stepRecords.map((e) => e.toJson()).toList(),
      'log_records': logRecords.map((e) => e.toJson()).toList(),
      'summary': _generateSummary(stepRecords),
    };
  }

  Map<String, dynamic> _generateSummary(List<StepRecord> stepRecords) {
    if (stepRecords.isEmpty) {
      return {
        'total_steps': 0,
        'total_records': 0,
        'first_record': null,
        'last_record': null,
      };
    }

    final totalSteps = stepRecords.last.steps - stepRecords.first.steps;
    return {
      'total_steps': totalSteps,
      'total_records': stepRecords.length,
      'first_record': stepRecords.first.timestamp.toIso8601String(),
      'last_record': stepRecords.last.timestamp.toIso8601String(),
    };
  }

  // Get storage directory for exports
  Future<Directory> getExportDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download/StepCounterLogs');
    } else {
      final documentsDir = await getApplicationDocumentsDirectory();
      return Directory('${documentsDir.path}/StepCounterLogs');
    }
  }

  Future<void> close() async {
    await _stepRecordsBoxInstance?.close();
    await _logRecordsBoxInstance?.close();
    await _appStateBoxInstance?.close();
  }
}

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer_2/pedometer_2.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/step_log_entry.dart';
import 'storage_service.dart';

class StepCounterService {
  static final StepCounterService _instance = StepCounterService._internal();
  static StepCounterService get instance => _instance;
  StepCounterService._internal();

  static const String _notificationTitle = 'Step Counter Active';
  static const String _notificationText = 'Counting your steps...';

  final _storageService = StorageService.instance;

  Future<void> initialize() async {
    try {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'step_counter_service',
          channelName: 'Step Counter Service',
          channelDescription: 'Keeps track of your steps continuously',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
        ),
        iosNotificationOptions: IOSNotificationOptions(
          showNotification: false,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(5000), // 5 seconds
          autoRunOnBoot: false, // Disable auto-run on boot for simplified flow
          allowWakeLock: true,
          allowWifiLock: false,
        ),
      );

      // Clean old CSV files on initialization
      await _cleanOldCsvFiles();

      // Validate service state on startup
      await _validateServiceState();

      developer.log('SERVICE_INITIALIZED');
    } catch (e) {
      developer.log('SERVICE_INIT_ERROR error: $e', level: 1000, error: e);
      rethrow;
    }
  }

  Future<void> _validateServiceState() async {
    try {
      final isServiceRunning = await FlutterForegroundTask.isRunningService;
      var appState = await _storageService.getAppState();

      // Sync local state with actual service status
      if (appState.isServiceRunning != isServiceRunning) {
        appState.isServiceRunning = isServiceRunning;
        if (!isServiceRunning) {
          appState.startEventTime = null;
          appState.driverName = null;
          appState.vehicleId = null;
        }
        await _storageService.saveAppState(appState);
        developer.log(
          'SERVICE_STATE_SYNC: localState=${appState.isServiceRunning} || actualState=$isServiceRunning',
        );
      }
    } catch (e) {
      developer.log('VALIDATE_SERVICE_STATE_ERROR: $e', level: 1000, error: e);
    }
  }

  Future<bool> startService({
    required String name,
    required String vehicleId,
  }) async {
    try {
      final isServiceRunning = await FlutterForegroundTask.isRunningService;
      if (isServiceRunning) {
        developer.log('SERVICE_ALREADY_RUNNING');
        return true;
      }

      // Save start time and driver info
      final startTime = DateTime.now();
      var appState = await _storageService.getAppState();
      appState.isServiceRunning = true;
      appState.startEventTime = startTime;
      appState.driverName = name;
      appState.vehicleId = vehicleId;
      await _storageService.saveAppState(appState);

      // Start foreground task
      final result = await FlutterForegroundTask.startService(
        notificationTitle: _notificationTitle,
        notificationText: _notificationText,
        callback: startCallback,
      );

      if (result is ServiceRequestSuccess) {
        developer.log(
          'SERVICE_STARTED: name=$name, vehicleId=$vehicleId, startTime=$startTime',
        );
        return true;
      } else {
        // Rollback state if service start failed
        appState.isServiceRunning = false;
        appState.startEventTime = null;
        appState.driverName = null;
        appState.vehicleId = null;
        await _storageService.saveAppState(appState);
        return false;
      }
    } catch (e) {
      developer.log('SERVICE_START_ERROR error: $e', level: 1000, error: e);
      return false;
    }
  }

  Future<bool> stopService() async {
    try {
      final isServiceRunning = await FlutterForegroundTask.isRunningService;
      if (!isServiceRunning) {
        developer.log('SERVICE_NOT_RUNNING');
        // Still try to export CSV if there's data
        await _exportCsvAndCleanup();
        return true;
      }

      // Stop foreground task first
      final result = await FlutterForegroundTask.stopService();

      if (result is ServiceRequestSuccess) {
        // Export CSV and cleanup
        await _exportCsvAndCleanup();

        // Update app state
        var appState = await _storageService.getAppState();
        appState.isServiceRunning = false;
        appState.startEventTime = null;
        appState.driverName = null;
        appState.vehicleId = null;
        await _storageService.saveAppState(appState);

        developer.log('SERVICE_STOPPED');
        return true;
      }

      return false;
    } catch (e) {
      developer.log('SERVICE_STOP_ERROR error: $e', level: 1000, error: e);
      return false;
    }
  }

  Future<void> _exportCsvAndCleanup() async {
    try {
      final entries = await _storageService.getAllStepLogEntries();
      if (entries.isEmpty) {
        developer.log('NO_DATA_TO_EXPORT');
        return;
      }

      // Get today's date for filename
      final today = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(today);
      final fileName = '${dateStr}_driver_steps.csv';

      // Get documents directory
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');

      // Write CSV header
      final csvContent = StringBuffer();
      csvContent.writeln('time,step_number,name,vehicle_id');

      // Write data rows
      for (final entry in entries) {
        final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(entry.time);
        csvContent.writeln(
          '$timeStr,${entry.stepNumber},${entry.name},${entry.vehicleId}',
        );
      }

      // Write to file
      await file.writeAsString(csvContent.toString());
      developer.log(
        'CSV_EXPORTED: $fileName, entries=${entries.length}, path=${file.path}',
      );

      // Clear database after export
      await _storageService.clearAllStepLogEntries();
      developer.log('DATABASE_CLEARED');
    } catch (e) {
      developer.log('EXPORT_CSV_ERROR: $e', level: 1000, error: e);
    }
  }

  Future<void> _cleanOldCsvFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir.listSync();
      final now = DateTime.now();
      final threeDaysAgo = now.subtract(const Duration(days: 3));

      int deletedCount = 0;
      for (final file in files) {
        if (file is File && file.path.endsWith('_driver_steps.csv')) {
          final stat = await file.stat();
          if (stat.modified.isBefore(threeDaysAgo)) {
            await file.delete();
            deletedCount++;
            developer.log('DELETED_OLD_CSV: ${file.path}');
          }
        }
      }

      if (deletedCount > 0) {
        developer.log('CLEANED_OLD_CSV_FILES: count=$deletedCount');
      }
    } catch (e) {
      developer.log('CLEAN_OLD_CSV_ERROR: $e', level: 1000, error: e);
    }
  }
}

@pragma('vm:entry-point')
Future<void> startCallback() async {
  FlutterForegroundTask.setTaskHandler(StepCounterTaskHandler());
}

class StepCounterTaskHandler extends TaskHandler {
  Timer? _periodicTimer;
  final _storageService = StorageService.instance;
  final _pedoInstance = Pedometer();
  DateTime? _startTime;
  String? _driverName;
  String? _vehicleId;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    developer.log('SERVICE_START: timestamp=$timestamp');
    await _storageService.initialize();

    // Get start time and driver info from app state
    final appState = await _storageService.getAppState();
    _startTime = appState.startEventTime;
    _driverName = appState.driverName;
    _vehicleId = appState.vehicleId;

    if (_startTime == null || _driverName == null || _vehicleId == null) {
      developer.log(
        'MISSING_START_INFO: $_startTime | $_driverName | $_vehicleId',
      );
      return;
    }

    // Start periodic timer (30 seconds)
    _periodicTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _logStepCount();
    });

    // Log immediately on start
    await _logStepCount();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Not used in simplified flow
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isDestroyed) async {
    developer.log('SERVICE_DESTROY: timestamp=$timestamp');
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  Future<void> _logStepCount() async {
    try {
      if (_startTime == null || _driverName == null || _vehicleId == null) {
        return;
      }

      final now = DateTime.now();
      // Get step count from start time to now
      final totalStepCount = await _pedoInstance.getStepCount(
        from: DateTime(now.year, now.month, now.day),
        to: now.add(const Duration(days: 1, seconds: -1)),
      );

      // Get step count from start time to now
      final stepCount = await _pedoInstance.getStepCount(
        from: _startTime,
        to: now.add(const Duration(days: 1, seconds: -1)),
      );

      developer.log('totalStepCount: $totalStepCount');
      developer.log('stepCount: $stepCount');

      // Create log entry
      final entry = StepLogEntry()
        ..time = now
        ..stepNumber = stepCount
        ..name = _driverName!
        ..vehicleId = _vehicleId!;

      // Save to database
      await _storageService.addStepLogEntry(entry);

      // Update notification
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Step Counter Active',
        notificationText:
            '${NumberFormat('#,###').format(stepCount)} steps • Last: ${_formatTime(now)}',
      );

      developer.log(
        'STEP_LOGGED: $now | $stepCount | $_driverName | $_vehicleId',
      );
    } catch (e) {
      developer.log('LOG_STEP_COUNT_ERROR: $e', level: 1000, error: e);
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer_2/pedometer_2.dart';
import 'package:intl/intl.dart';
import '../models/step_record.dart';
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
          autoRunOnBoot: true,
          allowWakeLock: true,
          allowWifiLock: false,
        ),
      );

      await _autoStartWhenKill();
      await _updatePreviousStep();
      await _updateMissDailyRecord();
      developer.log('SERVICE_INITIALIZED running');
    } catch (e) {
      developer.log('SERVICE_INIT_ERROR error: $e', level: 1000, error: e);
      rethrow;
    }
  }

  Future<void> _autoStartWhenKill() async {
    try {
      final isServiceRunning = await FlutterForegroundTask.isRunningService;
      var appState = await _storageService.getAppState();
      // Service is not running, do nothing
      if (appState.isServiceRunning == false) {
        return;
        // Service is running, do nothing
      } else if (appState.isServiceRunning && isServiceRunning) {
        return;
        // Kill service need to restart
      } else if (appState.isServiceRunning) {
        // reset app state
        appState = appState..isServiceRunning = false;
        await _storageService.saveAppState(appState);
        // restart service
        await startService();
      }
    } catch (e) {
      developer.log('AUTO_START_WHEN_KILL_ERROR: $e', level: 1000, error: e);
    }
  }

  Future<void> _updatePreviousStep() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    var record = await _storageService.getPreviousStepRecord(todayDate);
    if (record == null || record.date.isAtSameMomentAs(todayDate)) return;
    final prevDate = record.date;
    final steps = await Pedometer().getStepCount(
      from: prevDate,
      // end of day
      to: prevDate.copyWith(hour: 23, minute: 59, second: 59, millisecond: 999),
    );
    if (steps < (record.steps ?? 0)) return;
    record = record..steps = steps;
    await _storageService.addDailyStepRecord(record);
  }

  Future<void> _updateMissDailyRecord() async {
    final appState = await _storageService.getAppState();
    final startEventTime = appState.startEventTime;
    if (startEventTime == null) return;

    try {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      final twoWeeksAgo = todayDate.subtract(const Duration(days: 14));

      final startDate = DateTime(
        startEventTime.year,
        startEventTime.month,
        startEventTime.day,
      );

      final effectiveStartDate = startDate.isAfter(twoWeeksAgo)
          ? startDate
          : twoWeeksAgo;

      if (effectiveStartDate.isAtSameMomentAs(todayDate)) return;

      final existingRecords = await _storageService.getStepRecordsByDateRange(
        effectiveStartDate,
        todayDate,
      );

      final existingDates = existingRecords.map((record) {
        return DateTime(record.date.year, record.date.month, record.date.day);
      }).toSet();

      final missingDates = <DateTime>[];
      DateTime currentDate = effectiveStartDate;

      while (currentDate.isBefore(todayDate)) {
        if (!existingDates.contains(currentDate)) missingDates.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }

      if (missingDates.isEmpty) return;

      developer.log('MISSING_DATES_FOUND: ${missingDates.length} days');

      final pedoInstance = Pedometer();

      for (final missingDate in missingDates) {
        try {
          final startOfDay = missingDate;
          final endOfDay = DateTime(
            missingDate.year,
            missingDate.month,
            missingDate.day,
            23,
            59,
            59,
            999,
          );

          final steps = await pedoInstance.getStepCount(
            from: startOfDay,
            to: endOfDay,
          );

          final newRecord = DailyStepRecord()
            ..date = missingDate
            ..steps = steps
            ..lastUpdateTime = DateTime.now();

          await _storageService.addDailyStepRecord(newRecord);
        } catch (e) {
          developer.log(
            'ERROR_RECOVERING_DATE: ${DateFormat('yyyy-MM-dd').format(missingDate)} - $e',
            level: 1000,
            error: e,
          );
        }
      }
    } catch (e) {
      developer.log(
        'UPDATE_MISS_DAILY_RECORD_ERROR: $e',
        level: 1000,
        error: e,
      );
    }
  }

  Future<bool> _validateServiceState() async {
    try {
      final isServiceRunning = await FlutterForegroundTask.isRunningService;
      var appState = await _storageService.getAppState();
      if (appState.isServiceRunning && isServiceRunning) return true;
      await _storageService.saveAppState(
        appState..isServiceRunning = isServiceRunning,
      );
      await FlutterForegroundTask.stopService();
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> startService() async {
    try {
      final isValid = await _validateServiceState();
      if (isValid) {
        developer.log('SERVICE_ALREADY_RUNNING');
        return true;
      }

      // Start foreground task
      final result = await FlutterForegroundTask.startService(
        notificationTitle: _notificationTitle,
        notificationText: _notificationText,
        callback: startCallback,
      );

      if (result is ServiceRequestSuccess) {
        // Save new app state - Service layer manages its own state
        var newState = await _storageService.getAppState();
        newState = newState..isServiceRunning = true;
        if (newState.startEventTime == null) {
          newState = newState..startEventTime = DateTime.now();
        }
        await _storageService.saveAppState(newState);

        developer.log('SERVICE_STARTED');
      }

      return result is ServiceRequestSuccess;
    } catch (e) {
      developer.log('SERVICE_START_ERROR error: $e', level: 1000, error: e);
      return false;
    }
  }

  Future<bool> stopService() async {
    try {
      final isValid = await _validateServiceState();
      if (!isValid) {
        developer.log('SERVICE_NOT_RUNNING');
        return true;
      }

      // Stop foreground task
      final result = await FlutterForegroundTask.stopService();

      if (result is ServiceRequestSuccess) {
        // Update app state
        var appState = await _storageService.getAppState();
        appState = appState..isServiceRunning = false;
        await _storageService.saveAppState(appState);
        developer.log('SERVICE_STOPPED');
      }

      return result is ServiceRequestSuccess;
    } catch (e) {
      developer.log('SERVICE_STOP_ERROR error: $e', level: 1000, error: e);
      return false;
    }
  }
}

@pragma('vm:entry-point')
Future<void> startCallback() async {
  FlutterForegroundTask.setTaskHandler(StepCounterTaskHandler());
}

class StepCounterTaskHandler extends TaskHandler {
  StreamSubscription? _stepSubscription;
  int _lastDeviceSteps = 0;
  final _storageService = StorageService.instance;

  // Date tracking
  DateTime? _currentTrackingDate;

  // Debounce variables
  Timer? _debounceTimer;
  int _callCounter = 0;
  static const int _maxCallsBeforeForce = 5;
  static const Duration _debounceDuration = Duration(milliseconds: 350);

  // Processing flag to prevent race condition
  bool _isProcessing = false;
  bool _hasPendingUpdate = false; // Flag to track pending update

  final pedoInstance = Pedometer();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    developer.log('SERVICE_START: name: $starter');
    await _storageService.initialize();
    await _updateServiceState(true);
    await _beginBackgroundStepCounting();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isDestroyed) async {
    // Cancel pedometer subscription if active
    await _stepSubscription?.cancel();
    _stepSubscription = null;
    // Cancel debounce timer if active
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  Future<void> _updateServiceState(bool isRunning) async {
    var appState = await _storageService.getAppState();
    appState = appState..isServiceRunning = isRunning;
    if (appState.startEventTime == null) {
      appState = appState..startEventTime = DateTime.now();
    }
    await _storageService.saveAppState(appState);
  }

  DateTime _convertDayToKey(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _beginBackgroundStepCounting() async {
    try {
      final todayDate = _convertDayToKey(DateTime.now());
      _currentTrackingDate = todayDate;

      if (Platform.isIOS) {
        _listenerIOS();
      } else if (Platform.isAndroid) {
        _listenerAndroid();
      }
    } catch (e) {
      developer.log('STEP_COUNTING_ERROR_BG error: $e', level: 1000, error: e);
    }
  }

  Future<void> _finalizeOldDay(DateTime date) async {
    final endOfOldDay = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
      999,
    );

    final finalSteps = await pedoInstance.getStepCount(
      from: date,
      to: endOfOldDay,
    );

    final oldDayRecord = await _storageService.getTodayRecord(date);
    final finalizedRecord = oldDayRecord
      ..steps = finalSteps
      ..lastUpdateTime = DateTime.now();
    await _storageService.addDailyStepRecord(finalizedRecord);

    _lastDeviceSteps = 0;
  }

  void _listenerAndroid() {
    _stepSubscription = pedoInstance.stepCountStream().listen(
      (_) async {
        // If processing, mark as pending and return
        if (_isProcessing) {
          _hasPendingUpdate = true;
          return;
        }

        try {
          _callCounter++;
          final shouldForceUpdate = _callCounter >= _maxCallsBeforeForce;
          _debounceTimer?.cancel();

          if (shouldForceUpdate) {
            // Force update immediately after 5 calls
            _callCounter = 0;
            await _processStepUpdate();
          } else {
            // Debounce: wait 350ms without new event before updating
            _debounceTimer = Timer(_debounceDuration, () async {
              _callCounter = 0;
              await _processStepUpdate();
            });
          }
        } catch (e) {
          developer.log('PEDOMETER_LISTENER_ERROR: $e', level: 1000, error: e);
          _isProcessing = false;
          _hasPendingUpdate = false;
        }
      },
      onError: (error) {
        developer.log('PEDOMETER_STREAM_ERROR: ${error.toString()}');
      },
      cancelOnError: false,
    );
  }

  Future<void> _processStepUpdate({
    int? stepsFromStream,
    Future<void> Function()? onDateChanged,
  }) async {
    if (_isProcessing) return;
    if (_currentTrackingDate == null) return;

    _isProcessing = true;
    _hasPendingUpdate = false; // Reset pending flag when starting to process

    try {
      // Check for date change
      final todayKey = _convertDayToKey(DateTime.now());
      if (!_currentTrackingDate!.isAtSameMomentAs(todayKey)) {
        // Date changed - finalize old day
        await _finalizeOldDay(_currentTrackingDate!);
        _currentTrackingDate = todayKey;

        // iOS: restart listener, Android: just continue
        if (onDateChanged != null) {
          await onDateChanged();
          return;
        }
      }

      // Get steps: from stream (iOS) or query sensor (Android)
      final steps =
          stepsFromStream ??
          await pedoInstance.getStepCount(
            from: _currentTrackingDate!,
            to: DateTime.now(),
          );

      await _handleDailyStepChange(steps, _currentTrackingDate!);
    } catch (e) {
      developer.log('PROCESS_STEP_UPDATE_ERROR: $e', level: 1000, error: e);
    } finally {
      _isProcessing = false;

      // If there is pending update while processing, process again immediately
      if (!_hasPendingUpdate) return;
      _hasPendingUpdate = false;

      // Call again to process latest data
      // iOS: use _lastDeviceSteps, Android: query again
      await _processStepUpdate(
        stepsFromStream: stepsFromStream != null ? _lastDeviceSteps : null,
        onDateChanged: onDateChanged,
      );
    }
  }

  void _listenerIOS() {
    if (_currentTrackingDate == null) return;

    _stepSubscription = pedoInstance
        .stepCountStreamFrom(from: _currentTrackingDate!)
        .listen(
          (steps) async {
            // If processing, mark as pending and return
            if (_isProcessing) {
              _hasPendingUpdate = true;
              return;
            }

            try {
              await _processStepUpdate(
                stepsFromStream: steps,
                onDateChanged: () async {
                  // Restart listener with new date
                  await _stepSubscription?.cancel();
                  _listenerIOS();
                },
              );
            } catch (e) {
              developer.log(
                'PEDOMETER_LISTENER_ERROR: $e',
                level: 1000,
                error: e,
              );
              _isProcessing = false;
              _hasPendingUpdate = false;
            }
          },
          onError: (error) {
            developer.log('PEDOMETER_STREAM_ERROR: ${error.toString()}');
          },
          cancelOnError: false,
        );
  }

  Future<void> _handleDailyStepChange(int deviceSteps, DateTime date) async {
    try {
      final todayRecord = await _storageService.getTodayRecord(date);

      if (deviceSteps < todayRecord.stepsCount) return;
      final updatedRecord = todayRecord
        ..steps = deviceSteps
        ..lastUpdateTime = DateTime.now();
      await _storageService.addDailyStepRecord(updatedRecord);
      await _updateNotification(deviceSteps);
    } catch (e) {
      developer.log('STEP_HANDLE_ERROR_BG error: $e deviceSteps: $deviceSteps');
    }
  }

  Future<void> _updateNotification(int steps) async {
    try {
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Step Counter Active',
        notificationText:
            '${NumberFormat('#,###').format(steps)} steps today • Last: ${_formatTime(DateTime.now())}',
      );
    } catch (e) {
      developer.log('NOTIFICATION_UPDATE_ERROR_BG error: $e');
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

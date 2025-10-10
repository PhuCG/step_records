import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer_2/pedometer_2.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/step_record.dart';
import '../models/app_state.dart';
import '../models/session.dart';
import 'storage_service.dart';
import 'permission_service.dart';

class StepCounterService {
  static final StepCounterService _instance = StepCounterService._internal();
  static StepCounterService get instance => _instance;
  StepCounterService._internal();

  static const String _notificationTitle = 'Step Counter Active';
  static const String _notificationText = 'Counting your steps...';

  StreamSubscription? _stepSubscription;
  DateTime? _lastResetDate;
  String _currentSessionId = '';
  bool _isServiceRunning = false;

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
          showNotification: true,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(5000), // 5 seconds
          autoRunOnBoot: true,
          allowWakeLock: true,
          allowWifiLock: false,
        ),
      );

      await validateServiceState();
      developer.log('SERVICE_INITIALIZED running: $_isServiceRunning');
    } catch (e) {
      developer.log('SERVICE_INIT_ERROR error: $e', level: 1000, error: e);
      rethrow;
    }
  }

  // Validate service state on app startup
  Future<void> validateServiceState() async {
    try {
      // Check if FlutterForegroundTask service is actually running
      final isServiceRunning = await FlutterForegroundTask.isRunningService;

      // Get current local state
      final appState = await StorageService.instance.getAppState();

      // Sync local state with actual service status
      if (appState.isServiceRunning != isServiceRunning) {
        await StorageService.instance.saveAppState(
          AppState(
            serviceStartTime: appState.serviceStartTime,
            currentSessionId: appState.currentSessionId,
            isServiceRunning: isServiceRunning,
            lastUpdateTime: DateTime.now(),
            lastDateReset: appState.lastDateReset,
          ),
        );

        developer.log(
          'SERVICE_STATE_SYNC: localState=${appState.isServiceRunning} || actualState=$isServiceRunning || name: StepCounter',
        );

        // If local state says service should be running but it's not,
        // it means user force-killed the app - auto-restart service
        if (appState.isServiceRunning && !isServiceRunning) {
          await _autoRestartService();
        }
      }

      _isServiceRunning = isServiceRunning;
    } catch (e) {
      developer.log(
        'SERVICE_STATE_VALIDATION_ERROR error: $e',
        level: 1000,
        error: e,
      );
    }
  }

  // Auto-restart service when user force-killed the app
  Future<void> _autoRestartService() async {
    try {
      // Check if we have necessary permissions
      final hasPermissions = await PermissionService.instance
          .checkAllPermissions();
      if (!hasPermissions) {
        // Show notification asking user to grant permissions
        await _showPermissionRequiredNotification();
        developer.log(
          'SERVICE_AUTO_RESTART_FAILED: reason=permissions_denied || timestamp=${DateTime.now().toIso8601String()} || name: StepCounter',
        );
        return;
      }

      // Start the service again
      await FlutterForegroundTask.startService(
        notificationTitle: 'Step Counter Active',
        notificationText: 'Service restarted after app was killed',
        callback: startCallback,
      );

      // Log the auto-restart event
      developer.log(
        'SERVICE_AUTO_RESTART: reason=force_kill_detected || timestamp=${DateTime.now().toIso8601String()} || name: StepCounter',
      );
    } catch (e) {
      // If auto-restart fails, show notification to user
      await _showServiceRestartFailedNotification();
      developer.log(
        'SERVICE_AUTO_RESTART_FAILED: error=${e.toString()} || timestamp=${DateTime.now().toIso8601String()} || name: StepCounter',
        level: 1000,
        error: e,
      );
    }
  }

  Future<void> _showPermissionRequiredNotification() async {
    try {
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Step Counter - Permission Required',
        notificationText: 'Please grant permissions to continue step counting',
      );
    } catch (e) {
      developer.log('NOTIFICATION_ERROR: $e');
    }
  }

  Future<void> _showServiceRestartFailedNotification() async {
    try {
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Step Counter - Restart Failed',
        notificationText: 'Please open the app to restart step counting',
      );
    } catch (e) {
      developer.log('NOTIFICATION_ERROR: $e');
    }
  }

  Future<bool> startService() async {
    try {
      await validateServiceState();
      if (_isServiceRunning) {
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
        _isServiceRunning = true;
        _currentSessionId = const Uuid().v4();

        // Create new session
        final session = Session(
          sessionId: _currentSessionId,
          startTime: DateTime.now(),
          startSteps: 0,
          endSteps: 0,
          totalSteps: 0,
        );
        await StorageService.instance.addSession(session);

        // Save new app state
        final newState = AppState(
          serviceStartTime: DateTime.now(),
          currentSessionId: _currentSessionId,
          isServiceRunning: true,
          lastUpdateTime: DateTime.now(),
        );
        await StorageService.instance.saveAppState(newState);

        // Start step counting
        await _startStepCounting();

        developer.log('SERVICE_STARTED session_id: $_currentSessionId');
      }

      return result is ServiceRequestSuccess;
    } catch (e) {
      developer.log('SERVICE_START_ERROR error: $e', level: 1000, error: e);
      return false;
    }
  }

  Future<bool> stopService() async {
    try {
      await validateServiceState();
      if (!_isServiceRunning) {
        developer.log('SERVICE_NOT_RUNNING');
        return true;
      }

      // Stop step counting
      await _stepSubscription?.cancel();
      _stepSubscription = null;

      // End current session
      final latestSession = await StorageService.instance.getLatestSession();
      if (latestSession != null && latestSession.endTime == null) {
        final updatedSession = Session(
          sessionId: latestSession.sessionId,
          startTime: latestSession.startTime,
          endTime: DateTime.now(),
          startSteps: latestSession.startSteps,
          endSteps: latestSession.endSteps,
          totalSteps: latestSession.totalSteps,
          endReason: 'USER_STOP',
        );
        await StorageService.instance.addSession(updatedSession);
      }

      // Stop foreground task
      final result = await FlutterForegroundTask.stopService();

      if (result is ServiceRequestSuccess) {
        _isServiceRunning = false;

        // Update app state
        final appState = await StorageService.instance.getAppState();
        final updatedState = AppState(
          serviceStartTime: appState.serviceStartTime,
          currentSessionId: '',
          isServiceRunning: false,
          lastUpdateTime: DateTime.now(),
          lastDateReset: appState.lastDateReset,
        );
        await StorageService.instance.saveAppState(updatedState);

        developer.log('SERVICE_STOPPED session_id: $_currentSessionId');
      }

      return result is ServiceRequestSuccess;
    } catch (e) {
      developer.log('SERVICE_STOP_ERROR error: $e', level: 1000, error: e);
      return false;
    }
  }

  Future<void> _startStepCounting() async {
    try {
      // Get today's date for daily tracking
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Check if we need to reset daily counter
      if (_lastResetDate == null || !_isSameDay(_lastResetDate!, todayDate)) {
        await _resetDailyCounter(todayDate);
      }

      // Listen to daily step count stream from today
      if (Platform.isAndroid) {
        _stepSubscription = Pedometer().stepCountStream().listen(
          (steps) async {
            await _handleDailyStepChange(steps, todayDate);
          },
          onError: (error) {
            developer.log(
              'PEDOMETER_ERROR: ${error.toString()} || timestamp=${DateTime.now().toIso8601String()} || name: StepCounter',
              level: 1000,
              error: error,
            );
            _handlePedometerError(error);
          },
          cancelOnError: false, // Continue on errors
        );
      } else {
        _stepSubscription = Pedometer()
            .stepCountStreamFrom(from: todayDate)
            .listen(
              (steps) async {
                await _handleDailyStepChange(steps, todayDate);
              },
              onError: (error) {
                developer.log(
                  'PEDOMETER_ERROR: ${error.toString()} || timestamp=${DateTime.now().toIso8601String()} || name: StepCounter',
                  level: 1000,
                  error: error,
                );
                _handlePedometerError(error);
              },
              cancelOnError: false, // Continue on errors
            );
      }
      developer.log('STEP_COUNTING_STARTED');
    } catch (e) {
      developer.log('STEP_COUNTING_ERROR error: $e', level: 1000, error: e);
    }
  }

  Future<void> _handleDailyStepChange(int steps, DateTime date) async {
    try {
      // Get or create today's record
      final todayRecord = await StorageService.instance.getOrCreateTodayRecord(
        _currentSessionId,
      );

      // Calculate delta from last known steps
      final delta = steps - todayRecord.lastKnownSteps;

      if (delta > 0) {
        // Update today's step count
        final updatedRecord = DailyStepRecord(
          date: todayRecord.date,
          steps: todayRecord.steps + delta,
          lastKnownSteps: steps,
          lastUpdateTime: DateTime.now(),
          sessionId: _currentSessionId,
          synced: todayRecord.synced,
        );

        // Save to Isar with reactive updates
        await StorageService.instance.addDailyStepRecord(updatedRecord);

        // Update notification every 7 steps to save battery
        if (updatedRecord.steps % 7 == 0) {
          await _updateNotification(updatedRecord.steps);
        }

        // Log the step change
        developer.log(
          'DAILY_STEP_CHANGE: steps=$steps || delta=$delta || date=${date.toIso8601String().split('T')[0]} || name: StepCounter',
        );
      }
    } catch (e) {
      developer.log(
        'STEP_HANDLE_ERROR error: $e steps: $steps',
        level: 1000,
        error: e,
      );
    }
  }

  Future<void> _resetDailyCounter(DateTime todayDate) async {
    try {
      _lastResetDate = todayDate;

      // Update app state with new reset date
      final appState = await StorageService.instance.getAppState();
      final updatedState = AppState(
        serviceStartTime: appState.serviceStartTime,
        currentSessionId: appState.currentSessionId,
        isServiceRunning: appState.isServiceRunning,
        lastUpdateTime: DateTime.now(),
        lastDateReset: todayDate,
      );
      await StorageService.instance.saveAppState(updatedState);

      developer.log(
        'DAILY_RESET: date=${todayDate.toIso8601String().split('T')[0]} || name: StepCounter',
      );
    } catch (e) {
      developer.log('DAILY_RESET_ERROR error: $e', level: 1000, error: e);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _handlePedometerError(dynamic error) {
    // Handle pedometer errors gracefully
    developer.log('PEDOMETER_ERROR_HANDLED: $error');
  }

  Future<void> _updateNotification(int steps) async {
    try {
      FlutterForegroundTask.updateService(
        notificationTitle: 'Step Counter Active',
        notificationText:
            '${NumberFormat('#,###').format(steps)} steps today • Last: ${_formatTime(DateTime.now())}',
      );
    } catch (e) {
      developer.log('NOTIFICATION_UPDATE_ERROR error: $e');
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool get isServiceRunning => _isServiceRunning;
  String get currentSessionId => _currentSessionId;
}

@pragma('vm:entry-point')
Future<void> startCallback() async {
  FlutterForegroundTask.setTaskHandler(StepCounterTaskHandler());
}

class StepCounterTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Service started - update local state
    await _updateServiceState(true);
    developer.log(
      'SERVICE_START: timestamp=${timestamp.toIso8601String()} || name: StepCounter',
    );
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // This will be called every 5 seconds
    // The main step counting logic is handled in the main service
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isDestroyed) async {
    // Service destroyed - update local state
    await _updateServiceState(false);
    developer.log(
      'SERVICE_DESTROY: timestamp=${timestamp.toIso8601String()} || name: StepCounter',
    );
  }

  Future<void> _updateServiceState(bool isRunning) async {
    try {
      final appState = await StorageService.instance.getAppState();
      final updatedState = AppState(
        serviceStartTime: isRunning
            ? DateTime.now()
            : appState.serviceStartTime,
        currentSessionId: isRunning ? const Uuid().v4() : '',
        isServiceRunning: isRunning,
        lastUpdateTime: DateTime.now(),
        lastDateReset: appState.lastDateReset,
      );
      await StorageService.instance.saveAppState(updatedState);
    } catch (e) {
      developer.log('SERVICE_STATE_UPDATE_ERROR: $e', level: 1000, error: e);
    }
  }
}

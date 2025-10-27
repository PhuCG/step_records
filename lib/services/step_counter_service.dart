import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer_2/pedometer_2.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import 'storage_service.dart';

class StepCounterService {
  static final StepCounterService _instance = StepCounterService._internal();
  static StepCounterService get instance => _instance;
  StepCounterService._internal();

  static const String _notificationTitle = 'Step Counter Active';
  static const String _notificationText = 'Counting your steps...';

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

      await _validateServiceState();
      developer.log('SERVICE_INITIALIZED running');
    } catch (e) {
      developer.log('SERVICE_INIT_ERROR error: $e', level: 1000, error: e);
      rethrow;
    }
  }

  Future<bool> _validateServiceState() async {
    try {
      final isServiceRunning = await FlutterForegroundTask.isRunningService;
      var appState = await StorageService.instance.getAppState();
      if (appState.isServiceRunning && isServiceRunning) return true;
      await StorageService.instance.saveAppState(
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
        var newState = await StorageService.instance.getAppState();
        newState = newState..isServiceRunning = true;
        if (newState.startEventTime == null) {
          newState = newState..startEventTime = DateTime.now();
        }
        await StorageService.instance.saveAppState(newState);

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
        final updatedState = AppState()..isServiceRunning = false;
        await StorageService.instance.saveAppState(updatedState);
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

  // Debounce với counter
  Timer? _debounceTimer;
  int _callCounter = 0;
  static const int _maxCallsBeforeForce = 5;
  static const Duration _debounceDuration = Duration(seconds: 2);

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
    // Service destroyed - update local state
    await _updateOnDestroy();
    await _updateServiceState(false);
    // Cancel pedometer subscription if active
    await _stepSubscription?.cancel();
    _stepSubscription = null;
    // Cancel debounce timer if active
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  Future<void> _updateServiceState(bool isRunning) async {
    final updatedState = AppState()..isServiceRunning = isRunning;
    await _storageService.saveAppState(updatedState);
  }

  Future<void> _updateOnDestroy() async {
    try {
      final dateKey = _convertDayToKey(DateTime.now());
      final lastStepRecord = await _storageService.getLastStepRecord(dateKey);

      if (lastStepRecord == null) return;

      final updatedRecord = lastStepRecord
        ..steps = _lastDeviceSteps
        ..lastUpdateTime = DateTime.now();

      await _storageService.addDailyStepRecord(updatedRecord);
    } catch (e) {
      developer.log('LAST_STEP_COUNT_UPDATE_ERROR: $e', level: 1000, error: e);
    }
  }

  DateTime _convertDayToKey(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _beginBackgroundStepCounting() async {
    try {
      final todayDate = _convertDayToKey(DateTime.now());

      if (Platform.isIOS) {
        _listenerIOS(todayDate);
      } else if (Platform.isAndroid) {
        _listenerAndroid(todayDate);
      }
    } catch (e) {
      developer.log('STEP_COUNTING_ERROR_BG error: $e', level: 1000, error: e);
    }
  }

  void _listenerAndroid(DateTime todayDate) {
    _stepSubscription = pedoInstance.stepCountStream().listen(
      (_) async {
        _callCounter++;
        final shouldForceUpdate = _callCounter >= _maxCallsBeforeForce;

        _debounceTimer?.cancel();

        if (shouldForceUpdate) {
          _callCounter = 0;
          final steps = await pedoInstance.getStepCount(
            from: todayDate,
            to: DateTime.now(),
          );
          _lastDeviceSteps = steps;
          await _handleDailyStepChange(steps, todayDate);
        } else {
          _debounceTimer = Timer(_debounceDuration, () async {
            final steps = await pedoInstance.getStepCount(
              from: todayDate,
              to: DateTime.now(),
            );
            _lastDeviceSteps = steps;
            _callCounter = 0;
            await _handleDailyStepChange(steps, todayDate);
          });
        }
      },

      onError: (error) {
        developer.log('PEDOMETER_ERROR: ${error.toString()} ');
      },
      cancelOnError: false,
    );
  }

  void _listenerIOS(DateTime todayDate) {
    _stepSubscription = pedoInstance
        .stepCountStreamFrom(from: todayDate)
        .listen(
          (steps) async {
            developer.log('PEDOMETER_STEP_COUNT: $steps');
            _lastDeviceSteps = steps;
            await _handleDailyStepChange(steps, todayDate);
          },
          onError: (error) {
            developer.log('PEDOMETER_ERROR: ${error.toString()} ');
          },
          cancelOnError: false,
        );
  }

  Future<void> _handleDailyStepChange(int deviceSteps, DateTime date) async {
    try {
      final todayRecord = await _storageService.getTodayRecord(date);

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

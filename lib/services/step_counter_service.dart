import 'dart:async';
import 'dart:developer';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer_2/pedometer_2.dart';
import 'package:uuid/uuid.dart';
import '../models/step_record.dart';
import '../models/app_state.dart';
import 'storage_service.dart';
import 'logger.dart';

class StepCounterService {
  static final StepCounterService _instance = StepCounterService._internal();
  static StepCounterService get instance => _instance;
  StepCounterService._internal();

  static const String _notificationTitle = 'Step Counter Active';
  static const String _notificationText = 'Counting your steps...';

  StreamSubscription? _stepSubscription;
  int _currentSteps = 0;
  int _lastKnownSteps = 0;
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

      await Logger.info('SERVICE_INITIALIZED', {});
    } catch (e) {
      await Logger.error('SERVICE_INIT_ERROR', {'error': e.toString()});
      rethrow;
    }
  }

  Future<bool> startService() async {
    try {
      if (_isServiceRunning) {
        await Logger.warn('SERVICE_ALREADY_RUNNING', {});
        return true;
      }

      // Start foreground task
      final result = await FlutterForegroundTask.startService(
        notificationTitle: _notificationTitle,
        notificationText: _notificationText,
        callback: _startCallback,
      );

      if (result is ServiceRequestSuccess) {
        _isServiceRunning = true;
        _currentSessionId = const Uuid().v4();

        // Load last known state
        final appState = await StorageService.instance.getAppState();
        _lastKnownSteps = appState.lastKnownSteps;
        _currentSteps = _lastKnownSteps;

        // Save new app state
        final newState = AppState(
          serviceStartTime: DateTime.now(),
          lastKnownSteps: _currentSteps,
          currentSessionId: _currentSessionId,
          isServiceRunning: true,
          lastUpdateTime: DateTime.now(),
        );
        await StorageService.instance.saveAppState(newState);

        // Start step counting
        await _startStepCounting();

        await Logger.info('SERVICE_STARTED', {
          'session_id': _currentSessionId,
          'last_known_steps': _lastKnownSteps,
        });
      }

      return result is ServiceRequestSuccess;
    } catch (e) {
      await Logger.error('SERVICE_START_ERROR', {'error': e.toString()});
      return false;
    }
  }

  Future<bool> stopService() async {
    try {
      if (!_isServiceRunning) {
        await Logger.warn('SERVICE_NOT_RUNNING', {});
        return true;
      }

      // Stop step counting
      await _stepSubscription?.cancel();
      _stepSubscription = null;

      // Stop foreground task
      final result = await FlutterForegroundTask.stopService();

      if (result is ServiceRequestSuccess) {
        _isServiceRunning = false;

        // Update app state
        final appState = await StorageService.instance.getAppState();
        final updatedState = AppState(
          serviceStartTime: appState.serviceStartTime,
          lastKnownSteps: _currentSteps,
          currentSessionId: _currentSessionId,
          isServiceRunning: false,
          lastUpdateTime: DateTime.now(),
        );
        await StorageService.instance.saveAppState(updatedState);

        await Logger.info('SERVICE_STOPPED', {
          'session_id': _currentSessionId,
          'final_steps': _currentSteps,
        });
      }

      return result is ServiceRequestSuccess;
    } catch (e) {
      await Logger.error('SERVICE_STOP_ERROR', {'error': e.toString()});
      return false;
    }
  }

  Future<void> _startStepCounting() async {
    try {
      final pedometer = Pedometer();
      final stepStream = pedometer.stepCountStream;

      _stepSubscription = stepStream().listen(
        (event) async {
          log('message $event');
          // Handle step count event

          await _handleStepChange(event);
        },
        onError: (error) async {
          await Logger.error('PEDOMETER_ERROR', {'error': error.toString()});
        },
        cancelOnError: false,
      );

      await Logger.info('STEP_COUNTING_STARTED', {});
    } catch (e) {
      await Logger.error('STEP_COUNTING_ERROR', {'error': e.toString()});
    }
  }

  Future<void> _handleStepChange(int steps) async {
    try {
      final appState = await StorageService.instance.getAppState();
      final lastSteps = appState.lastKnownSteps;
      final delta = steps - lastSteps;

      if (delta > 0) {
        // Create step record
        final record = StepRecord(
          id: const Uuid().v4(),
          steps: steps,
          delta: delta,
          timestamp: DateTime.now(),
          sessionId: appState.currentSessionId,
        );

        // Save step record
        await StorageService.instance.addStepRecord(record);

        // Update app state
        final updatedState = AppState(
          serviceStartTime: appState.serviceStartTime,
          lastKnownSteps: steps,
          currentSessionId: appState.currentSessionId,
          isServiceRunning: true,
          lastUpdateTime: DateTime.now(),
        );
        await StorageService.instance.saveAppState(updatedState);

        // Update current steps
        _currentSteps = steps;

        // Update notification
        await _updateNotification();

        await Logger.debug('STEP_RECORDED', {
          'steps': steps,
          'delta': delta,
          'session_id': appState.currentSessionId,
        });
      }
    } catch (e) {
      await Logger.error('STEP_HANDLE_ERROR', {
        'error': e.toString(),
        'steps': steps,
      });
    }
  }

  Future<void> _updateNotification() async {
    try {
      FlutterForegroundTask.updateService(
        notificationTitle: 'Step Counter Active',
        notificationText:
            '$_currentSteps steps today • Last: ${_formatTime(DateTime.now())}',
      );
    } catch (e) {
      await Logger.error('NOTIFICATION_UPDATE_ERROR', {'error': e.toString()});
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool get isServiceRunning => _isServiceRunning;
  int get currentSteps => _currentSteps;
  String get currentSessionId => _currentSessionId;
}

@pragma('vm:entry-point')
Future<void> _startCallback() async {
  FlutterForegroundTask.setTaskHandler(StepCounterTaskHandler());
}

class StepCounterTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await Logger.info('TASK_HANDLER_START', {
      'timestamp': timestamp.toIso8601String(),
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // This will be called every 5 seconds
    // The main step counting logic is handled in the main service
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    await Logger.info('TASK_HANDLER_DESTROY', {
      'timestamp': timestamp.toIso8601String(),
    });
  }
}

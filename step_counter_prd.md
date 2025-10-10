# Step Counter Demo - Project Requirements Document

## Project Overview

**Project Name:** Step Counter Demo Application  
**Platform:** Flutter (iOS & Android)  
**Version:** 1.0.0 (Demo/POC)  
**Last Updated:** October 9, 2025

### Purpose
Develop a proof-of-concept mobile application that counts user steps continuously when the app is in foreground or background, and logs all activity data locally for analysis. The app uses foreground service to maintain step counting even when the main app is not visible, but may stop when the app is force-killed by the user.

---

## Technical Stack

### Core Dependencies
```yaml
dependencies:
  flutter_foreground_task: ^8.0.0+
  pedometer_2: ^5.0.4
  isar_community: ^3.3.0-dev.3
  isar_community_flutter_libs: ^3.3.0-dev.3
  path_provider: ^2.1.0
  permission_handler: ^11.0.0
  connectivity_plus: ^5.0.0
  device_info_plus: ^9.1.0
  intl: ^0.18.0
  uuid: ^4.4.0

dev_dependencies:
  isar_community_generator: ^3.3.0-dev.3
  build_runner: ^2.4.0
```

### Architecture Pattern
- Clean Architecture with separation of concerns
- Repository pattern for data management
- Service layer for foreground task handling
- Local-first approach (no server integration in demo)

---

## Functional Requirements

### FR-001: Continuous Step Counting
**Priority:** CRITICAL  
**Description:** The application must count user steps continuously when possible using foreground service

**Acceptance Criteria:**
- ✅ Daily steps are counted when app is in foreground
- ✅ Daily steps are counted when app is in background (via foreground service)
- ✅ Daily step counting resumes after phone reboot (if service auto-starts)
- ✅ Daily step count resets at midnight (00:00)
- ✅ Step count accuracy within ±5% of system pedometer
- ✅ UI updates reactively when step count changes
- ⚠️ Service may stop when app is force-killed by user (OS limitation)

**Implementation:**
- Use `flutter_foreground_task` to maintain persistent service
- Use `pedometer_2` with `stepCountStreamFrom()` for daily step tracking
- Use `isar_community` for reactive database updates
- Configure service with `autoRunOnBoot: true`
- Implement daily reset logic at midnight

---

### FR-002: Local Data Logging
**Priority:** HIGH  
**Description:** All step data and events must be logged locally to device storage

**Acceptance Criteria:**
- ✅ Each daily step change is logged with timestamp
- ✅ Service lifecycle events are logged (start, stop, restart)
- ✅ System events are logged (boot, network change, daily reset)
- ✅ Error events are logged with stack traces
- ✅ Database changes trigger reactive UI updates

**Log Format:**
```
SERVICE_START: timestamp=2025-10-09T10:30:45.123Z || name: StepCounter
DAILY_STEP_CHANGE: steps=1234 || delta=10 || date=2025-10-09 || name: StepCounter
PEDOMETER_ERROR: Sensor not available || timestamp=2025-10-09T10:30:45.123Z || name: StepCounter
SERVICE_AUTO_RESTART: reason=force_kill_detected || timestamp=2025-10-09T10:30:45.123Z || name: StepCounter
```

---

### FR-003: Permission Management
**Priority:** CRITICAL  
**Description:** Request and validate all necessary permissions

**Required Permissions:**

**Android:**
- `ACTIVITY_RECOGNITION` - For step counting
- `FOREGROUND_SERVICE` - For persistent service
- `POST_NOTIFICATIONS` - For service notification
- `IGNORE_BATTERY_OPTIMIZATIONS` - Prevent service kill
- `RECEIVE_BOOT_COMPLETED` - Auto-start after reboot

**iOS:**
- `NSMotionUsageDescription` - Access to motion sensors
- `UIBackgroundModes` - Background execution

**Acceptance Criteria:**
- ✅ All permissions requested on first launch
- ✅ User is guided to settings if permissions denied
- ✅ App shows clear explanation for each permission
- ✅ App handles permission denial gracefully
- ✅ Special handling for battery optimization on Android

---

### FR-004: Foreground Service with Notification
**Priority:** CRITICAL  
**Description:** Display persistent notification while service is running

**Notification Requirements:**
- Must show current step count
- Must show service status (active/paused)
- Must show last update timestamp
- Must have action buttons (optional: Pause/Resume, Stop)
- Must be non-dismissible (Android)
- Updates every 7 steps (to save battery)

**Notification Content:**
```
Title: Step Counter Active
Body: 1,234 steps today • Last: 10:30 AM
Icon: App icon
Actions: [Pause] [Stop Service]
```

---

### FR-005: Data Persistence Strategy
**Priority:** HIGH  
**Description:** Store step data and logs efficiently

**Storage Structure:**

**Daily Step Records Table:**
```dart
@collection
class DailyStepRecord {
  Id id = Isar.autoIncrement;
  @Index()
  late DateTime date; // YYYY-MM-DD format for daily tracking
  late int steps; // Steps for this specific day
  late int lastKnownSteps; // Last known step count from pedometer
  @Index()
  late DateTime lastUpdateTime;
  late String sessionId;
  late bool synced; // For future server sync
}
```

**App State:**
```dart
@collection
class AppState {
  Id id = Isar.autoIncrement;
  DateTime? serviceStartTime;
  @Index()
  late String currentSessionId;
  late bool isServiceRunning;
  DateTime? lastUpdateTime;
  late DateTime lastDateReset; // Track when we last reset daily counter
}
```

**Data Retention:**
- Daily reset at midnight (00:00) to start fresh count

---

### FR-006: Service State Synchronization
**Priority:** HIGH  
**Description:** Ensure service state accuracy between foreground service and local database

**Problem Statement:**
When user kills the app, the foreground service may still be running but `isServiceRunning` in local database remains `true`, causing UI to show incorrect status.

**Solution Strategy:**
1. **TaskHandler Lifecycle:** Use `onStart` and `onDestroy` callbacks for service state management
2. **State Validation:** App startup checks actual service status vs local state
3. **Auto-Correction:** Automatically sync local state with actual service status

**Implementation:**
```dart
import 'dart:developer' as developer;

// TaskHandler implementation
class StepCounterTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // Service started - update local state
    await _updateServiceState(true);
    developer.log('SERVICE_START: timestamp=${timestamp.toIso8601String()} || name: StepCounter');
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // Service destroyed - update local state
    await _updateServiceState(false);
    developer.log('SERVICE_DESTROY: timestamp=${timestamp.toIso8601String()} || name: StepCounter');
  }

  Future<void> _updateServiceState(bool isRunning) async {
    await _isar.writeTxn(() async {
      final appState = await _isar.appStates.get(0);
      if (appState != null) {
        appState.isServiceRunning = isRunning;
        appState.lastUpdateTime = DateTime.now();
        if (isRunning) {
          appState.serviceStartTime = DateTime.now();
          appState.currentSessionId = Uuid().v4();
        } else {
          appState.serviceStartTime = null;
          appState.currentSessionId = '';
        }
        await _isar.appStates.put(appState);
      }
    });
  }
}

// App startup validation - check if service is actually running
Future<void> validateServiceState() async {
  // Check if FlutterForegroundTask service is actually running
  final isServiceRunning = await FlutterForegroundTask.isRunningService;
  
  // Get current local state
  final appState = await _isar.appStates.get(0);
  if (appState == null) return;
  
  // Sync local state with actual service status
  if (appState.isServiceRunning != isServiceRunning) {
    await _isar.writeTxn(() async {
      appState.isServiceRunning = isServiceRunning;
      appState.lastUpdateTime = DateTime.now();
      if (!isServiceRunning) {
        appState.serviceStartTime = null;
        appState.currentSessionId = '';
      }
      await _isar.appStates.put(appState);
    });
    
    developer.log('SERVICE_STATE_SYNC: localState=${appState.isServiceRunning} || actualState=$isServiceRunning || name: StepCounter');
    
    // If local state says service should be running but it's not,
    // it means user force-killed the app - auto-restart service
    if (appState.isServiceRunning && !isServiceRunning) {
      await _autoRestartService();
    }
  }
}

// Auto-restart service when user force-killed the app
Future<void> _autoRestartService() async {
  try {
    // Check if we have necessary permissions
    final hasPermissions = await _checkAllPermissions();
    if (!hasPermissions) {
      // Show notification asking user to grant permissions
      await _showPermissionRequiredNotification();
      developer.log('SERVICE_AUTO_RESTART_FAILED: reason=permissions_denied || timestamp=${DateTime.now().toIso8601String()} || name: StepCounter');
      return;
    }
    
    // Start the service again
    await FlutterForegroundTask.startService(
      notificationTitle: 'Step Counter Active',
      notificationText: 'Service restarted after app was killed',
      callback: startCallback,
    );
    
    // Log the auto-restart event
    developer.log('SERVICE_AUTO_RESTART: reason=force_kill_detected || timestamp=${DateTime.now().toIso8601String()} || name: StepCounter');
    
  } catch (e) {
    // If auto-restart fails, show notification to user
    await _showServiceRestartFailedNotification();
    developer.log('SERVICE_AUTO_RESTART_FAILED: error=${e.toString()} || timestamp=${DateTime.now().toIso8601String()} || name: StepCounter', level: 1000, error: e);
  }
}
```

**Acceptance Criteria:**
- ✅ TaskHandler `onStart` updates service state to running
- ✅ TaskHandler `onDestroy` updates service state to stopped
- ✅ App validates service state on startup using `FlutterForegroundTask.isRunningService`
- ✅ Local state automatically syncs with actual service status
- ✅ Auto-restart service when force-kill is detected
- ✅ UI shows correct service status after app restart
- ✅ Handles both normal shutdown and force kill scenarios
- ✅ User doesn't need to manually restart service after force-kill

---

### FR-007: Session Management
**Priority:** MEDIUM  
**Description:** Track distinct counting sessions

**Session Boundaries:**
- New session on service start
- New session after phone reboot
- New session at midnight (date rollover)
- Session ID: UUID v4

**Session Data:**
```dart
class Session {
  String sessionId;
  DateTime startTime;
  DateTime? endTime;
  int startSteps;
  int endSteps;
  int totalSteps; // endSteps - startSteps
  String endReason; // USER_STOP, REBOOT, DATE_CHANGE, CRASH
}
```

---

### FR-008: Error Handling & Recovery
**Priority:** HIGH  
**Description:** Handle failures gracefully

**Error Scenarios:**

1. **Pedometer Not Available:**
   - Detect on service start
   - Log error with device info
   - Show user-friendly error message
   - Disable service start

2. **Service Killed by OS:**
   - Auto-restart via `flutter_foreground_task`
   - Log restart event
   - Resume from last known state
   - Send notification: "Service restarted"

3. **Permission Revoked:**
   - Detect permission changes
   - Pause service
   - Show notification asking user to restore permissions
   - Guide to settings

4. **Storage Full:**
   - Detect before writing
   - Trigger auto-cleanup
   - If still full, show error
   - Continue counting but stop logging

5. **Corrupted Database:**
   - Catch Isar exceptions
   - Backup current data
   - Reset database
   - Log incident
   - Notify user

6. **Service State Mismatch:**
   - Detect when local state doesn't match actual service status
   - Auto-correct state on app startup
   - Auto-restart service if force-kill is detected
   - Log state synchronization events
   - Show user notification if manual intervention needed

7. **Force Kill Recovery:**
   - Detect when user force-killed the app (local state = true, actual = false)
   - Automatically restart service without user intervention
   - Check permissions before auto-restart
   - Show notification if auto-restart fails
   - Log auto-restart events for debugging

---

## UI/UX Requirements

### Main Screen
```
┌─────────────────────────────┐
│  [☰] Step Counter    [⋮]    │
├─────────────────────────────┤
│                             │
│        👟 12,345            │
│        steps today          │
│                             │
│   Last updated: 10:30 AM    │
│                             │
│  ┌─────────────────────┐    │
│  │  [Start Tracking]   │    │
│  └─────────────────────┘    │
│                             │
│  Session: 2h 15m            │
│  Service: ● Active          │
├─────────────────────────────┤

```

### Settings Screen
- Permission status indicators
- Battery optimization status
- Service auto-start toggle
- Data retention settings
- About & Debug info

---

## Technical Implementation Details

### Service Configuration
```dart
FlutterForegroundTask.init(
  androidNotificationOptions: AndroidNotificationOptions(
    channelId: 'step_counter_service',
    channelName: 'Step Counter Service',
    channelImportance: NotificationChannelImportance.LOW,
    priority: NotificationPriority.LOW,
  ),
  foregroundTaskOptions: ForegroundTaskOptions(
    interval: 5000, // 5 seconds
    isOnceEvent: false,
    autoRunOnBoot: true,
    allowWakeLock: true,
    allowWifiLock: false,
  ),
);
```

### Daily Step Stream Handling
```dart
import 'dart:developer' as developer;

StreamSubscription? _stepSubscription;
DateTime? _lastResetDate;

void startListening() {
  // Get today's date for daily tracking
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  
  // Check if we need to reset daily counter
  if (_lastResetDate == null || !_isSameDay(_lastResetDate!, todayDate)) {
    await _resetDailyCounter(todayDate);
  }
  
  // Listen to daily step count stream from today
  _stepSubscription = Pedometer().stepCountStreamFrom(todayDate).listen(
    (steps) async {
      await _handleDailyStepChange(steps, todayDate);
    },
    onError: (error) {
      developer.log('PEDOMETER_ERROR: ${error.toString()} || timestamp=${DateTime.now().toIso8601String()} || name: StepCounter', level: 1000, error: error);
      _handlePedometerError(error);
    },
    cancelOnError: false, // Continue on errors
  );
}

Future<void> _handleDailyStepChange(int steps, DateTime date) async {
  // Get or create today's record
  final todayRecord = await _getOrCreateDailyRecord(date);
  
  // Calculate delta from last known steps
  final delta = steps - todayRecord.lastKnownSteps;
  
  if (delta > 0) {
    // Update today's step count
    todayRecord.steps += delta;
    todayRecord.lastKnownSteps = steps;
    todayRecord.lastUpdateTime = DateTime.now();
    
    // Save to Isar with reactive updates
    await _isar.writeTxn(() async {
      await _isar.dailyStepRecords.put(todayRecord);
    });
    
    // Log the step change
    developer.log('DAILY_STEP_CHANGE: steps=$steps || delta=$delta || date=${date.toIso8601String().split('T')[0]} || name: StepCounter');
  }
}
```


```

### Isar Reactive UI Updates
```dart
// Watch daily step records for UI updates
Stream<List<DailyStepRecord>> watchTodaySteps() {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  
  return _isar.dailyStepRecords
      .filter()
      .dateEqualTo(todayDate)
      .watch(fireImmediately: true);
}

// Watch app state changes
Stream<AppState?> watchAppState() {
  return _isar.appStates
      .filter()
      .idEqualTo(0) // Single app state record
      .watch(fireImmediately: true);
}

// Get today's step count
Future<int> getTodayStepCount() async {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  
  final record = await _isar.dailyStepRecords
      .filter()
      .dateEqualTo(todayDate)
      .findFirst();
  
  return record?.steps ?? 0;
}
```


---

## Testing Requirements

### Unit Tests
- [ ] Pedometer stream handling
- [ ] Database CRUD operations
- [ ] Log formatting
- [ ] Permission checking
- [ ] Session management
- [ ] Service state synchronization

### Integration Tests
- [ ] Service start/stop flow
- [ ] Step counting accuracy
- [ ] Data persistence after restart
- [ ] Error recovery scenarios
- [ ] Service state sync after app kill

### Manual Testing Scenarios
1. **Happy Path:**
   - Install app → Grant permissions → Start service → Walk 100 steps → Verify count

2. **Service Persistence:**
   - Start service → Close app → Walk 50 steps → Open app → Verify count updated

3. **Service Kill:**
   - Start service → Force stop app → Wait 1 min → Verify service restarted

4. **Phone Reboot:**
   - Start service → Reboot phone → Verify service auto-started

5. **Battery Saver:**
   - Enable battery saver → Verify service still running

6. **Service State Sync:**
   - Start service → Kill app → Wait 2 minutes → Open app → Verify state corrected

7. **Auto-Restart After Force Kill:**
   - Start service → Force kill app → Open app → Verify service auto-restarted
   - Verify notification shows "Service restarted after app was killed"
   - Verify step counting continues seamlessly

8. **OEM Testing:**
   - Test on Xiaomi, Samsung, Huawei devices

---

## Known Limitations (Demo Version)

1. **No Server Integration:**
   - All data stored locally only
   - No cloud backup
   - No multi-device sync

2. **iOS Background Limitations:**
   - iOS may suspend service more aggressively
   - Step counting may be less reliable on iOS
   - Consider using HealthKit for iOS in production

3. **Force Kill Limitations:**
   - When user force-kills the app, foreground service may also stop
   - This is an OS limitation, not a bug in the application
   - Service will restart when user opens the app again

4. **Sensor Availability:**
   - Some devices may not have step counter sensor
   - Older devices may have less accurate sensors

5. **Battery Impact:**
   - Continuous service will consume battery
   - Impact varies by device and usage

6. **Storage Limitation:**
   - Local storage only (no unlimited cloud)
   - Auto-cleanup required to prevent storage full

---


## Success Metrics (Demo)

- ✅ Service runs for 24+ hours without manual restart
- ✅ Step count accuracy within 95%
- ✅ No data loss after phone reboot
- ✅ App handles all error scenarios gracefully
- ✅ Battery consumption < 5% per day
- ✅ Auto-restart works after force-kill (no user intervention needed)
- ✅ Seamless user experience even after force-kill


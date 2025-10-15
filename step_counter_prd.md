# Step Counter Demo - Project Requirements Document

## Project Overview

**Project Name:** Step Counter Demo Application  
**Platform:** Flutter (iOS & Android)  
**Version:** 1.0.0 (Demo/POC)  
**Last Updated:** October 9, 2025

### Purpose
Develop a proof-of-concept mobile application that counts user steps continuously when the app is in foreground or background, and logs all activity data locally for analysis. The app uses foreground service to maintain step counting even when the main app is not visible, but may stop when the app is force-killed by the user.

This is a background-first design: all counting, baselining, and persistence happen in the background service. The UI is intentionally minimal and acts only as a thin client to visualize the latest totals and to expose a single Start/Stop control that toggles the background counter.

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

**Background-first Constraint:**
- ✅ All counting logic and data writes occur in the background service (foreground task), not in UI.
- ✅ UI never computes or mutates step totals; it only observes database streams and invokes Start/Stop.

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

**Service Responsibilities (authoritative source of truth):**
- Maintain accumulator/baseline math and detect day rollover/reboots
- Persist daily `startSteps`, `endSteps`, `steps` and session fields
- Emit progress to the notification (optional actions: Pause/Stop)
- Expose Start/Stop lifecycle (via a single public API used by the UI)

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
  // Baseline-based daily tracking
  late int startSteps; // Effective total at the start of the day (baseline)
  late int endSteps;   // Latest effective total observed for the day
  late int steps;      // Computed: endSteps - startSteps (persisted for convenience)
  
  // Optional diagnostics per day (raw pedometer continuity)
  late int lastRawDeviceTotal; // Last raw total read during the day (for reboot detection)
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

  // Baseline math for converting raw pedometer total to a monotonic effective total
  // effectiveTotal = rawDeviceTotal + accumulatorOffset
  late int accumulatorOffset; // Sum of lastRaw totals across device reboots
  late int lastRawDeviceTotal; // Last raw total observed globally (not per day)

  // Session tracking (active when user pressed Start)
  int? sessionStartSteps; // Effective total at session start (baseline)
  int? sessionEndSteps;   // Latest effective total while session active
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

### Main Screen (Minimal UI)
```
┌─────────────────────────────┐
│  Step Counter               │
├─────────────────────────────┤
│        👟 12,345            │
│        steps today          │
│   Service: ● Active         │
│   Last: 10:30 AM            │
│                             │
│  ┌─────────────────────┐    │
│  │ [Start / Stop]      │    │ ← single toggle button
│  └─────────────────────┘    │
├─────────────────────────────┤

```

**Minimal UI Requirements:**
- Single toggle button that calls background service API to Start or Stop.
- Display only: today's steps, service status, last update time.
- UI reads from Isar streams (`watchTodaySteps()`, `watchAppState()`); UI never writes step data.

### Settings Screen
- Permission status indicators
- Battery optimization status
- Service auto-start toggle
- Data retention settings
- About & Debug info

---

## Technical Implementation Details

### Baseline-based Counting (accurate per-day from cumulative pedometer)
The pedometer returns a cumulative step total that can reset on device reboot. Use baselines and an accumulator to compute accurate per-day and per-session steps.

Formulas:
- effectiveTotal = rawDeviceTotal + accumulatorOffset
- On reboot detection (rawDeviceTotal < lastRawDeviceTotal): accumulatorOffset += lastRawDeviceTotal
- Daily: dailySteps = max(0, effectiveTotal - dailyStartSteps)
- Session (if active): sessionSteps = max(0, effectiveTotal - sessionStartSteps)

Where:
- dailyStartSteps is stored in `DailyStepRecord.startSteps` for today.
- sessionStartSteps is stored in `AppState.sessionStartSteps` when user presses Start.

Day rollover:
- On first tick after 00:00 or when today changes, set `startSteps = effectiveTotal`, `endSteps = effectiveTotal`, `steps = 0` for the new `DailyStepRecord`.

App kill / resume:
- No need to see every delta. On resume, read the current rawDeviceTotal, compute effectiveTotal, then update today's `endSteps` and `steps`. If session active, update `sessionEndSteps` as well.

### Background-first Integration Contract
- Public API (service layer):
  - `startCounting()` → initializes session baselines, starts foreground task
  - `stopCounting()` → stops foreground task, seals session
  - `isRunning()` → reflects `FlutterForegroundTask.isRunningService`
- UI uses only the API above plus database watch streams for rendering.
- All data mutations happen inside the service task handler.

### Isar Database Best Practices (CRITICAL)

**Problem:** Isar `watch()` streams fail if the model doesn't exist, and replacing instances breaks reactive streams.

**Solution:**
1. **Initialization-first approach:**
   - Call `ensureRequiredModelsExist()` at app startup BEFORE any `watch()` calls
   - Create singleton `AppState` with ID=0
   - Create today's `DailyStepRecord` if it doesn't exist
   - Only then is it safe to use `watch()` in UI

2. **Get-Modify-Put pattern for all updates:**
   ```dart
   // ✅ CORRECT: Preserves watch streams
   await isar.writeTxn(() async {
     final appState = await isar.appStates.get(0);
     if (appState != null) {
       appState.isServiceRunning = true; // Modify existing instance
       await isar.appStates.put(appState); // Put back same instance
     }
   });
   
   // ❌ WRONG: Breaks watch streams
   await isar.writeTxn(() async {
     final newState = AppState()..isServiceRunning = true; // New instance
     await isar.appStates.put(newState); // Replaces old instance - breaks watches!
   });
   ```

3. **Singleton pattern for AppState:**
   - Always use ID=0 for the single app state
   - Use `await isar.appStates.get(0)` to retrieve
   - Never create multiple AppState instances

4. **Daily record uniqueness:**
   - Use date (normalized to midnight) as the unique key
   - Query with `.filter().dateEqualTo(todayDate).findFirst()`
   - Modify existing record for the day, don't create duplicates

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

### Step Stream Handling (from cumulative pedometer total)
```dart
import 'dart:developer' as developer;

StreamSubscription? _stepSubscription;
DateTime? _lastResetDate;

void startListening() {
  final now = DateTime.now();
  final todayDate = DateTime(now.year, now.month, now.day);

  // Ensure today's record exists and baselined
  _ensureDailyBaseline(todayDate);

  // Listen to cumulative raw step total
  _stepSubscription = Pedometer().stepCountStream.listen(
    (rawDeviceTotal) async {
      await _handleRawTotalUpdate(rawDeviceTotal);
    },
    onError: (error) {
      developer.log('PEDOMETER_ERROR: ${error.toString()} || timestamp=${DateTime.now().toIso8601String()} || name: StepCounter', level: 1000, error: error);
      _handlePedometerError(error);
    },
    cancelOnError: false,
  );
}

Future<void> _handleRawTotalUpdate(int rawDeviceTotal) async {
  await _isar.writeTxn(() async {
    // CRITICAL: Load existing instance, modify it, then put back
    final appState = await _isar.appStates.get(0);
    if (appState == null) return;

    // Reboot detection: raw decreased -> add lastRaw to accumulator
    if (appState.lastRawDeviceTotal > 0 && rawDeviceTotal < appState.lastRawDeviceTotal) {
      appState.accumulatorOffset += appState.lastRawDeviceTotal;
      developer.log('REBOOT_DETECTED: lastRaw=${appState.lastRawDeviceTotal} || newRaw=$rawDeviceTotal || offset=${appState.accumulatorOffset} || name: StepCounter');
    }

    // Compute effective total
    final effectiveTotal = rawDeviceTotal + appState.accumulatorOffset;

    // Day rollover check
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    if (_lastResetDate == null || !_isSameDay(_lastResetDate!, todayDate)) {
      await _createNewDayBaseline(todayDate, effectiveTotal);
      _lastResetDate = todayDate;
      appState.lastDateReset = todayDate;
    }

    // CRITICAL: Load existing today's record, modify it, then put back
    var todayRecord = await _isar.dailyStepRecords
        .filter()
        .dateEqualTo(todayDate)
        .findFirst();
    
    if (todayRecord != null) {
      // Modify existing instance
      todayRecord.lastRawDeviceTotal = rawDeviceTotal;
      todayRecord.endSteps = effectiveTotal;
      todayRecord.steps = (todayRecord.endSteps - todayRecord.startSteps).clamp(0, 1 << 31);
      todayRecord.lastUpdateTime = now;
      await _isar.dailyStepRecords.put(todayRecord); // Put back same instance
    }

    // Update session if active (modify existing appState instance)
    if (appState.currentSessionId.isNotEmpty && appState.sessionStartSteps != null) {
      appState.sessionEndSteps = effectiveTotal;
    }

    appState.lastRawDeviceTotal = rawDeviceTotal;
    appState.lastUpdateTime = now;
    await _isar.appStates.put(appState); // Put back same instance

    developer.log('DAILY_STEP_UPDATE: eff=$effectiveTotal || steps=${todayRecord?.steps ?? 0} || date=${todayDate.toIso8601String().split('T')[0]} || name: StepCounter');
  });
}

Future<void> _ensureDailyBaseline(DateTime date) async {
  final record = await _getOrCreateDailyRecord(date);
  if (record.startSteps == 0 && record.endSteps == 0 && record.steps == 0) {
    // Initialize baseline from current effective total if available
    final appState = await _isar.appStates.get(0);
    if (appState != null) {
      final effectiveTotal = appState.lastRawDeviceTotal + appState.accumulatorOffset;
      record.startSteps = effectiveTotal;
      record.endSteps = effectiveTotal;
      record.steps = 0;
      record.lastUpdateTime = DateTime.now();
      await _isar.writeTxn(() async {
        await _isar.dailyStepRecords.put(record);
      });
    }
  }
}

Future<void> _createNewDayBaseline(DateTime date, int effectiveTotal) async {
  final newRecord = DailyStepRecord()
    ..date = date
    ..startSteps = effectiveTotal
    ..endSteps = effectiveTotal
    ..steps = 0
    ..lastRawDeviceTotal = 0
    ..lastUpdateTime = DateTime.now()
    ..sessionId = ''
    ..synced = false;
  await _isar.writeTxn(() async {
    await _isar.dailyStepRecords.put(newRecord);
  });
}
```


```

### Isar Reactive UI Updates & Initialization Pattern

**Critical Isar Requirements:**
1. **Always ensure models exist before watching** - Isar watch will fail if the model doesn't exist yet
2. **Always update existing instances, never replace** - Use get → modify → put pattern to preserve watch streams

```dart
// INITIALIZATION: Must be called at app startup before any watch() calls
Future<void> ensureRequiredModelsExist() async {
  await _isar.writeTxn(() async {
    // Ensure AppState exists with ID=0 (singleton)
    var appState = await _isar.appStates.get(0);
    if (appState == null) {
      appState = AppState()
        ..id = 0
        ..currentSessionId = ''
        ..isServiceRunning = false
        ..lastUpdateTime = DateTime.now()
        ..lastDateReset = DateTime.now()
        ..accumulatorOffset = 0
        ..lastRawDeviceTotal = 0
        ..sessionStartSteps = null
        ..sessionEndSteps = null;
      await _isar.appStates.put(appState);
      developer.log('INIT: AppState created || name: StepCounter');
    }
    
    // Ensure today's DailyStepRecord exists
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    var todayRecord = await _isar.dailyStepRecords
        .filter()
        .dateEqualTo(todayDate)
        .findFirst();
    
    if (todayRecord == null) {
      final effectiveTotal = appState.lastRawDeviceTotal + appState.accumulatorOffset;
      todayRecord = DailyStepRecord()
        ..date = todayDate
        ..startSteps = effectiveTotal
        ..endSteps = effectiveTotal
        ..steps = 0
        ..lastRawDeviceTotal = 0
        ..lastUpdateTime = DateTime.now()
        ..sessionId = ''
        ..synced = false;
      await _isar.dailyStepRecords.put(todayRecord);
      developer.log('INIT: DailyStepRecord created || date=${todayDate.toIso8601String().split('T')[0]} || name: StepCounter');
    }
  });
}

// Watch daily step records for UI updates (safe after ensureRequiredModelsExist)
Stream<List<DailyStepRecord>> watchTodaySteps() {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  
  return _isar.dailyStepRecords
      .filter()
      .dateEqualTo(todayDate)
      .watch(fireImmediately: true);
}

// Watch app state changes (safe after ensureRequiredModelsExist)
Stream<AppState?> watchAppState() {
  return _isar.appStates
      .where()
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

// CORRECT UPDATE PATTERN: Get existing instance → modify → put
Future<void> updateAppState(Function(AppState) updateFn) async {
  await _isar.writeTxn(() async {
    final appState = await _isar.appStates.get(0);
    if (appState != null) {
      updateFn(appState); // Modify the existing instance
      await _isar.appStates.put(appState); // Put back the same instance
    }
  });
}

// Example: Update service running state
Future<void> setServiceRunning(bool isRunning) async {
  await updateAppState((state) {
    state.isServiceRunning = isRunning;
    state.lastUpdateTime = DateTime.now();
  });
}

// CORRECT UPDATE PATTERN for DailyStepRecord
Future<void> updateTodaySteps(int effectiveTotal) async {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  
  await _isar.writeTxn(() async {
    final record = await _isar.dailyStepRecords
        .filter()
        .dateEqualTo(todayDate)
        .findFirst();
    
    if (record != null) {
      // Modify existing instance
      record.endSteps = effectiveTotal;
      record.steps = (record.endSteps - record.startSteps).clamp(0, 1 << 31);
      record.lastUpdateTime = DateTime.now();
      await _isar.dailyStepRecords.put(record); // Put back the same instance
    }
  });
}
```

**App Initialization Flow:**
```dart
// In main.dart or app startup
Future<void> initializeApp() async {
  // 1. Initialize Isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [AppStateSchema, DailyStepRecordSchema],
    directory: dir.path,
  );
  
  // 2. CRITICAL: Ensure required models exist BEFORE any watch() calls
  await ensureRequiredModelsExist();
  
  // 3. Validate service state (sync with actual service status)
  await validateServiceState();
  
  // 4. Now safe to use watch() in UI
  runApp(MyApp());
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

### Scenario Coverage for Baseline Logic
1. User has NOT pressed Start, walks 1000 steps (TH1):
   - `dailyStartSteps` is set at first tick of the day; `dailySteps = effectiveTotal - dailyStartSteps`.
   - Persist `startSteps`, `endSteps`, `steps` per day; no session required.
2. User pressed Start, then app is killed/backgrounded, later re-opens (TH2):
   - On resume, compute `effectiveTotal` from raw + accumulator.
   - `sessionSteps = effectiveTotal - sessionStartSteps`; update `daily` similarly.
3. After pressing Start, always count even across kills (TH3):
   - Persist `sessionStartSteps` at Start; on next open, recompute and fill `sessionEndSteps` and `daily` from baselines.

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


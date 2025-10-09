# Step Counter Demo - Project Requirements Document

## Project Overview

**Project Name:** Step Counter Demo Application  
**Platform:** Flutter (iOS & Android)  
**Version:** 1.0.0 (Demo/POC)  
**Last Updated:** October 9, 2025

### Purpose
Develop a proof-of-concept mobile application that counts user steps continuously, even when the app is closed or killed, and logs all activity data locally for analysis.

---

## Technical Stack

### Core Dependencies
```yaml
dependencies:
  flutter_foreground_task: ^8.0.0+
  pedometer_2: ^5.0.4
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.0
  permission_handler: ^11.0.0
  connectivity_plus: ^5.0.0
  device_info_plus: ^9.1.0
  intl: ^0.18.0

dev_dependencies:
  hive_generator: ^2.0.0
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
**Description:** The application must count user steps continuously, 24/7

**Acceptance Criteria:**
- ✅ Steps are counted when app is in foreground
- ✅ Steps are counted when app is in background
- ✅ Steps are counted when app is closed/killed by user
- ✅ Step counting resumes after phone reboot
- ✅ Step count accuracy within ±5% of system pedometer

**Implementation:**
- Use `flutter_foreground_task` to maintain persistent service
- Use `pedometer_2` for step detection via Sensors API
- Configure service with `autoRunOnBoot: true`

---

### FR-002: Local Data Logging
**Priority:** HIGH  
**Description:** All step data and events must be logged locally to device storage

**Acceptance Criteria:**
- ✅ Each step change is logged with timestamp
- ✅ Service lifecycle events are logged (start, stop, restart)
- ✅ System events are logged (boot, network change)
- ✅ Error events are logged with stack traces
- ✅ Logs are persisted across app sessions
- ✅ Logs can be exported to external file

**Log Data Structure:**
```json
{
  "log_id": "uuid-v4",
  "timestamp": "2025-10-09T10:30:45.123Z",
  "log_level": "INFO|DEBUG|WARN|ERROR",
  "event_type": "STEP_CHANGE|SERVICE_START|SERVICE_STOP|ERROR",
  "data": {
    "steps": 1234,
    "delta": 10,
    "session_id": "session-abc",
    "device_info": {},
    "additional_context": {}
  }
}
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
- Updates every 10 steps (to save battery)

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

**Step Records Table:**
```dart
@HiveType(typeId: 0)
class StepRecord {
  @HiveField(0) String id;
  @HiveField(1) int steps;
  @HiveField(2) int delta;
  @HiveField(3) DateTime timestamp;
  @HiveField(4) String sessionId;
  @HiveField(5) bool synced; // For future server sync
}
```

**Log Records Table:**
```dart
@HiveType(typeId: 1)
class LogRecord {
  @HiveField(0) String id;
  @HiveField(1) DateTime timestamp;
  @HiveField(2) String level;
  @HiveField(3) String eventType;
  @HiveField(4) Map<String, dynamic> data;
}
```

**App State:**
```dart
@HiveType(typeId: 2)
class AppState {
  @HiveField(0) DateTime? serviceStartTime;
  @HiveField(1) int lastKnownSteps;
  @HiveField(2) String currentSessionId;
  @HiveField(3) bool isServiceRunning;
  @HiveField(4) DateTime? lastUpdateTime;
}
```

**Data Retention:**
- Step records: Keep last 30 days
- Log records: Keep last 7 days
- Auto-cleanup on app start
- Export capability before cleanup

---

### FR-006: Log Export Functionality
**Priority:** HIGH  
**Description:** Export all logs to readable file format

**Export Formats:**
1. **JSON** (Structured data)
2. **CSV** (For Excel analysis)
3. **TXT** (Human-readable)

**Export Content:**
- All step records within date range
- All log entries within date range
- App state snapshots
- Device information
- Session summaries

**Export File Naming:**
```
step_counter_logs_YYYYMMDD_HHmmss.{json|csv|txt}
```

**Export Location:**
- Android: `/storage/emulated/0/Download/StepCounterLogs/`
- iOS: App's Documents directory (accessible via Files app)

**Acceptance Criteria:**
- ✅ Export initiated from UI
- ✅ User can select date range
- ✅ User can select export format
- ✅ Export includes all relevant data
- ✅ File is saved to accessible location
- ✅ User notified of export completion with file path
- ✅ Option to share exported file

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
   - Catch Hive exceptions
   - Backup current data
   - Reset database
   - Log incident
   - Notify user

---

## Non-Functional Requirements

### NFR-001: Performance
- App launch time: < 2 seconds
- Service start time: < 3 seconds
- Database query time: < 100ms
- Log write time: < 50ms
- Notification update: < 200ms
- Memory usage: < 150MB (service)
- Step detection latency: < 2 seconds

### NFR-002: Battery Consumption
- Target: < 3% battery per day
- Optimize notification updates (batch every 10 steps)
- Minimize wake locks
- Use efficient database operations
- Debounce rapid step changes

### NFR-003: Reliability
- Service uptime: > 95% (excluding user manual stops)
- Data integrity: 100% (no lost records)
- Crash rate: < 0.1%
- Auto-recovery on errors: 100%

### NFR-004: Compatibility
- Android: 10.0 (API 29) and above
- iOS: 13.0 and above
- Device requirement: Built-in step sensor
- Screen sizes: All (responsive design)

### NFR-005: Data Storage
- Step records: Max 10,000 entries
- Log records: Max 50,000 entries
- Auto-cleanup: Daily at 3:00 AM
- Storage size: < 50MB
- Database backup: Before cleanup

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
│  ┌─────────────────────┐   │
│  │  [Start Tracking]   │   │
│  └─────────────────────┘   │
│                             │
│  Session: 2h 15m            │
│  Service: ● Active          │
│                             │
├─────────────────────────────┤
│  📊 Today's Activity        │
│  ┌─────────────────────┐   │
│  │  [Graph/Chart]      │   │
│  └─────────────────────┘   │
├─────────────────────────────┤
│  📁 Logs & Data             │
│  • Total records: 1,234     │
│  • Last export: 2 days ago  │
│  ┌─────────────────────┐   │
│  │  [Export Logs]      │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
```

### Settings Screen
- Permission status indicators
- Battery optimization status
- Service auto-start toggle
- Data retention settings
- Export settings
- About & Debug info

### Export Dialog
```
┌─────────────────────────────┐
│  Export Logs                │
├─────────────────────────────┤
│  Date Range:                │
│  [From: ___] [To: ___]      │
│                             │
│  Format:                    │
│  ○ JSON                     │
│  ○ CSV                      │
│  ○ TXT                      │
│                             │
│  Include:                   │
│  ☑ Step records             │
│  ☑ Log entries              │
│  ☑ Session summaries        │
│  ☑ Device info              │
│                             │
│  [Cancel]  [Export]         │
└─────────────────────────────┘
```

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

### Pedometer Stream Handling
```dart
StreamSubscription? _stepSubscription;

void startListening() {
  _stepSubscription = Pedometer().stepCountStream().listen(
    (steps) async {
      await _handleStepChange(steps);
    },
    onError: (error) {
      _logError('PEDOMETER_ERROR', error);
      _handlePedometerError(error);
    },
    cancelOnError: false, // Continue on errors
  );
}
```

### Logging Strategy
```dart
enum LogLevel { DEBUG, INFO, WARN, ERROR }

class Logger {
  static Future<void> log(
    LogLevel level,
    String eventType,
    Map<String, dynamic> data,
  ) async {
    final record = LogRecord(
      id: Uuid().v4(),
      timestamp: DateTime.now(),
      level: level.name,
      eventType: eventType,
      data: data,
    );
    
    await _logsBox.add(record);
    
    // Also print to console in debug mode
    if (kDebugMode) {
      print('[${level.name}] $eventType: $data');
    }
  }
}
```

### Export Implementation
```dart
class ExportService {
  Future<File> exportToJson(DateTime from, DateTime to) async {
    final steps = await _getStepRecords(from, to);
    final logs = await _getLogRecords(from, to);
    
    final data = {
      'export_date': DateTime.now().toIso8601String(),
      'date_range': {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      },
      'device_info': await _getDeviceInfo(),
      'step_records': steps.map((e) => e.toJson()).toList(),
      'log_records': logs.map((e) => e.toJson()).toList(),
      'summary': _generateSummary(steps),
    };
    
    final json = JsonEncoder.withIndent('  ').convert(data);
    return await _writeToFile('json', json);
  }
}
```

---

## Testing Requirements

### Unit Tests
- [ ] Pedometer stream handling
- [ ] Database CRUD operations
- [ ] Log formatting
- [ ] Export file generation
- [ ] Permission checking
- [ ] Session management

### Integration Tests
- [ ] Service start/stop flow
- [ ] Step counting accuracy
- [ ] Data persistence after restart
- [ ] Export complete workflow
- [ ] Error recovery scenarios

### Manual Testing Scenarios
1. **Happy Path:**
   - Install app → Grant permissions → Start service → Walk 100 steps → Verify count

2. **Service Persistence:**
   - Start service → Close app → Walk 50 steps → Open app → Verify count updated

3. **Service Kill:**
   - Start service → Force stop app → Wait 1 min → Verify service restarted

4. **Phone Reboot:**
   - Start service → Reboot phone → Verify service auto-started

5. **Export:**
   - Generate 1 day of data → Export to JSON → Verify file contents

6. **Battery Saver:**
   - Enable battery saver → Verify service still running

7. **OEM Testing:**
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

3. **Sensor Availability:**
   - Some devices may not have step counter sensor
   - Older devices may have less accurate sensors

4. **Battery Impact:**
   - Continuous service will consume battery
   - Impact varies by device and usage

5. **Storage Limitation:**
   - Local storage only (no unlimited cloud)
   - Auto-cleanup required to prevent storage full

---


## Success Metrics (Demo)

- ✅ Service runs for 24+ hours without manual restart
- ✅ Step count accuracy within 95%
- ✅ No data loss after phone reboot
- ✅ Export generates valid files
- ✅ App handles all error scenarios gracefully
- ✅ Battery consumption < 5% per day

---

## Project Timeline (Estimated)

- **Week 1:** Setup + Permissions + Basic UI
- **Week 2:** Foreground Service + Pedometer Integration
- **Week 3:** Local Storage + Logging
- **Week 4:** Export Functionality + Testing
- **Week 5:** Bug Fixes + Polish + Documentation

**Total:** 5 weeks for demo version

---


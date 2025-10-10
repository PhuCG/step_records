import 'dart:io';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/step_record.dart';
import '../models/app_state.dart';
import '../models/session.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static StorageService get instance => _instance;
  StorageService._internal();

  Isar? _isar;

  // Watchers
  Stream<void>? _appStateWatchLazy;
  Stream<void>? _dailyStepRecordsWatchLazy;
  Stream<void>? _sessionsWatchLazy;

  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([
      DailyStepRecordSchema,
      AppStateSchema,
      SessionSchema,
    ], directory: dir.path);

    // Ensure single AppState row exists
    final existing = await _isar!.appStates.get(0);
    if (existing == null) {
      await _isar!.writeTxn(() async {
        await _isar!.appStates.put(AppState());
      });
    }
    await _cleanupOldData();
  }

  // Daily Step Records
  Future<void> addDailyStepRecord(DailyStepRecord record) async {
    await _isar!.writeTxn(() async {
      await _isar!.dailyStepRecords.put(record);
    });
  }

  Future<DailyStepRecord?> getTodayStepRecord() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return await _isar!.dailyStepRecords
        .filter()
        .dateEqualTo(todayDate)
        .findFirst();
  }

  Future<DailyStepRecord> getOrCreateTodayRecord(String sessionId) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final existing = await _isar!.dailyStepRecords
        .filter()
        .dateEqualTo(todayDate)
        .findFirst();

    if (existing != null) {
      return existing;
    }

    // Create new record for today
    final newRecord = DailyStepRecord(
      date: todayDate,
      steps: 0,
      lastKnownSteps: 0,
      lastUpdateTime: DateTime.now(),
      sessionId: sessionId,
    );

    await _isar!.writeTxn(() async {
      await _isar!.dailyStepRecords.put(newRecord);
    });

    return newRecord;
  }

  Future<List<DailyStepRecord>> getDailyStepRecords(
    DateTime from,
    DateTime to,
  ) async {
    final q = _isar!.dailyStepRecords
        .where()
        .filter()
        .dateBetween(from, to, includeLower: false, includeUpper: false)
        .sortByDate();
    return await q.findAll();
  }

  Future<List<DailyStepRecord>> getAllDailyStepRecords() async {
    final q = _isar!.dailyStepRecords.where().sortByDate();
    return await q.findAll();
  }

  Future<DailyStepRecord?> getLatestDailyStepRecord() async {
    return await _isar!.dailyStepRecords.where().sortByDateDesc().findFirst();
  }

  // Watch daily step records for UI updates
  Stream<List<DailyStepRecord>> watchTodaySteps() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return _isar!.dailyStepRecords
        .filter()
        .dateEqualTo(todayDate)
        .watch(fireImmediately: true);
  }

  // Get today's step count
  Future<int> getTodayStepCount() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final record = await _isar!.dailyStepRecords
        .filter()
        .dateEqualTo(todayDate)
        .findFirst();

    return record?.steps ?? 0;
  }

  // App State
  Future<void> saveAppState(AppState state) async {
    state.id = 0;
    await _isar!.writeTxn(() async {
      await _isar!.appStates.put(state);
    });
  }

  Future<AppState> getAppState() async {
    return (await _isar!.appStates.get(0)) ?? AppState();
  }

  // Watch app state changes
  Stream<AppState?> watchAppState() {
    return _isar!.appStates
        .where()
        .idEqualTo(0) // Single app state record
        .watch(fireImmediately: true)
        .map((list) => list.isNotEmpty ? list.first : null);
  }

  // Sessions
  Future<void> addSession(Session session) async {
    await _isar!.writeTxn(() async {
      await _isar!.sessions.put(session);
    });
  }

  Future<List<Session>> getAllSessions() async {
    final q = _isar!.sessions.where().sortByStartTimeDesc();
    return await q.findAll();
  }

  Future<Session?> getLatestSession() async {
    return await _isar!.sessions.where().sortByStartTimeDesc().findFirst();
  }

  // Watchers
  Stream<void> watchAppStateLazy() {
    _appStateWatchLazy ??= _isar!.appStates.watchLazy(fireImmediately: true);
    return _appStateWatchLazy!;
  }

  Stream<void> watchDailyStepRecordsLazy() {
    _dailyStepRecordsWatchLazy ??= _isar!.dailyStepRecords.watchLazy(
      fireImmediately: true,
    );
    return _dailyStepRecordsWatchLazy!;
  }

  Stream<void> watchSessionsLazy() {
    _sessionsWatchLazy ??= _isar!.sessions.watchLazy(fireImmediately: true);
    return _sessionsWatchLazy!;
  }

  // Data cleanup
  Future<void> _cleanupOldData() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Cleanup daily step records older than 30 days
    final oldRecords = await _isar!.dailyStepRecords
        .where()
        .filter()
        .dateLessThan(thirtyDaysAgo)
        .findAll();
    await _isar!.writeTxn(() async {
      for (final r in oldRecords) {
        await _isar!.dailyStepRecords.delete(r.id);
      }
    });

    // Cleanup sessions older than 30 days
    final oldSessions = await _isar!.sessions
        .where()
        .filter()
        .startTimeLessThan(thirtyDaysAgo)
        .findAll();
    await _isar!.writeTxn(() async {
      for (final s in oldSessions) {
        await _isar!.sessions.delete(s.id);
      }
    });
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _isar!.writeTxn(() async {
      await _isar!.dailyStepRecords.clear();
      await _isar!.sessions.clear();
      // Keep AppState but reset it
      final appState = AppState();
      await _isar!.appStates.put(appState);
    });
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
    await _isar?.close();
  }
}

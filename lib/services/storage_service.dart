import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/step_record.dart';
import '../models/app_state.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static StorageService get instance => _instance;
  StorageService._internal();

  Isar? _isar;

  // Watchers
  Stream<void>? _appStateWatchLazy;
  Stream<void>? _dailyStepRecordsWatchLazy;

  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([
      DailyStepRecordSchema,
      AppStateSchema,
    ], directory: dir.path);

    // Ensure single AppState row exists
    final existing = await _isar?.appStates.get(0);
    if (existing == null) {
      await _isar?.writeTxn(() async {
        await _isar?.appStates.put(AppState());
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

  Future<DailyStepRecord> getOrCreateTodayRecord(DateTime date) async {
    final todayDate = DateTime(date.year, date.month, date.day);

    final existing = await _isar!.dailyStepRecords
        .filter()
        .dateEqualTo(todayDate)
        .findFirst();

    if (existing != null) return existing;

    // Create new record for today
    final newRecord = DailyStepRecord(
      date: todayDate,
      steps: 0,
      lastUpdateTime: DateTime.now(),
    );

    await _isar?.writeTxn(() async {
      await _isar?.dailyStepRecords.put(newRecord);
    });

    return newRecord;
  }

  Future<List<DailyStepRecord>> getAllDailyStepRecords() async {
    final q = _isar!.dailyStepRecords.where().sortByDate();
    return await q.findAll();
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
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _isar?.dailyStepRecords.clear();
    await _isar?.writeTxn(() async {
      // Keep AppState but reset it
      final appState = AppState();
      await _isar?.appStates.put(appState);
    });
  }
}

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/step_record.dart';
import '../models/app_state.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static StorageService get instance => _instance;
  StorageService._internal();

  Isar? _isar;

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
  }

  // Daily Step Records
  Future<void> addDailyStepRecord(DailyStepRecord record) async {
    await _isar?.writeTxn(() async {
      await _isar?.dailyStepRecords.put(record);
    });
  }

  Future<DailyStepRecord?> getLastStepRecord(DateTime date) async {
    final stepRecord = await _isar?.dailyStepRecords
        .where()
        .dateEqualTo(date)
        .findFirst();

    if (stepRecord != null) return stepRecord;

    return await getPreviousStepRecord(date);
  }

  // Get the previous step record (the record before the given date)
  Future<DailyStepRecord?> getPreviousStepRecord(DateTime currentDate) async {
    final previousRecord = await _isar?.dailyStepRecords
        .filter()
        .dateLessThan(currentDate)
        .sortByDateDesc()
        .findFirst();

    return previousRecord;
  }

  Future<DailyStepRecord> getOrCreateTodayRecord(
    DateTime dateKey,
    int? startSteps,
  ) async {
    // First, try to find existing record
    final existing = await _isar?.dailyStepRecords
        .filter()
        .dateEqualTo(dateKey)
        .findFirst();

    if (existing != null) {
      if (existing.startSteps == null && startSteps != null) {
        final updatedRecord = existing
          ..startSteps = startSteps
          ..lastUpdateTime = DateTime.now();
        await _isar?.writeTxn(() async {
          await _isar?.dailyStepRecords.put(updatedRecord);
        });
        return updatedRecord;
      }
      return existing;
    }

    // Before creating new record, update previous day's endSteps if needed
    await _updatePreviousDayEndSteps(dateKey, startSteps);

    // Create new record for today if not exists
    final newRecord = DailyStepRecord()
      ..date = dateKey
      ..startSteps = startSteps
      ..lastUpdateTime = DateTime.now();

    await _isar?.writeTxn(() async {
      await _isar?.dailyStepRecords.put(newRecord);
    });

    return newRecord;
  }

  // Update previous day's endSteps when creating a new day record
  Future<void> _updatePreviousDayEndSteps(
    DateTime currentDate,
    int? currentDeviceSteps,
  ) async {
    if (currentDeviceSteps == null) return;

    final previousRecord = await getPreviousStepRecord(currentDate);
    if (previousRecord == null) return;

    // Only update if current device steps > previous endSteps
    final previousEndSteps = previousRecord.endSteps ?? 0;
    if (currentDeviceSteps > previousEndSteps) {
      final updatedPreviousRecord = previousRecord
        ..endSteps = currentDeviceSteps
        ..lastUpdateTime = DateTime.now();

      await _isar?.writeTxn(() async {
        await _isar?.dailyStepRecords.put(updatedPreviousRecord);
      });
    }
  }

  // Watch daily step records for UI updates
  Stream<List<DailyStepRecord>> watchTodaySteps() async* {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    await getOrCreateTodayRecord(todayDate, null);

    yield* _isar!.dailyStepRecords
        .filter()
        .dateEqualTo(todayDate)
        .watch(fireImmediately: true);
  }

  // App State
  Future<void> saveAppState(AppState state) async {
    await _isar?.writeTxn(() async {
      final item = await _isar?.appStates.where().findFirst();
      item?.isServiceRunning = state.isServiceRunning;
      if (item != null) await _isar?.appStates.put(item);
    });
  }

  Future<AppState> getAppState() async {
    final item = await _isar?.appStates.where().findFirst();
    if (item != null) return item;
    return AppState();
  }

  // Watch app state changes
  Stream<AppState?> watchAppState() async* {
    yield* _isar!.appStates
        .where()
        .idEqualTo(0)
        .watch(fireImmediately: true)
        .map((list) => list.isNotEmpty ? list.first : null);
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

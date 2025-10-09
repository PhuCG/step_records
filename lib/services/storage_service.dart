import 'dart:io';
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
  Stream<void>? _stepRecordsWatchLazy;

  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([
      StepRecordSchema,
      AppStateSchema,
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

  // Step Records
  Future<void> addStepRecord(StepRecord record) async {
    await _isar!.writeTxn(() async {
      await _isar!.stepRecords.put(record);
    });
  }

  Future<List<StepRecord>> getStepRecords(DateTime from, DateTime to) async {
    final q = _isar!.stepRecords
        .where()
        .filter()
        .timestampBetween(from, to, includeLower: false, includeUpper: false)
        .sortByTimestamp();
    return await q.findAll();
  }

  Future<List<StepRecord>> getAllStepRecords() async {
    final q = _isar!.stepRecords.where().sortByTimestamp();
    return await q.findAll();
  }

  Future<StepRecord?> getLatestStepRecord() async {
    return await _isar!.stepRecords.where().sortByTimestampDesc().findFirst();
  }

  // App State
  Future<void> saveAppState(AppState state) async {
    state.id = 0;
    await _isar!.writeTxn(() async {
      await _isar!.appStates.put(state);
    });
    // notify watchers
  }

  Future<AppState> getAppState() async {
    return (await _isar!.appStates.get(0)) ?? AppState();
  }

  // Watchers
  Stream<void> watchAppStateLazy() {
    _appStateWatchLazy ??= _isar!.appStates.watchLazy(fireImmediately: true);
    return _appStateWatchLazy!;
  }

  Stream<void> watchStepRecordsLazy() {
    _stepRecordsWatchLazy ??= _isar!.stepRecords.watchLazy(
      fireImmediately: true,
    );
    return _stepRecordsWatchLazy!;
  }

  // Data cleanup
  Future<void> _cleanupOldData() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Cleanup step records older than 30 days
    final old = await _isar!.stepRecords
        .where()
        .filter()
        .timestampLessThan(thirtyDaysAgo)
        .findAll();
    await _isar!.writeTxn(() async {
      for (final r in old) {
        await _isar!.stepRecords.delete(r.autoId);
      }
    });

    // Cleanup log records older than 7 days
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

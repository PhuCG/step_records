import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/app_state.dart';
import '../models/step_log_entry.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static StorageService get instance => _instance;
  StorageService._internal();

  Isar? _isar;

  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([
      AppStateSchema,
      StepLogEntrySchema,
    ], directory: dir.path);

    // Ensure single AppState row exists
    final existing = await _isar?.appStates.get(0);
    if (existing == null) {
      await _isar?.writeTxn(() async {
        await _isar?.appStates.put(AppState());
      });
    }
  }

  // App State
  Future<void> saveAppState(AppState state) async {
    await _isar?.writeTxn(() async {
      final item = await _isar?.appStates.where().findFirst();
      if (item != null) {
        item.isServiceRunning = state.isServiceRunning;
        item.startEventTime = state.startEventTime;
        item.driverName = state.driverName;
        item.vehicleId = state.vehicleId;
        await _isar?.appStates.put(item);
      }
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

  // Step Log Entries
  Future<void> addStepLogEntry(StepLogEntry entry) async {
    await _isar?.writeTxn(() async {
      await _isar?.stepLogEntrys.put(entry);
    });
  }

  Future<List<StepLogEntry>> getAllStepLogEntries() async {
    return await _isar?.stepLogEntrys.where().sortByTime().findAll() ?? [];
  }

  Future<void> clearAllStepLogEntries() async {
    await _isar?.writeTxn(() async {
      await _isar?.stepLogEntrys.clear();
    });
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/step_counter_service.dart';
import '../services/storage_service.dart';
import '../services/permission_service.dart';
import '../models/app_state.dart';
import '../models/step_record.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  AppState _appState = AppState();
  DailyStepRecord? _todayRecord;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Subscribe to app state changes via database watcher for live UI updates
    StorageService.instance.watchAppState().listen((appState) async {
      if (mounted && appState != null) {
        setState(() {
          _appState = appState;
        });
      }
    });

    // Subscribe to today's step changes
    StorageService.instance.watchTodaySteps().listen((records) {
      if (mounted) {
        if (records.isNotEmpty) {
          setState(() {
            _todayRecord = records.first;
          });
        } else {}
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _startService() async {
    try {
      // UI Layer: Handle permissions first
      final hasPermissions = await PermissionService.instance
          .checkAllPermissions();
      if (!hasPermissions) {
        final granted = await PermissionService.instance
            .requestAllPermissions();
        if (!granted) {
          _showErrorSnackBar('Permissions required to start step counting');
          return;
        }
      }

      // UI Layer: Start service (Service layer will handle the rest)
      final success = await StepCounterService.instance.startService();
      if (success) {
        _showSuccessSnackBar('Step counting started');
        // No need to refresh - watchers will handle UI updates
      } else {
        _showErrorSnackBar('Failed to start step counting');
      }
    } catch (e) {
      _showErrorSnackBar('Error starting service: $e');
    }
  }

  Future<void> _stopService() async {
    try {
      // UI Layer: Stop service (Service layer will handle the rest)
      final success = await StepCounterService.instance.stopService();
      if (success) {
        _showSuccessSnackBar('Step counting stopped');
        // No need to refresh - watchers will handle UI updates
      } else {
        _showErrorSnackBar('Failed to stop step counting');
      }
    } catch (e) {
      _showErrorSnackBar('Error stopping service: $e');
    }
  }

  // Removed _refreshAppState - UI updates are handled by watchers

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  String _formatSteps(int steps) {
    return NumberFormat('#,###').format(steps);
  }

  String _formatLastUpdate(DateTime? lastUpdate) {
    if (lastUpdate == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, HH:mm').format(lastUpdate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final todaySteps = _todayRecord?.steps ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step Counter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main step counter display
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.directions_walk,
                      size: 64,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _formatSteps(todaySteps),
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'steps today',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Last updated: ${_formatLastUpdate(_todayRecord?.lastUpdateTime)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Control button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _appState.isServiceRunning
                    ? _stopService
                    : _startService,
                icon: Icon(
                  _appState.isServiceRunning ? Icons.stop : Icons.play_arrow,
                ),
                label: Text(
                  _appState.isServiceRunning
                      ? 'Stop Tracking'
                      : 'Start Tracking',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _appState.isServiceRunning
                      ? Colors.red
                      : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const SizedBox(height: 24),

            // Status information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session Info',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status:'),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _appState.isServiceRunning
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _appState.isServiceRunning
                                  ? 'Active'
                                  : 'Inactive',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

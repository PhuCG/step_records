import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/step_counter_service.dart';
import '../services/storage_service.dart';
import '../services/permission_service.dart';
import '../models/app_state.dart';
import '../models/step_record.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  AppState _appState = AppState();
  DailyStepRecord? _todayRecord;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
    // Subscribe to app state changes via database watcher for live UI updates
    StorageService.instance.watchAppStateLazy().listen((_) async {
      final appState = await StorageService.instance.getAppState();
      if (mounted) {
        setState(() {
          _appState = appState;
        });
      }
    });

    // Subscribe to today's step changes
    StorageService.instance.watchTodaySteps().listen((records) {
      if (mounted && records.isNotEmpty) {
        setState(() {
          _todayRecord = records.first;
        });
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize service first to allow state reconciliation
      await StepCounterService.instance.initialize();

      // Load app state
      _appState = await StorageService.instance.getAppState();

      // Load today's step record
      _todayRecord = await StorageService.instance.getTodayStepRecord();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to initialize app: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // When app comes back to foreground, reconcile service state and refresh UI
      StepCounterService.instance.validateServiceState().then(
        (_) => _refreshAppState(),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _startService() async {
    try {
      // Check permissions first
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

      // Start service
      final success = await StepCounterService.instance.startService();
      if (success) {
        await _refreshAppState();
        _showSuccessSnackBar('Step counting started');
      } else {
        _showErrorSnackBar('Failed to start step counting');
      }
    } catch (e) {
      _showErrorSnackBar('Error starting service: $e');
    }
  }

  Future<void> _stopService() async {
    try {
      final success = await StepCounterService.instance.stopService();
      if (success) {
        await _refreshAppState();
        _showSuccessSnackBar('Step counting stopped');
      } else {
        _showErrorSnackBar('Failed to stop step counting');
      }
    } catch (e) {
      _showErrorSnackBar('Error stopping service: $e');
    }
  }

  Future<void> _refreshAppState() async {
    final appState = await StorageService.instance.getAppState();
    final todayRecord = await StorageService.instance.getTodayStepRecord();

    setState(() {
      _appState = appState;
      _todayRecord = todayRecord;
    });
  }

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

  String _formatDuration(DateTime? startTime) {
    if (startTime == null) return '0m';

    final duration = DateTime.now().difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final todaySteps = _todayRecord?.steps ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step Counter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              await _refreshAppState();
            },
          ),
        ],
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
                        const Text('Duration:'),
                        Text(_formatDuration(_appState.serviceStartTime)),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                    if (_appState.currentSessionId.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Session:'),
                          Text(
                            _appState.currentSessionId.substring(0, 8),
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ],
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

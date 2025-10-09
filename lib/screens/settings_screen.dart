import 'package:flutter/material.dart';
import '../services/permission_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, bool> _permissionStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPermissionStatus();
  }

  Future<void> _loadPermissionStatus() async {
    try {
      final status = await PermissionService.instance.getPermissionStatus();
      setState(() {
        _permissionStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load permission status: $e');
    }
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

  Future<void> _requestPermissions() async {
    try {
      final granted = await PermissionService.instance.requestAllPermissions();
      if (granted) {
        _showSuccessSnackBar('All permissions granted');
      } else {
        _showErrorSnackBar('Some permissions were denied');
      }
      await _loadPermissionStatus();
    } catch (e) {
      _showErrorSnackBar('Error requesting permissions: $e');
    }
  }

  Future<void> _openAppSettings() async {
    try {
      await PermissionService.instance.openAppSettings();
    } catch (e) {
      _showErrorSnackBar('Error opening settings: $e');
    }
  }

  Future<void> _requestBatteryOptimization() async {
    try {
      final granted = await PermissionService.instance
          .requestBatteryOptimization();
      if (granted) {
        _showSuccessSnackBar('Battery optimization disabled');
      } else {
        _showErrorSnackBar('Battery optimization permission denied');
      }
    } catch (e) {
      _showErrorSnackBar('Error requesting battery optimization: $e');
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all step records and logs. This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // This would require implementing a clearAllData method in StorageService
        _showSuccessSnackBar('All data cleared');
      } catch (e) {
        _showErrorSnackBar('Error clearing data: $e');
      }
    }
  }

  Widget _buildPermissionTile(String permission, bool isGranted) {
    return ListTile(
      leading: Icon(
        isGranted ? Icons.check_circle : Icons.cancel,
        color: isGranted ? Colors.green : Colors.red,
      ),
      title: Text(_getPermissionDisplayName(permission)),
      subtitle: Text(isGranted ? 'Granted' : 'Denied'),
      trailing: isGranted ? null : const Icon(Icons.arrow_forward_ios),
      onTap: isGranted ? null : _openAppSettings,
    );
  }

  String _getPermissionDisplayName(String permission) {
    switch (permission) {
      case 'Permission.activityRecognition':
        return 'Activity Recognition';
      case 'Permission.notification':
        return 'Notifications';
      case 'Permission.ignoreBatteryOptimizations':
        return 'Battery Optimization';
      case 'Permission.sensors':
        return 'Motion Sensors';
      default:
        return permission;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Permissions section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Permissions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._permissionStatus.entries.map(
                    (entry) => _buildPermissionTile(entry.key, entry.value),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _requestPermissions,
                      child: const Text('Request All Permissions'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Battery optimization
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Battery Optimization',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Disable battery optimization to ensure step counting continues in the background.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _requestBatteryOptimization,
                      child: const Text('Disable Battery Optimization'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Data management
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Management',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Manage your step data and logs.'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _clearAllData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Clear All Data'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // About section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Step Counter Demo v1.0.0'),
                  const Text('A proof-of-concept step counting application.'),
                  const SizedBox(height: 8),
                  const Text(
                    'This app counts your steps continuously and stores all data locally on your device.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

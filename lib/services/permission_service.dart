import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'logger.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  static PermissionService get instance => _instance;
  PermissionService._internal();

  // Required permissions for Android
  static const List<Permission> _androidPermissions = [
    Permission.activityRecognition,
    Permission.notification,
    Permission.ignoreBatteryOptimizations,
  ];

  // Required permissions for iOS
  static const List<Permission> _iosPermissions = [Permission.sensors];

  Future<bool> requestAllPermissions() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      List<Permission> permissionsToRequest = [];

      if (Platform.isAndroid) {
        permissionsToRequest = List.from(_androidPermissions);

        // Add Android 13+ specific permissions
        if (androidInfo.version.sdkInt >= 33) {
          permissionsToRequest.add(Permission.notification);
        }
      } else if (Platform.isIOS) {
        permissionsToRequest = List.from(_iosPermissions);
      }

      await Logger.info('PERMISSION_REQUEST', {
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'permissions': permissionsToRequest.map((p) => p.toString()).toList(),
      });

      final results = await permissionsToRequest.request();

      bool allGranted = true;
      for (final permission in permissionsToRequest) {
        final status = results[permission];
        if (status != PermissionStatus.granted) {
          allGranted = false;
          await Logger.warn('PERMISSION_DENIED', {
            'permission': permission.toString(),
            'status': status.toString(),
          });
        }
      }

      if (allGranted) {
        await Logger.info('PERMISSION_GRANTED', {'all_permissions': true});
      }

      return allGranted;
    } catch (e) {
      await Logger.error('PERMISSION_ERROR', {'error': e.toString()});
      return false;
    }
  }

  Future<bool> checkAllPermissions() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      List<Permission> permissionsToCheck = [];

      if (Platform.isAndroid) {
        permissionsToCheck = List.from(_androidPermissions);

        // Add Android 13+ specific permissions
        if (androidInfo.version.sdkInt >= 33) {
          permissionsToCheck.add(Permission.notification);
        }
      } else if (Platform.isIOS) {
        permissionsToCheck = List.from(_iosPermissions);
      }

      for (final permission in permissionsToCheck) {
        final status = await permission.status;
        if (status != PermissionStatus.granted) {
          await Logger.debug('PERMISSION_CHECK', {
            'permission': permission.toString(),
            'status': status.toString(),
            'granted': false,
          });
          return false;
        }
      }

      await Logger.debug('PERMISSION_CHECK', {'all_granted': true});
      return true;
    } catch (e) {
      await Logger.error('PERMISSION_CHECK_ERROR', {'error': e.toString()});
      return false;
    }
  }

  Future<Map<String, bool>> getPermissionStatus() async {
    final status = <String, bool>{};

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      List<Permission> permissionsToCheck = [];

      if (Platform.isAndroid) {
        permissionsToCheck = List.from(_androidPermissions);

        // Add Android 13+ specific permissions
        if (androidInfo.version.sdkInt >= 33) {
          permissionsToCheck.add(Permission.notification);
        }
      } else if (Platform.isIOS) {
        permissionsToCheck = List.from(_iosPermissions);
      }

      for (final permission in permissionsToCheck) {
        final permissionStatus = await permission.status;
        status[permission.toString()] =
            permissionStatus == PermissionStatus.granted;
      }
    } catch (e) {
      await Logger.error('PERMISSION_STATUS_ERROR', {'error': e.toString()});
    }

    return status;
  }

  Future<bool> openAppSettings() async {
    try {
      await openAppSettings();
      await Logger.info('APP_SETTINGS_OPENED', {});
      return true;
    } catch (e) {
      await Logger.error('APP_SETTINGS_ERROR', {'error': e.toString()});
      return false;
    }
  }

  Future<bool> requestBatteryOptimization() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (status == PermissionStatus.granted) {
        return true;
      }

      final result = await Permission.ignoreBatteryOptimizations.request();
      await Logger.info('BATTERY_OPTIMIZATION_REQUEST', {
        'result': result.toString(),
      });

      return result == PermissionStatus.granted;
    } catch (e) {
      await Logger.error('BATTERY_OPTIMIZATION_ERROR', {'error': e.toString()});
      return false;
    }
  }
}

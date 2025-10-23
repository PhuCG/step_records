# Native Permissions Setup Guide for Flutter Foreground Task & Pedometer

## Overview

This application uses the following packages:
- `flutter_foreground_task: ^9.1.0` - Background service management
- `permission_handler: ^11.0.0` - Runtime permissions management
- `pedometer_2: ^5.0.4` - Step counting functionality

This guide covers all necessary native configurations for both Android and iOS platforms.

---

## 📱 Android Setup

### 1. AndroidManifest.xml

**Location:** `android/app/src/main/AndroidManifest.xml`

#### Required Permissions:

```xml
<!-- Essential for step counting -->
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />

<!-- Foreground service permissions -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />

<!-- Notification permission (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Battery optimization permission -->
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />

<!-- Auto-restart after device reboot -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.WAKE_LOCK" />

<!-- Network permissions (optional) -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Storage permissions (optional, if needed) -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### Service and Receiver Configuration:

```xml
<application
    android:label="test_abc"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
    
    <!-- MainActivity -->
    <activity
        android:name=".MainActivity"
        android:exported="true"
        android:launchMode="singleTop"
        android:taskAffinity=""
        android:theme="@style/LaunchTheme"
        android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
        android:hardwareAccelerated="true"
        android:windowSoftInputMode="adjustResize">
        <intent-filter>
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.LAUNCHER"/>
        </intent-filter>
    </activity>
    
    <!-- Foreground Service for flutter_foreground_task -->
    <service
        android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
        android:foregroundServiceType="dataSync"
        android:exported="false" />
        
    <!-- Restart Receiver for auto-restart after reboot -->
    <receiver
        android:name="com.pravera.flutter_foreground_task.service.RestartReceiver"
        android:exported="false">
        <intent-filter>
            <action android:name="android.intent.action.BOOT_COMPLETED" />
        </intent-filter>
    </receiver>
</application>
```

### 2. build.gradle.kts (App Level)

**Location:** `android/app/build.gradle.kts`

#### Key Configuration:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.test_abc"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    
    defaultConfig {
        applicationId = "com.example.test_abc"
        minSdk = 29  // Minimum Android 10 (API 29)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}
```

**Important Notes:**
- `minSdk = 29` is required for:
  - Activity Recognition permission
  - Foreground Service Type
  - Stable Pedometer API
  - Better step counter accuracy

### 3. MainActivity.kt

**Location:** `android/app/src/main/kotlin/com/example/test_abc/MainActivity.kt`

```kotlin
package com.example.test_abc

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

**Note:** No additional configuration needed. The standard `FlutterActivity` is sufficient for both `flutter_foreground_task` and `pedometer_2` as they handle everything through plugins.

### 4. Permission Mapping with PermissionService

| Permission in Code | Android Native Permission | Purpose |
|-------------------|---------------------------|---------|
| `Permission.activityRecognition` | `ACTIVITY_RECOGNITION` | Step counting via pedometer_2 |
| `Permission.notification` | `POST_NOTIFICATIONS` (API 33+) | Foreground service notification |
| `Permission.ignoreBatteryOptimizations` | `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Keep service running in background |

---

## 🍎 iOS Setup

### 1. Info.plist

**Location:** `ios/Runner/Info.plist`

#### Required Keys:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Bundle configuration -->
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleDisplayName</key>
    <string>Test Abc</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    
    <!-- Motion & Fitness permission (Required for pedometer_2) -->
    <key>NSMotionUsageDescription</key>
    <string>This app needs access to motion sensors to count your steps.</string>
    
    <!-- Notification permission (Required for flutter_foreground_task) -->
    <key>NSUserNotificationUsageDescription</key>
    <string>We need your permission to show notifications for the foreground service.</string>
    <!-- Flutter forground -->
    <key>BGTaskSchedulerPermittedIdentifiers</key>
    <array>
      <string>com.pravera.flutter_foreground_task.refresh</string>
    </array>
    <!-- Background Modes (Required for flutter_foreground_task) -->
    <key>UIBackgroundModes</key>
    <array>
        <string>background-processing</string>
        <string>background-fetch</string>
        <string>remote-notification</string>
    </array>
</dict>
</plist>
```

### 2. AppDelegate.swift

**Location:** `ios/Runner/AppDelegate.swift`

#### Required Configuration for flutter_foreground_task:

```swift
import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // IMPORTANT: Setup flutter_foreground_task plugin
    SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    
    // Setup notification delegate for iOS 10+
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**Critical Points:**
- `SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback` is **required** for the foreground task to work properly
- Without this callback, the background isolate won't have access to Flutter plugins
- The notification delegate setup enables notification handling

### 3. Podfile

**Location:** `ios/Podfile`

#### Required Configuration for permission_handler:

```ruby
# Uncomment this line to define a global platform for your project
# platform :ios, '13.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    ## IMPORTANT: Add permission_handler configurations
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        ## dart: PermissionGroup.sensors (for pedometer_2)
        'PERMISSION_SENSORS=1',
        ## dart: PermissionGroup.notification (for flutter_foreground_task)
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
    ## END OF PERMISSION CONFIGURATION
  end
end
```

**Important:** The `GCC_PREPROCESSOR_DEFINITIONS` section is **required** for `permission_handler` to include the necessary permission modules. Without these:
- `Permission.sensors` will not work (breaks pedometer)
- `Permission.notification` will not work (breaks foreground task)

### 4. Runner.entitlements

**Location:** `ios/Runner/Runner.entitlements`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>aps-environment</key>
    <string>development</string>
</dict>
</plist>
```

**Note:** For production builds, change to:
```xml
<string>production</string>
```

### 5. Xcode Project Configuration

**Required Steps in Xcode:**

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability" and add "Background Modes"
5. Enable the following modes:
   - ✓ Background fetch
   - ✓ Background processing
   - ✓ Remote notifications

**Why these are needed:**
- **Background fetch:** Allows periodic background updates
- **Background processing:** Enables long-running background tasks
- **Remote notifications:** Required for foreground service notifications

### 6. Permission Mapping with PermissionService

| Permission in Code | iOS Native Permission | Purpose |
|-------------------|----------------------|---------|
| `Permission.notification` | User Notifications Framework | Foreground service notification |
| `Permission.sensors` | Motion & Fitness (NSMotionUsageDescription) | Step counting via pedometer_2 |

---

## 🔍 Permission Comparison by Platform

### Android (from PermissionService)
```dart
static const List<Permission> _androidPermissions = [
  Permission.activityRecognition,        // ✅ ACTIVITY_RECOGNITION (for pedometer_2)
  Permission.notification,                // ✅ POST_NOTIFICATIONS (API 33+, for flutter_foreground_task)
  Permission.ignoreBatteryOptimizations, // ✅ REQUEST_IGNORE_BATTERY_OPTIMIZATIONS (keep service alive)
];
```

### iOS (from PermissionService)
```dart
static const List<Permission> _iosPermissions = [
  Permission.notification,  // ✅ NSUserNotificationUsageDescription (for flutter_foreground_task)
  Permission.sensors,       // ✅ NSMotionUsageDescription (for pedometer_2)
];
```

---

## ✅ Complete Setup Checklist

### Android:
- [x] `ACTIVITY_RECOGNITION` in AndroidManifest.xml
- [x] `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_DATA_SYNC` in AndroidManifest.xml
- [x] `POST_NOTIFICATIONS` in AndroidManifest.xml (Android 13+)
- [x] `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` in AndroidManifest.xml
- [x] `RECEIVE_BOOT_COMPLETED` + `WAKE_LOCK` in AndroidManifest.xml
- [x] ForegroundService declaration with `foregroundServiceType="dataSync"`
- [x] RestartReceiver declaration with BOOT_COMPLETED intent filter
- [x] minSdk = 29 in build.gradle.kts
- [x] MainActivity extends FlutterActivity

### iOS:
- [x] `NSMotionUsageDescription` in Info.plist
- [x] `NSUserNotificationUsageDescription` in Info.plist
- [x] `UIBackgroundModes` array with: background-processing, background-fetch, remote-notification
- [x] `SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback` in AppDelegate.swift
- [x] `UNUserNotificationCenter` delegate setup in AppDelegate.swift
- [x] `PERMISSION_SENSORS=1` in Podfile post_install
- [x] `PERMISSION_NOTIFICATIONS=1` in Podfile post_install
- [x] `aps-environment` in Runner.entitlements
- [x] Background Modes enabled in Xcode capabilities

---

## 📝 Important Notes

### Android:

#### pedometer_2 Specifics:
- Requires `ACTIVITY_RECOGNITION` permission (runtime permission on Android 10+)
- Works best with `minSdk = 29` or higher
- Uses `SensorManager` or `StepCounterListener` internally
- No additional native code required

#### flutter_foreground_task Specifics:
- Requires `FOREGROUND_SERVICE` permission
- Must declare `foregroundServiceType` (we use `dataSync`)
- Notification channel is created automatically
- Can auto-restart after device reboot with `RECEIVE_BOOT_COMPLETED`

#### General:
1. **Android 13+ (API 33+):** Must request `POST_NOTIFICATIONS` at runtime
2. **Battery Optimization:** User must manually grant in Settings (cannot be granted automatically)
3. **Foreground Service Type:** `dataSync` is appropriate for background data processing
4. **Boot Completed:** Allows service to auto-start after device reboot

### iOS:

#### pedometer_2 Specifics:
- Requires `NSMotionUsageDescription` in Info.plist
- Uses Core Motion framework (`CMPedometer`)
- Automatically requests permission when first accessed
- No additional native code required

#### flutter_foreground_task Specifics:
- Requires `SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback` in AppDelegate
- Without this callback, background isolate won't work
- Uses local notifications to keep app running
- Background modes must be enabled in Xcode

#### General:
1. **Motion Permission:** Required for pedometer, user must approve
2. **Background Modes:** Must be configured in Xcode Signing & Capabilities
3. **Notification Permission:** Always requires user approval
4. **Plugin Registrant Callback:** Critical for flutter_foreground_task to function

---

## 🔧 Testing & Verification

### Check All Permissions:
```dart
final permissionService = PermissionService.instance;

// Check all permissions at once
bool allGranted = await permissionService.checkAllPermissions();

// Get detailed status for each permission
Map<String, bool> status = await permissionService.getPermissionStatus();
print('Permission Status: $status');
```

### Request Permissions:
```dart
bool granted = await permissionService.requestAllPermissions();

if (!granted) {
  // Open app settings for manual permission grant
  await permissionService.openAppSettings();
}
```

### Test Pedometer (pedometer_2):
```dart
import 'package:pedometer_2/pedometer_2.dart';

// Listen to step count stream
Pedometer.stepCountStream.listen((StepCount event) {
  print('Steps: ${event.steps}');
}).onError((error) {
  print('Pedometer Error: $error');
});
```

### Test Foreground Task:
```dart
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// Check if service is running
bool isRunning = await FlutterForegroundTask.isRunningService;
print('Foreground Service Running: $isRunning');

// Start foreground service
await FlutterForegroundTask.startService(
  notificationTitle: 'Step Counter',
  notificationText: 'Counting your steps...',
  callback: startCallback,
);
```

---

## 🚨 Common Issues & Solutions

### Android:

**Issue:** Foreground service stops after app is killed
- **Solution:** Ensure `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` is granted
- **Solution:** Set `autoRunOnBoot: true` in FlutterForegroundTask config

**Issue:** Pedometer not receiving step updates
- **Solution:** Check `ACTIVITY_RECOGNITION` permission is granted
- **Solution:** Ensure device has step counter sensor (use `SensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)`)

### iOS:

**Issue:** Background task stops after a few minutes
- **Solution:** Verify `SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback` is in AppDelegate
- **Solution:** Ensure Background Modes are enabled in Xcode

**Issue:** Pedometer permission not requested
- **Solution:** Check `NSMotionUsageDescription` is in Info.plist
- **Solution:** Verify `PERMISSION_SENSORS=1` is in Podfile

**Issue:** Compile error: "Use of unresolved identifier 'SwiftFlutterForegroundTaskPlugin'"
- **Solution:** Run `cd ios && pod install && cd ..`
- **Solution:** Clean build folder in Xcode

---

## 📚 Reference Documentation

### Official Package Documentation:
- [flutter_foreground_task](https://pub.dev/packages/flutter_foreground_task)
- [permission_handler](https://pub.dev/packages/permission_handler)
- [pedometer_2](https://pub.dev/packages/pedometer_2)

### Platform Documentation:
- [Android Foreground Services](https://developer.android.com/develop/background-work/services/foreground-services)
- [Android Runtime Permissions](https://developer.android.com/training/permissions/requesting)
- [iOS Background Execution](https://developer.apple.com/documentation/uikit/app_and_environment/scenes/preparing_your_ui_to_run_in_the_background)
- [iOS Core Motion](https://developer.apple.com/documentation/coremotion)
- [iOS User Notifications](https://developer.apple.com/documentation/usernotifications)

### Permission Handler Setup:
- [permission_handler iOS Setup](https://pub.dev/packages/permission_handler#setup)
- [permission_handler Android Setup](https://pub.dev/packages/permission_handler#setup)

---

## 📋 Quick Reference

### Minimum Requirements:
- **Android:** API 29 (Android 10) or higher
- **iOS:** iOS 10.0 or higher (iOS 13+ recommended)
- **Flutter:** SDK version as specified in pubspec.yaml

### Key Files to Configure:

#### Android (3 files):
1. `android/app/src/main/AndroidManifest.xml` - Permissions & components
2. `android/app/build.gradle.kts` - Build configuration
3. `android/app/src/main/kotlin/.../MainActivity.kt` - (No changes needed)

#### iOS (4 files + Xcode):
1. `ios/Runner/Info.plist` - Permission descriptions & background modes
2. `ios/Runner/AppDelegate.swift` - Plugin callback setup
3. `ios/Podfile` - Permission handler configuration
4. `ios/Runner/Runner.entitlements` - APS environment
5. Xcode project - Background Modes capabilities

### Critical Native Setup:

| Feature | Android Requirement | iOS Requirement |
|---------|---------------------|-----------------|
| Step Counting | `ACTIVITY_RECOGNITION` | `NSMotionUsageDescription` + `PERMISSION_SENSORS=1` |
| Foreground Task | ForegroundService declaration | `SwiftFlutterForegroundTaskPlugin` callback |
| Notifications | `POST_NOTIFICATIONS` (API 33+) | `NSUserNotificationUsageDescription` + `PERMISSION_NOTIFICATIONS=1` |
| Background Execution | `FOREGROUND_SERVICE_DATA_SYNC` | Background Modes in Xcode |
| Auto-restart | `RECEIVE_BOOT_COMPLETED` | Not applicable |

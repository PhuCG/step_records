# Guideline Tích Hợp Step Counter Package cho Android

## 📋 Mục Lục
1. [Cấu Trúc Package](#cấu-trúc-package)
2. [Dependencies Cần Thiết](#dependencies-cần-thiết)
3. [Cấu Hình Android](#cấu-hình-android)
4. [Services và API](#services-và-api)
5. [Cách Tích Hợp](#cách-tích-hợp)
6. [Ví Dụ Sử Dụng](#ví-dụ-sử-dụng)

---

## 📁 Cấu Trúc Package

Tích hợp như một package module độc lập trong project chính với cấu trúc như sau:

```
your-project/
├── lib/
│   └── ...
├── packages/
│   └── step_counter/
│       ├── lib/
│       │   ├── models/
│       │   │   ├── app_state.dart
│       │   │   ├── app_state.g.dart
│       │   │   ├── step_log_entry.dart
│       │   │   └── step_log_entry.g.dart
│       │   └── services/
│       │       ├── step_counter_service.dart
│       │       ├── permission_service.dart
│       │       └── storage_service.dart
│       └── pubspec.yaml  ← Dependencies khai báo ở đây
└── ...
```

**Lợi ích của cấu trúc Package độc lập:**
- ✅ **Quản lý dependencies riêng**: Mỗi package có `pubspec.yaml` riêng, tránh conflict với project chính
- ✅ Tách biệt code hoàn toàn với `lib/`, dễ quản lý và maintain
- ✅ Có thể tái sử dụng trong các project khác
- ✅ Dễ dàng test độc lập
- ✅ Giảm nguy cơ conflict với code và dependencies của project chính

---

## 📦 Dependencies Cần Thiết

### ✅ Khuyến Nghị: Dependencies Khai Báo Trong Package

**Dependencies được khai báo trong `packages/step_counter/pubspec.yaml`**, không phải trong project chính. Điều này giúp:
- ✅ Tránh conflict với dependencies của project chính
- ✅ Package độc lập, có thể tái sử dụng
- ✅ Dễ quản lý và maintain

### Tạo pubspec.yaml cho Package

Tạo file `packages/step_counter/pubspec.yaml`:

```yaml
name: step_counter
description: Step counter package for Android using foreground service
version: 1.0.0

environment:
  sdk: ^3.9.2

dependencies:
  flutter:
    sdk: flutter
  
  # Step Counter Core Dependencies
  flutter_foreground_task: ^9.1.0
  pedometer_2: ^5.0.4
  isar_community: ^3.3.0-dev.3
  isar_community_flutter_libs: ^3.3.0-dev.3
  path_provider: ^2.1.0
  permission_handler: ^11.0.0
  connectivity_plus: ^5.0.0
  device_info_plus: ^9.1.0
  intl: ^0.18.0
  uuid: ^4.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code generation dependencies
  build_runner: ^2.4.0
  isar_community_generator: ^3.3.0-dev.3
```

### Thêm Package vào Project Chính

Trong `pubspec.yaml` của project chính (root level), thêm package như dependency local:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Step Counter Package (local)
  step_counter:
    path: packages/step_counter
```

Sau đó chạy:
```bash
# Từ root của project chính
flutter pub get

# Generate code cho package
cd packages/step_counter
flutter pub run build_runner build --delete-conflicting-outputs
cd ../..
```

### ⚠️ Lưu Ý Quan Trọng

1. **Dependencies của package** (`flutter_foreground_task`, `pedometer_2`, etc.) được khai báo trong `packages/step_counter/pubspec.yaml`
2. **Project chính** chỉ cần thêm `step_counter` như một local dependency với `path: packages/step_counter`
3. Flutter sẽ tự động resolve và merge dependencies từ cả 2 nơi
4. Nếu có conflict về version giữa package và project chính, Flutter sẽ cảnh báo và bạn cần điều chỉnh

### ✅ Xác Minh Cấu Trúc Package Hoạt Động Đúng

Để đảm bảo local package hoạt động đúng, kiểm tra các điểm sau:

#### 1. Cấu Trúc Folder Phải Đúng

```
packages/
└── step_counter/
    ├── lib/                    ← BẮT BUỘC: phải có folder lib/
    │   ├── models/
    │   └── services/
    └── pubspec.yaml            ← BẮT BUỘC: phải có pubspec.yaml ở root của package
```

**Quan trọng:** 
- Folder `lib/` là bắt buộc trong Flutter package
- Tất cả Dart code phải nằm trong `lib/`
- `pubspec.yaml` phải ở root của package (không phải trong `lib/`)

#### 2. pubspec.yaml của Package Phải Có Đúng Format

```yaml
name: step_counter              ← Tên package (dùng để import: package:step_counter/...)
description: Step counter package for Android
version: 1.0.0

environment:
  sdk: ^3.9.2

dependencies:
  flutter:
    sdk: flutter
  # ... các dependencies khác
```

**Quan trọng:** 
- Field `name:` là bắt buộc và sẽ được dùng trong import statement
- Tên package phải hợp lệ (chỉ chữ thường, số, dấu gạch dưới)

#### 3. pubspec.yaml của Project Chính Phải Reference Đúng

```yaml
dependencies:
  step_counter:
    path: packages/step_counter  ← Đường dẫn tương đối từ root project
```

**Quan trọng:**
- Đường dẫn `path:` phải tương đối từ root của project chính
- Không dùng đường dẫn tuyệt đối
- Tên dependency (`step_counter`) phải match với `name:` trong pubspec.yaml của package

#### 4. Kiểm Tra Sau Khi Setup

```bash
# 1. Từ root project, chạy pub get
flutter pub get

# 2. Kiểm tra dependencies đã được resolve
flutter pub deps | grep step_counter

# 3. Kiểm tra package có được nhận diện không
# Nếu thành công, bạn sẽ thấy step_counter trong danh sách dependencies

# 4. Generate code cho package
cd packages/step_counter
flutter pub run build_runner build --delete-conflicting-outputs
cd ../..

# 5. Nếu có lỗi, kiểm tra:
# - pubspec.yaml của package có đúng format không (dùng: flutter pub get trong folder package)
# - Đường dẫn path trong project chính có đúng không
# - Folder lib/ có tồn tại trong package không
# - Tên package có hợp lệ không
```

#### 5. Xử Lý Conflict Dependencies

Nếu project chính đã có một số dependencies với version khác:

**Cách 1: Sử dụng version chung (Khuyến nghị)**
- Điều chỉnh version trong `packages/step_counter/pubspec.yaml` để match với project chính
- Flutter sẽ tự động sử dụng version chung từ dependency graph
- Ví dụ: Nếu project chính có `permission_handler: ^11.0.0`, package cũng nên dùng `^11.0.0`

**Cách 2: Sử dụng dependency_overrides (Chỉ khi cần thiết)**
```yaml
# Trong pubspec.yaml của project chính
dependency_overrides:
  permission_handler: ^11.0.0  # Force version cụ thể
```
⚠️ Không khuyến nghị vì có thể gây vấn đề với các package khác

**Cách 3: Không khai báo trong package, chỉ khai báo trong project chính**
- Nếu muốn tránh conflict hoàn toàn, có thể chỉ khai báo dependencies trong project chính
- Package sẽ sử dụng dependencies từ project chính (transitive dependencies)
- Nhưng cách này mất đi tính độc lập của package và không khuyến nghị

#### 6. Troubleshooting Common Issues

**Issue 1: Package not found**
```
Error: Could not find package "step_counter"
```
**Giải pháp:**
- Kiểm tra đường dẫn `path:` trong pubspec.yaml của project chính
- Đảm bảo folder `packages/step_counter/` tồn tại
- Chạy `flutter pub get` lại

**Issue 2: Dependencies conflict**
```
Because step_counter depends on permission_handler ^11.0.0 and your_project depends on permission_handler ^10.0.0, version solving failed.
```
**Giải pháp:**
- Điều chỉnh version trong package để match với project chính
- Hoặc sử dụng version range rộng hơn (ví dụ: `^10.0.0 || ^11.0.0`)

**Issue 3: Import not working**
```
Error: The getter 'StepCounterService' isn't defined
```
**Giải pháp:**
- Kiểm tra import path: `package:step_counter/services/step_counter_service.dart`
- Đảm bảo file tồn tại trong `packages/step_counter/lib/services/`
- Chạy `flutter pub get` lại

---

## 🤖 Cấu Hình Android

### 1. AndroidManifest.xml Permissions

**QUAN TRỌNG:** Copy các permissions sau vào `android/app/src/main/AndroidManifest.xml` của project chính:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- ============================================ -->
    <!-- PERMISSIONS CHO STEP COUNTER SERVICE -->
    <!-- ============================================ -->
    
    <!-- Permission để đọc số bước chân -->
    <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
    
    <!-- Permissions cho Foreground Service -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    
    <!-- Permission cho Notification (Android 13+) -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <!-- Permission để tránh bị kill bởi battery optimization -->
    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
    
    <!-- Permission để tự động start service sau khi reboot -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    
    <!-- Permission để giữ device wake khi service chạy -->
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    
    <!-- Permissions cho network (nếu cần) -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- Permissions cho file storage (để lưu CSV) -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    
    <application
        android:label="your_app_name"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- ============================================ -->
        <!-- FOREGROUND SERVICE CONFIGURATION -->
        <!-- ============================================ -->
        
        <!-- Foreground service cho step counting -->
        <service
            android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
            android:foregroundServiceType="dataSync"
            android:exported="false" />
        
        <!-- Boot receiver để tự động start service sau reboot (optional) -->
        <receiver
            android:name="com.pravera.flutter_foreground_task.service.RestartReceiver"
            android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
            </intent-filter>
        </receiver>
        
        <!-- Your existing activities and other components -->
        <!-- ... -->
        
    </application>
</manifest>
```

### 2. build.gradle.kts Configuration

Đảm bảo `android/app/build.gradle.kts` có cấu hình tối thiểu:

```kotlin
android {
    namespace = "com.yourcompany.yourapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.yourcompany.yourapp"
        minSdk = 29  // ⚠️ QUAN TRỌNG: minSdk phải >= 29
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    
    // ... rest of config
}
```

**Lưu ý:** `minSdk = 29` là bắt buộc vì `ACTIVITY_RECOGNITION` permission chỉ có từ Android 10 (API 29).

---

## 🔧 Services và API

### 1. PermissionService

Service này xử lý tất cả các permissions cần thiết cho Android.

**Chức năng chính:**
- `requestAllPermissions()`: Request tất cả permissions cần thiết
- `checkAllPermissions()`: Kiểm tra xem đã có đủ permissions chưa
- `getPermissionStatus()`: Lấy trạng thái từng permission
- `requestBatteryOptimization()`: Request ignore battery optimization

**Permissions được xử lý:**
- `ACTIVITY_RECOGNITION`: Để đọc số bước chân
- `NOTIFICATION`: Để hiển thị notification (Android 13+)
- `IGNORE_BATTERY_OPTIMIZATIONS`: Để service không bị kill

### 2. StorageService

Service này quản lý local database sử dụng Isar.

**Chức năng chính:**
- `initialize()`: Khởi tạo database
- `saveAppState()` / `getAppState()`: Lưu/lấy app state
- `watchAppState()`: Stream để theo dõi thay đổi app state
- `addStepLogEntry()` / `getAllStepLogEntries()`: Quản lý step log entries
- `clearAllStepLogEntries()`: Xóa tất cả entries

### 3. StepCounterService (API Chính)

Đây là service chính cung cấp 2 endpoints chính: `start()` và `stop()`.

#### 3.1. Initialize Service

Trước khi sử dụng, cần initialize service trong `main()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  await StorageService.instance.initialize();
  
  // Initialize foreground task communication
  FlutterForegroundTask.initCommunicationPort();
  
  // Initialize step counter service
  await StepCounterService.instance.initialize();
  
  runApp(const YourApp());
}
```

#### 3.2. Configure Timer Interval (Optional)

Có thể thay đổi timer interval trước khi start service:

```dart
// Mặc định là 30 giây
StepCounterService.instance.setTimerInterval(const Duration(seconds: 30));

// Hoặc đổi thành 60 giây
StepCounterService.instance.setTimerInterval(const Duration(seconds: 60));

// Hoặc 1 phút
StepCounterService.instance.setTimerInterval(const Duration(minutes: 1));
```

#### 3.3. Start Service

```dart
Future<bool> startService({
  required String name,        // Tên driver
  required String vehicleId,   // ID của vehicle
}) async
```

**Ví dụ:**

```dart
// 1. Kiểm tra permissions trước
final hasPermissions = await PermissionService.instance.checkAllPermissions();
if (!hasPermissions) {
  final granted = await PermissionService.instance.requestAllPermissions();
  if (!granted) {
    // Handle permission denied
    return;
  }
}

// 2. Request battery optimization (recommended)
await PermissionService.instance.requestBatteryOptimization();

// 3. Start service
final success = await StepCounterService.instance.startService(
  name: 'Nguyen Van A',
  vehicleId: 'VEHICLE_001',
);

if (success) {
  print('Service started successfully');
} else {
  print('Failed to start service');
}
```

**Lưu ý:**
- Service sẽ tự động log số bước chân mỗi 30 giây (hoặc theo interval đã config)
- Service chạy trong foreground với notification
- Dữ liệu được lưu vào local database (Isar)

#### 3.4. Stop Service

```dart
Future<String?> stopService() async
```

**Return value:**
- `String?`: Path đến file CSV đã export, hoặc `null` nếu không có dữ liệu

**Ví dụ:**

```dart
final csvPath = await StepCounterService.instance.stopService();

if (csvPath != null) {
  print('CSV exported to: $csvPath');
  
  // Đọc file CSV
  final file = File(csvPath);
  final csvContent = await file.readAsString();
  print('CSV Content:\n$csvContent');
  
  // Hoặc parse CSV
  final lines = csvContent.split('\n');
  // ... process CSV data
} else {
  print('No data to export');
}
```

**Lưu ý:**
- Khi stop, service sẽ tự động export tất cả dữ liệu ra CSV file
- File CSV có format: `yyyy-MM-dd_driver_steps.csv`
- File được lưu trong `ApplicationDocumentsDirectory`
- Sau khi export, database sẽ được clear
- CSV format:
  ```csv
  time,step_number,name,vehicle_id
  2025-11-17 10:30:00,100,Nguyen Van A,VEHICLE_001
  2025-11-17 10:30:30,150,Nguyen Van A,VEHICLE_001
  ```

---

## 🔗 Cách Tích Hợp

### Bước 1: Tạo Package Structure

Tạo folder structure cho package ở root level:

```bash
mkdir -p packages/step_counter/lib/models
mkdir -p packages/step_counter/lib/services
```

### Bước 2: Tạo pubspec.yaml cho Package

Tạo file `packages/step_counter/pubspec.yaml` với nội dung như đã mô tả ở phần [Dependencies Cần Thiết](#dependencies-cần-thiết).

### Bước 3: Copy Code vào Package

Copy các file sau vào `packages/step_counter/lib/`:

```
packages/
└── step_counter/
    ├── lib/
    │   ├── models/
    │   │   ├── app_state.dart
    │   │   ├── app_state.g.dart
    │   │   ├── step_log_entry.dart
    │   │   └── step_log_entry.g.dart
    │   └── services/
    │       ├── step_counter_service.dart
    │       ├── permission_service.dart
    │       └── storage_service.dart
    └── pubspec.yaml
```

### Bước 4: Thêm Package vào Project Chính

Trong `pubspec.yaml` của project chính (root level), thêm:

```yaml
dependencies:
  step_counter:
    path: packages/step_counter
```

Sau đó chạy:
```bash
flutter pub get
```

### Bước 5: Update Import Paths

Các import paths trong code đã được thiết kế để hoạt động với cấu trúc package:

```dart
// Trong step_counter_service.dart (trong package)
import '../models/step_log_entry.dart';
import 'storage_service.dart';

// Trong storage_service.dart (trong package)
import '../models/app_state.dart';
import '../models/step_log_entry.dart';

// Khi sử dụng từ project chính (lib/)
import 'package:step_counter/services/step_counter_service.dart';
import 'package:step_counter/services/permission_service.dart';
```

Chạy build_runner để generate code cho Isar:

```bash
# Từ root của project chính
cd packages/step_counter
flutter pub run build_runner build --delete-conflicting-outputs
cd ../..
```

Hoặc từ root:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Bước 7: Cấu Hình Android

- Copy permissions vào `AndroidManifest.xml` của project chính (xem phần trên)
- Đảm bảo `minSdk >= 29` trong `build.gradle.kts` của project chính

### Bước 8: Initialize trong main()

```dart
import 'package:step_counter/services/storage_service.dart';
import 'package:step_counter/services/step_counter_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await StorageService.instance.initialize();
  FlutterForegroundTask.initCommunicationPort();
  await StepCounterService.instance.initialize();
  
  runApp(const YourApp());
}
```

### Bước 9: Sử Dụng trong Code

Xem ví dụ ở phần [Ví Dụ Sử Dụng](#ví-dụ-sử-dụng).

---

## 💡 Ví Dụ Sử Dụng

### Ví Dụ 1: Start và Stop Service Cơ Bản

```dart
import 'package:step_counter/services/step_counter_service.dart';
import 'package:step_counter/services/permission_service.dart';
import 'dart:io';

class StepCounterController {
  // Start service
  Future<void> startStepCounting(String driverName, String vehicleId) async {
    // 1. Check permissions
    final hasPermissions = await PermissionService.instance.checkAllPermissions();
    if (!hasPermissions) {
      final granted = await PermissionService.instance.requestAllPermissions();
      if (!granted) {
        throw Exception('Permissions denied');
      }
    }
    
    // 2. Request battery optimization
    await PermissionService.instance.requestBatteryOptimization();
    
    // 3. (Optional) Configure timer interval
    StepCounterService.instance.setTimerInterval(const Duration(seconds: 60));
    
    // 4. Start service
    final success = await StepCounterService.instance.startService(
      name: driverName,
      vehicleId: vehicleId,
    );
    
    if (!success) {
      throw Exception('Failed to start step counting service');
    }
  }
  
  // Stop service và lấy CSV path
  Future<String?> stopStepCounting() async {
    final csvPath = await StepCounterService.instance.stopService();
    return csvPath;
  }
  
  // Đọc CSV file
  Future<List<Map<String, dynamic>>> readCsvData(String csvPath) async {
    final file = File(csvPath);
    final lines = await file.readAsLines();
    
    if (lines.isEmpty) return [];
    
    // Skip header
    final dataLines = lines.skip(1).where((line) => line.isNotEmpty).toList();
    
    return dataLines.map((line) {
      final parts = line.split(',');
      return {
        'time': parts[0],
        'step_number': int.parse(parts[1]),
        'name': parts[2],
        'vehicle_id': parts[3],
      };
    }).toList();
  }
}
```

### Ví Dụ 2: Sử Dụng trong Widget

```dart
import 'package:flutter/material.dart';
import 'package:step_counter/services/step_counter_service.dart';
import 'package:step_counter/services/permission_service.dart';

class StepCounterWidget extends StatefulWidget {
  @override
  _StepCounterWidgetState createState() => _StepCounterWidgetState();
}

class _StepCounterWidgetState extends State<StepCounterWidget> {
  bool _isRunning = false;
  String? _csvPath;

  Future<void> _startService() async {
    // Check permissions
    final hasPermissions = await PermissionService.instance.checkAllPermissions();
    if (!hasPermissions) {
      final granted = await PermissionService.instance.requestAllPermissions();
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permissions required')),
        );
        return;
      }
    }

    // Request battery optimization
    await PermissionService.instance.requestBatteryOptimization();

    // Configure timer (optional)
    StepCounterService.instance.setTimerInterval(const Duration(seconds: 60));

    // Start service
    final success = await StepCounterService.instance.startService(
      name: 'Driver Name',
      vehicleId: 'VEHICLE_001',
    );

    if (success) {
      setState(() {
        _isRunning = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Step counting started')),
      );
    }
  }

  Future<void> _stopService() async {
    final csvPath = await StepCounterService.instance.stopService();
    
    setState(() {
      _isRunning = false;
      _csvPath = csvPath;
    });

    if (csvPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV exported to: $csvPath'),
          duration: Duration(seconds: 5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data to export')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isRunning ? _stopService : _startService,
          child: Text(_isRunning ? 'Stop' : 'Start'),
        ),
        if (_csvPath != null)
          Text('CSV Path: $_csvPath'),
      ],
    );
  }
}
```

### Ví Dụ 3: Parse CSV Data

```dart
import 'dart:io';
import 'dart:convert';

class CsvParser {
  static Future<List<StepData>> parseCsv(String csvPath) async {
    final file = File(csvPath);
    final lines = await file.readAsLines();
    
    if (lines.isEmpty) return [];
    
    // Skip header
    final dataLines = lines.skip(1).where((line) => line.isNotEmpty).toList();
    
    return dataLines.map((line) {
      final parts = line.split(',');
      return StepData(
        time: DateTime.parse(parts[0]),
        stepNumber: int.parse(parts[1]),
        name: parts[2],
        vehicleId: parts[3],
      );
    }).toList();
  }
}

class StepData {
  final DateTime time;
  final int stepNumber;
  final String name;
  final String vehicleId;

  StepData({
    required this.time,
    required this.stepNumber,
    required this.name,
    required this.vehicleId,
  });
}
```

---

## ⚠️ Lưu Ý Quan Trọng

### 1. Permissions
- **Bắt buộc:** Phải request `ACTIVITY_RECOGNITION` permission trước khi start service
- **Khuyến nghị:** Request `IGNORE_BATTERY_OPTIMIZATIONS` để service không bị kill
- **Android 13+:** Cần request `POST_NOTIFICATIONS` permission

### 2. Foreground Service
- Service chạy trong foreground với notification
- Notification không thể bị dismiss bởi user
- Service sẽ tự động restart nếu bị kill (nếu đã config)

### 3. Battery Optimization
- Một số device (Xiaomi, Huawei, etc.) có battery optimization mạnh
- Cần hướng dẫn user disable battery optimization cho app
- Có thể dùng `PermissionService.requestBatteryOptimization()` để mở settings

### 4. Timer Interval
- Mặc định: 30 giây
- Có thể thay đổi bằng `setTimerInterval()`
- Interval ngắn hơn = nhiều log hơn = tốn pin hơn
- Interval dài hơn = ít log hơn = tiết kiệm pin hơn

### 5. CSV Export
- CSV được export tự động khi stop service
- File được lưu trong `ApplicationDocumentsDirectory`
- Format: `yyyy-MM-dd_driver_steps.csv`
- Database được clear sau khi export

### 6. Testing
- Test trên device thật (không phải emulator) vì cần hardware sensor
- Test với các permission scenarios khác nhau
- Test với battery optimization enabled/disabled
- Test service restart sau khi kill app

---

## 🐛 Troubleshooting

### Service không start
- ✅ Kiểm tra permissions đã được grant chưa
- ✅ Kiểm tra `minSdk >= 29`
- ✅ Kiểm tra AndroidManifest.xml có đủ permissions và service config chưa
- ✅ Kiểm tra logcat để xem lỗi cụ thể

### Service bị kill
- ✅ Request `IGNORE_BATTERY_OPTIMIZATIONS` permission
- ✅ Hướng dẫn user disable battery optimization trong settings
- ✅ Kiểm tra notification có hiển thị không

### CSV không được export
- ✅ Kiểm tra có dữ liệu trong database không
- ✅ Kiểm tra storage permission
- ✅ Kiểm tra log để xem có lỗi không

### Timer không chạy đúng interval
- ✅ Đảm bảo gọi `setTimerInterval()` trước khi `startService()`
- ✅ Kiểm tra interval đã được set đúng chưa

---

## 📚 Tài Liệu Tham Khảo

- [flutter_foreground_task](https://pub.dev/packages/flutter_foreground_task)
- [pedometer_2](https://pub.dev/packages/pedometer_2)
- [isar_community](https://pub.dev/packages/isar_community)
- [permission_handler](https://pub.dev/packages/permission_handler)
- [Android Foreground Services](https://developer.android.com/guide/components/foreground-services)

---

## ✅ Checklist Tích Hợp

- [ ] Tạo folder structure `packages/step_counter/lib/` ở root level
- [ ] Tạo `packages/step_counter/pubspec.yaml` với dependencies
- [ ] Copy code vào package module (`packages/step_counter/lib/`)
- [ ] Thêm `step_counter` vào `pubspec.yaml` của project chính với `path: packages/step_counter`
- [ ] Chạy `flutter pub get` từ root của project chính
- [ ] Chạy `build_runner` để generate code cho package
- [ ] Copy permissions vào `AndroidManifest.xml`
- [ ] Copy service config vào `AndroidManifest.xml`
- [ ] Đảm bảo `minSdk >= 29` trong `build.gradle.kts`
- [ ] Initialize services trong `main()`
- [ ] Update import paths trong code (nếu cần)
- [ ] Implement permission request flow
- [ ] Implement start/stop service flow
- [ ] Test trên device thật
- [ ] Test với các permission scenarios
- [ ] Test CSV export và parsing

---

**Chúc bạn tích hợp thành công! 🚀**


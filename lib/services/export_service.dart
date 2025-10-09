import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'storage_service.dart';
import 'logger.dart';

enum ExportFormat { json, csv, txt }

class ExportService {
  static final ExportService _instance = ExportService._internal();
  static ExportService get instance => _instance;
  ExportService._internal();

  Future<String> exportData({
    required DateTime from,
    required DateTime to,
    required ExportFormat format,
    bool includeStepRecords = true,
    bool includeLogRecords = true,
    bool includeSessionSummaries = true,
    bool includeDeviceInfo = true,
  }) async {
    try {
      await Logger.info('EXPORT_START', {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
        'format': format.name,
      });

      // Get data from storage
      final data = await StorageService.instance.exportData(from, to);

      // Filter data based on options
      final filteredData = <String, dynamic>{
        'export_date': data['export_date'],
        'date_range': data['date_range'],
      };

      if (includeStepRecords) {
        filteredData['step_records'] = data['step_records'];
      }

      if (includeLogRecords) {
        filteredData['log_records'] = data['log_records'];
      }

      if (includeSessionSummaries) {
        filteredData['summary'] = data['summary'];
      }

      if (includeDeviceInfo) {
        filteredData['device_info'] = await _getDeviceInfo();
      }

      // Generate file content based on format
      String content;
      String extension;

      switch (format) {
        case ExportFormat.json:
          content = _exportToJson(filteredData);
          extension = 'json';
          break;
        case ExportFormat.csv:
          content = _exportToCsv(filteredData);
          extension = 'csv';
          break;
        case ExportFormat.txt:
          content = _exportToTxt(filteredData);
          extension = 'txt';
          break;
      }

      // Create export directory
      final exportDir = await StorageService.instance.getExportDirectory();
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      // Generate filename
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = 'step_counter_logs_$timestamp.$extension';
      final file = File('${exportDir.path}/$filename');

      // Write file
      await file.writeAsString(content);

      await Logger.info('EXPORT_SUCCESS', {
        'file_path': file.path,
        'file_size': await file.length(),
      });

      return file.path;
    } catch (e) {
      await Logger.error('EXPORT_ERROR', {
        'error': e.toString(),
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
        'format': format.name,
      });
      rethrow;
    }
  }

  String _exportToJson(Map<String, dynamic> data) {
    return JsonEncoder.withIndent('  ').convert(data);
  }

  String _exportToCsv(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Type,Timestamp,Data');

    // Step records
    if (data['step_records'] != null) {
      final stepRecords = data['step_records'] as List;
      for (final record in stepRecords) {
        buffer.writeln(
          'STEP,${record['timestamp']},${record['steps']},${record['delta']},${record['sessionId']}',
        );
      }
    }

    // Log records
    if (data['log_records'] != null) {
      final logRecords = data['log_records'] as List;
      for (final record in logRecords) {
        buffer.writeln(
          'LOG,${record['timestamp']},${record['level']},${record['eventType']},${record['data']}',
        );
      }
    }

    return buffer.toString();
  }

  String _exportToTxt(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    buffer.writeln('Step Counter Export Report');
    buffer.writeln('========================');
    buffer.writeln('Export Date: ${data['export_date']}');
    buffer.writeln(
      'Date Range: ${data['date_range']['from']} to ${data['date_range']['to']}',
    );
    buffer.writeln('');

    // Summary
    if (data['summary'] != null) {
      final summary = data['summary'] as Map<String, dynamic>;
      buffer.writeln('Summary:');
      buffer.writeln('--------');
      buffer.writeln('Total Steps: ${summary['total_steps']}');
      buffer.writeln('Total Records: ${summary['total_records']}');
      buffer.writeln('First Record: ${summary['first_record']}');
      buffer.writeln('Last Record: ${summary['last_record']}');
      buffer.writeln('');
    }

    // Step records
    if (data['step_records'] != null) {
      final stepRecords = data['step_records'] as List;
      buffer.writeln('Step Records:');
      buffer.writeln('-------------');
      for (final record in stepRecords) {
        final timestamp = DateTime.parse(record['timestamp']);
        buffer.writeln(
          '${dateFormat.format(timestamp)}: ${record['steps']} steps (+${record['delta']})',
        );
      }
      buffer.writeln('');
    }

    // Log records
    if (data['log_records'] != null) {
      final logRecords = data['log_records'] as List;
      buffer.writeln('Log Records:');
      buffer.writeln('------------');
      for (final record in logRecords) {
        final timestamp = DateTime.parse(record['timestamp']);
        buffer.writeln(
          '${dateFormat.format(timestamp)} [${record['level']}] ${record['eventType']}: ${record['data']}',
        );
      }
    }

    return buffer.toString();
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
        };
      }

      return {'platform': 'unknown'};
    } catch (e) {
      await Logger.error('DEVICE_INFO_ERROR', {'error': e.toString()});
      return {'platform': 'unknown', 'error': e.toString()};
    }
  }

  Future<void> shareFile(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
      await Logger.info('FILE_SHARED', {'file_path': filePath});
    } catch (e) {
      await Logger.error('FILE_SHARE_ERROR', {
        'error': e.toString(),
        'file_path': filePath,
      });
      rethrow;
    }
  }
}

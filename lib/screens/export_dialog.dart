import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/export_service.dart';

class ExportDialog extends StatefulWidget {
  final Function(DateTime from, DateTime to, ExportFormat format) onExport;

  const ExportDialog({super.key, required this.onExport});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();
  ExportFormat _selectedFormat = ExportFormat.json;
  bool _includeStepRecords = true;
  bool _includeLogRecords = true;
  bool _includeSessionSummaries = true;
  bool _includeDeviceInfo = true;

  Future<void> _selectFromDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _fromDate = date;
        if (_fromDate.isAfter(_toDate)) {
          _toDate = _fromDate;
        }
      });
    }
  }

  Future<void> _selectToDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _toDate = date;
      });
    }
  }

  void _export() {
    widget.onExport(_fromDate, _toDate, _selectedFormat);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Logs'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date range selection
            Text(
              'Date Range:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _selectFromDate,
                    child: Text(DateFormat('MMM d, yyyy').format(_fromDate)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('to'),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _selectToDate,
                    child: Text(DateFormat('MMM d, yyyy').format(_toDate)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Format selection
            Text(
              'Format:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...ExportFormat.values.map(
              (format) => RadioListTile<ExportFormat>(
                title: Text(format.name.toUpperCase()),
                subtitle: Text(_getFormatDescription(format)),
                value: format,
                groupValue: _selectedFormat,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFormat = value;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 24),

            // Include options
            Text(
              'Include:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Step records'),
              subtitle: const Text('Individual step count entries'),
              value: _includeStepRecords,
              onChanged: (value) {
                setState(() {
                  _includeStepRecords = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Log entries'),
              subtitle: const Text('System and error logs'),
              value: _includeLogRecords,
              onChanged: (value) {
                setState(() {
                  _includeLogRecords = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Session summaries'),
              subtitle: const Text('Counting session information'),
              value: _includeSessionSummaries,
              onChanged: (value) {
                setState(() {
                  _includeSessionSummaries = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Device info'),
              subtitle: const Text('Device and system information'),
              value: _includeDeviceInfo,
              onChanged: (value) {
                setState(() {
                  _includeDeviceInfo = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _export, child: const Text('Export')),
      ],
    );
  }

  String _getFormatDescription(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'Structured data format for developers';
      case ExportFormat.csv:
        return 'Spreadsheet format for data analysis';
      case ExportFormat.txt:
        return 'Human-readable text format';
    }
  }
}

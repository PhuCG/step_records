import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/step_record.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<DailyStepRecord> _allRecords = [];

  @override
  void initState() {
    super.initState();
    // Subscribe to all step records changes
    StorageService.instance.watchAllSteps().listen((records) {
      if (mounted) {
        setState(() {
          _allRecords = records;
        });
      }
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  String _formatSteps(int steps) {
    return NumberFormat('#,###').format(steps);
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return DateFormat('HH:mm').format(time);
  }

  Color _getStepColor(int steps) {
    if (steps >= 10000) return Colors.green;
    if (steps >= 5000) return Colors.orange;
    return Colors.grey;
  }

  IconData _getStepIcon(int steps) {
    if (steps >= 10000) return Icons.emoji_events;
    if (steps >= 5000) return Icons.trending_up;
    return Icons.directions_walk;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step History'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _allRecords.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No step records yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start tracking to see your history',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _allRecords.length,
              itemBuilder: (context, index) {
                final record = _allRecords[index];
                final steps = record.steps;
                final stepColor = _getStepColor(steps);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: stepColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getStepIcon(steps),
                        color: stepColor,
                        size: 32,
                      ),
                    ),
                    title: Text(
                      _formatDate(record.date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.directions_walk,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_formatSteps(steps)} steps',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Updated: ${_formatTime(record.lastUpdateTime)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatSteps(steps),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: stepColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (steps >= 10000)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Goal!',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      _showRecordDetails(record);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showRecordDetails(DailyStepRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_formatDate(record.date)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Total Steps', _formatSteps(record.steps)),
            const Divider(height: 24),
            _buildDetailRow(
              'Start Steps',
              _formatSteps(record.startSteps ?? 0),
            ),
            _buildDetailRow('End Steps', _formatSteps(record.endSteps ?? 0)),
            const Divider(height: 24),
            _buildDetailRow(
              'Last Update',
              record.lastUpdateTime != null
                  ? DateFormat(
                      'MMM d, yyyy HH:mm:ss',
                    ).format(record.lastUpdateTime!)
                  : 'Never',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

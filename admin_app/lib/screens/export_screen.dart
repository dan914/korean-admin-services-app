import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import '../ui/design_tokens.dart';
import '../providers/application_provider.dart';
import 'package:intl/intl.dart';
// Note: file_picker will be needed for web/desktop file saving

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _exportFormat = 'csv';
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final applications = ref.watch(applicationProvider);
    final filteredApplications = _getFilteredApplications(applications);

    return Scaffold(
      backgroundColor: DesignTokens.bgDefault,
      appBar: AppBar(
        title: const Text('데이터 내보내기'),
        backgroundColor: Colors.white,
        foregroundColor: DesignTokens.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: DesignTokens.borderLight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DesignTokens.primary,
                    DesignTokens.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.analytics_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '총 신청서',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${applications.length}건',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '선택된 기간',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${filteredApplications.length}건',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Export settings
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DesignTokens.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내보내기 설정',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Date range
                  Text(
                    '기간 선택',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: DesignTokens.borderLight),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: DesignTokens.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _startDate != null
                                      ? DateFormat('yyyy-MM-dd').format(_startDate!)
                                      : '시작일',
                                  style: TextStyle(
                                    color: _startDate != null
                                        ? DesignTokens.textPrimary
                                        : DesignTokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('~'),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: DesignTokens.borderLight),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: DesignTokens.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _endDate != null
                                      ? DateFormat('yyyy-MM-dd').format(_endDate!)
                                      : '종료일',
                                  style: TextStyle(
                                    color: _endDate != null
                                        ? DesignTokens.textPrimary
                                        : DesignTokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Format selection
                  Text(
                    '파일 형식',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFormatOption('csv', 'CSV', Icons.table_chart),
                      const SizedBox(width: 12),
                      _buildFormatOption('json', 'JSON', Icons.code),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Export button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _exportData,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download_rounded),
                      label: Text(_isExporting ? '내보내는 중...' : '데이터 내보내기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignTokens.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DesignTokens.info.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: DesignTokens.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '내보내기 안내',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.info,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• CSV: Excel에서 바로 열 수 있습니다\n• JSON: 개발자용 데이터 형식입니다\n• 기간을 선택하지 않으면 전체 데이터를 내보냅니다',
                          style: TextStyle(
                            fontSize: 14,
                            color: DesignTokens.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatOption(String value, String label, IconData icon) {
    final isSelected = _exportFormat == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _exportFormat = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? DesignTokens.primary.withOpacity(0.1) : Colors.white,
            border: Border.all(
              color: isSelected ? DesignTokens.primary : DesignTokens.borderLight,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? DesignTokens.primary : DesignTokens.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? DesignTokens.primary : DesignTokens.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredApplications(List<Map<String, dynamic>> applications) {
    if (_startDate == null && _endDate == null) {
      return applications;
    }

    return applications.where((app) {
      final timestamp = app['timestamp'] as String?;
      if (timestamp == null) return false;

      try {
        final date = DateTime.parse(timestamp);
        
        if (_startDate != null && date.isBefore(_startDate!)) {
          return false;
        }
        
        if (_endDate != null && date.isAfter(_endDate!.add(const Duration(days: 1)))) {
          return false;
        }
        
        return true;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);

    try {
      final applications = ref.read(applicationProvider);
      final filtered = _getFilteredApplications(applications);

      if (_exportFormat == 'csv') {
        _exportAsCSV(filtered);
      } else {
        _exportAsJSON(filtered);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${filtered.length}건의 데이터를 내보냈습니다'),
            backgroundColor: DesignTokens.success,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _exportAsCSV(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return;

    // Prepare CSV data
    final headers = [
      '이름', '전화번호', '이메일', '상태', '접수일시',
      '상담희망일', '1순위시간', '2순위시간', '메모'
    ];

    final rows = data.map((app) => [
      app['name'] ?? '',
      app['phone'] ?? '',
      app['email'] ?? '',
      _getStatusText(app['status'] ?? 'pending'),
      app['timestamp'] ?? '',
      app['reservationDate'] ?? '',
      app['firstTimeSlot'] ?? '',
      app['secondTimeSlot'] ?? '',
      app['memo'] ?? '',
    ]).toList();

    final csv = const ListToCsvConverter().convert([headers, ...rows]);
    
    // In a real app, you would save this to a file
    // For now, we'll just print it
    print('CSV Export:\n$csv');
  }

  void _exportAsJSON(List<Map<String, dynamic>> data) {
    final json = jsonEncode(data);
    
    // In a real app, you would save this to a file
    // For now, we'll just print it
    print('JSON Export:\n$json');
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return '완료';
      case 'in_progress':
        return '진행중';
      default:
        return '대기중';
    }
  }
}
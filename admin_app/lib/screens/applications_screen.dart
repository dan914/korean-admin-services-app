import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../ui/design_tokens.dart';
import '../providers/application_provider.dart';
import 'package:intl/intl.dart';
import '../utils/code_mappings.dart';

class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final applications = ref.watch(applicationProvider);
    final filteredApplications = _getFilteredApplications(applications);

    return Scaffold(
      backgroundColor: DesignTokens.bgDefault,
      appBar: AppBar(
        title: const Text('신청서 관리'),
        backgroundColor: Colors.white,
        foregroundColor: DesignTokens.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(applicationProvider.notifier).refresh(),
            tooltip: '새로고침',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: DesignTokens.borderLight,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '이름, 전화번호로 검색',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: DesignTokens.borderLight),
                      ),
                      filled: true,
                      fillColor: DesignTokens.bgAlt,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: DesignTokens.borderLight),
                    borderRadius: BorderRadius.circular(8),
                    color: DesignTokens.bgAlt,
                  ),
                  child: DropdownButton<String>(
                    value: _filterStatus,
                    underline: const SizedBox(),
                    onChanged: (value) {
                      setState(() {
                        _filterStatus = value!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('전체')),
                      DropdownMenuItem(value: 'pending', child: Text('대기중')),
                      DropdownMenuItem(value: 'in_progress', child: Text('진행중')),
                      DropdownMenuItem(value: 'completed', child: Text('완료')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Applications list
          Expanded(
            child: filteredApplications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: DesignTokens.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '검색 결과가 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: DesignTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredApplications.length,
                    itemBuilder: (context, index) {
                      final app = filteredApplications[index];
                      return _buildApplicationCard(app, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> app, int index) {
    final status = app['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: DesignTokens.borderLight),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            _getStatusIcon(status),
            color: statusColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                app['name'] ?? '이름 없음',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(app['phone'] ?? '전화번호 없음'),
            if (app['form_data']?['step_4'] != null) 
              Text(
                '서비스: ${CodeMappings.getServiceTypeLabel(app['form_data']?['step_4'])}',
                style: TextStyle(
                  fontSize: 12,
                  color: DesignTokens.textSecondary,
                ),
              ),
            if (app['form_data']?['step_9'] != null)
              Text(
                '상담방식: ${CodeMappings.getStepLabel(9, app['form_data']?['step_9'])}',
                style: TextStyle(
                  fontSize: 12,
                  color: DesignTokens.textSecondary,
                ),
              ),
            if (app['form_data']?['reservationDate'] != null)
              Text(
                '예약: ${_formatDate(app['form_data']?['reservationDate'])}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DesignTokens.bgAlt,
              border: Border(
                top: BorderSide(color: DesignTokens.borderLight),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // All 10 Wizard Steps Section
                Text(
                  '신청 내용 (10단계 답변)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                // Display all 10 steps
                for (int i = 1; i <= 10; i++) ...[
                  _buildDetailRow(
                    '${i}. ${CodeMappings.getStepTitle(i)}',
                    CodeMappings.getStepLabel(i, app['form_data']?['step_$i']),
                  ),
                ],
                const Divider(height: 24),
                
                // Consultation Reservation Section
                if (app['form_data']?['reservationDate'] != null) ...[
                  Text(
                    '상담 예약',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('예약 날짜', _formatDate(app['form_data']?['reservationDate'])),
                  _buildDetailRow('1차 희망 시간', app['form_data']?['firstTimeSlot'] ?? '-'),
                  _buildDetailRow('2차 희망 시간', app['form_data']?['secondTimeSlot'] ?? '-'),
                  const Divider(height: 24),
                ],
                
                // Contact Information Section
                Text(
                  '연락처 정보',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('이메일', app['email'] ?? '-'),
                _buildDetailRow('접수일시', _formatDate(app['created_at'])),
                _buildDetailRow('알림 설정', _getNotificationPreferences(app)),
                const SizedBox(height: 16),
                
                // Description Section
                if ((app['description'] != null && app['description'].toString().isNotEmpty) || 
                    (app['form_data']?['description'] != null && app['form_data']['description'].toString().isNotEmpty)) ...[
                  Text(
                    '상세 설명',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: DesignTokens.borderLight),
                    ),
                    child: Text(app['description'] ?? app['form_data']?['description'] ?? app['form_data']?['memo'] ?? ''),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Memo section
                if (app['memo'] != null && app['memo'].isNotEmpty) ...[
                  Text(
                    '메모',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: DesignTokens.borderLight),
                    ),
                    child: Text(app['memo']),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus(index, 'in_progress'),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('진행중'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignTokens.warning,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus(index, 'completed'),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('완료'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignTokens.success,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _deleteApplication(index),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: DesignTokens.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: DesignTokens.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredApplications(List<Map<String, dynamic>> applications) {
    return applications.where((app) {
      // Status filter
      if (_filterStatus != 'all' && app['status'] != _filterStatus) {
        return false;
      }
      
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (app['name'] ?? '').toLowerCase();
        final phone = (app['phone'] ?? '').toLowerCase();
        final email = (app['email'] ?? '').toLowerCase();
        
        return name.contains(query) || phone.contains(query) || email.contains(query);
      }
      
      return true;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return DesignTokens.success;
      case 'in_progress':
        return DesignTokens.warning;
      default:
        return DesignTokens.textSecondary;
    }
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.pending;
      default:
        return Icons.schedule;
    }
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null) return '-';
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      return timestamp;
    }
  }

  String _getNotificationPreferences(Map<String, dynamic> app) {
    List<String> prefs = [];
    if (app['notification_kakao'] == true) prefs.add('카카오톡');
    if (app['notification_sms'] == true) prefs.add('SMS');
    if (app['notification_email'] == true) prefs.add('이메일');
    return prefs.isEmpty ? '없음' : prefs.join(', ');
  }

  void _updateStatus(int index, String status) {
    ref.read(applicationProvider.notifier).updateApplicationStatus(index, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('상태가 ${_getStatusText(status)}(으)로 변경되었습니다'),
        backgroundColor: _getStatusColor(status),
      ),
    );
  }

  void _deleteApplication(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('신청서 삭제'),
        content: const Text('이 신청서를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(applicationProvider.notifier).deleteApplication(index);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('신청서가 삭제되었습니다'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
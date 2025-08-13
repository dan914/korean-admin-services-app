import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';
import '../services/answer_formatter.dart';
import '../models/lead.dart';
import '../ui/design_tokens.dart';
import '../config/env.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final _adminService = AdminService();
  List<Lead> _leads = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String _selectedStatus = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        _adminService.getLeads(
          status: _selectedStatus,
          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        ),
        _adminService.getLeadStats(),
      ]);
      
      setState(() {
        _leads = results[0] as List<Lead>;
        _stats = results[1] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('죄송합니다. 데이터를 불러오는 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  Future<void> _updateLeadStatus(String leadId, String newStatus) async {
    try {
      await _adminService.updateLeadStatus(leadId, newStatus);
      _loadData(); // Refresh data
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상태가 성공적으로 업데이트되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('죄송합니다. 상태 업데이트 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('행정도우미 관리자'),
        backgroundColor: DesignTokens.primary,
        foregroundColor: Colors.white,
        actions: [
          if (!Env.isConfigured)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'OFFLINE',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: const CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(DesignTokens.spacingBase),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(),
                  SizedBox(height: DesignTokens.spacingSection),
                  _buildFiltersAndSearch(),
                  SizedBox(height: DesignTokens.spacingBase),
                  _buildLeadsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(DesignTokens.spacingBase),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 리드 현황',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: DesignTokens.spacingBase),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatItem('전체', _stats['total'] ?? 0, Colors.blue),
                _buildStatItem('대기중', _stats['pending'] ?? 0, Colors.orange),
                _buildStatItem('진행중', _stats['in_progress'] ?? 0, Colors.green),
                _buildStatItem('완료', _stats['completed'] ?? 0, Colors.purple),
                _buildStatItem('취소', _stats['cancelled'] ?? 0, Colors.red),
                _buildStatItem('최근 7일', _stats['recent_week'] ?? 0, Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(DesignTokens.spacingBase),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '이름, 이메일, 전화번호로 검색...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      setState(() => _searchQuery = value);
                      _loadData();
                    },
                  ),
                ),
                SizedBox(width: DesignTokens.spacingBase),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _searchQuery = _searchController.text);
                    _loadData();
                  },
                  child: const Text('검색'),
                ),
              ],
            ),
            SizedBox(height: DesignTokens.spacingBase),
            Row(
              children: [
                const Text('상태 필터: '),
                SizedBox(width: DesignTokens.spacingBase),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('전체')),
                    DropdownMenuItem(value: 'pending', child: Text('대기중')),
                    DropdownMenuItem(value: 'in_progress', child: Text('진행중')),
                    DropdownMenuItem(value: 'completed', child: Text('완료')),
                    DropdownMenuItem(value: 'cancelled', child: Text('취소')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value!);
                    _loadData();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadsList() {
    if (_leads.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('조건에 맞는 리드가 없습니다.'),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(DesignTokens.spacingBase),
            child: Text(
              '📋 리드 목록 (${_leads.length}개)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _leads.length,
            itemBuilder: (context, index) {
              final lead = _leads[index];
              return _buildLeadCard(lead);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(Lead lead) {
    final statusColor = _getStatusColor(lead.status);
    final priorityColor = _getPriorityColor(lead.priority);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingBase,
        vertical: DesignTokens.spacingSmall,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: DesignTokens.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                lead.contactInfo.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusLabel(lead.status),
                style: TextStyle(color: statusColor, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getPriorityLabel(lead.priority),
                style: TextStyle(color: priorityColor, fontSize: 12),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📧 ${lead.contactInfo.email}'),
            Text('📞 ${lead.contactInfo.phone}'),
            Text('🕒 ${_formatDateTime(lead.createdAt)}'),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(DesignTokens.spacingBase),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📝 설문 응답:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: DesignTokens.spacingSmall),
                ...AnswerFormatter.formatAllAnswers(lead.formData).entries.map((e) => 
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            e.key,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            e.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: DesignTokens.spacingBase),
                const Text('🔔 알림 설정:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('카카오톡: ${lead.contactInfo.notificationPreferences.kakao ? "허용" : "차단"}'),
                Text('SMS: ${lead.contactInfo.notificationPreferences.sms ? "허용" : "차단"}'),
                Text('이메일: ${lead.contactInfo.notificationPreferences.email ? "허용" : "차단"}'),
                SizedBox(height: DesignTokens.spacingBase),
                if (Env.isConfigured) _buildStatusUpdateButtons(lead),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateButtons(Lead lead) {
    final statuses = ['pending', 'in_progress', 'completed', 'cancelled'];
    return Wrap(
      spacing: 8,
      children: statuses.where((s) => s != lead.status).map((status) {
        return ElevatedButton(
          onPressed: () => _updateLeadStatus(lead.id, status),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getStatusColor(status),
            foregroundColor: Colors.white,
          ),
          child: Text(_getStatusLabel(status)),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'in_progress': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high': return Colors.red;
      case 'normal': return Colors.blue;
      case 'low': return Colors.grey;
      default: return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending': return '대기중';
      case 'in_progress': return '진행중';
      case 'completed': return '완료';
      case 'cancelled': return '취소';
      default: return status;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'high': return '높음';
      case 'normal': return '보통';
      case 'low': return '낮음';
      default: return priority;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
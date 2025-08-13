import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../services/answer_formatter.dart';
import '../ui/design_tokens.dart';
import '../config/env.dart';

class SimpleAdminScreen extends ConsumerStatefulWidget {
  const SimpleAdminScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SimpleAdminScreen> createState() => _SimpleAdminScreenState();
}

class _SimpleAdminScreenState extends ConsumerState<SimpleAdminScreen> {
  List<Map<String, dynamic>> leads = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    if (!Env.isConfigured) {
      setState(() {
        leads = [
          {
            'id': '1',
            'contact_info': {'name': '홍길동', 'email': 'test@example.com', 'phone': '010-1234-5678'},
            'form_data': {
              'step_1': 'relief',
              'step_2': '1010000', 
              'step_3': 'notice',
              'step_4': 'penalty',
              'step_4_penalty_0': 'food',
              'step_5': '1',
              'memo': '추가 상황 설명입니다.'
            },
            'status': 'pending',
            'created_at': '2024-01-01T10:00:00Z',
          },
        ];
      });
      return;
    }

    setState(() => isLoading = true);
    
    try {
      final result = await SupabaseService().getLeads(limit: 50);
      setState(() {
        leads = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로드 오류: $e')),
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
            onPressed: _loadLeads,
          ),
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildLeadsList(),
    );
  }

  Widget _buildLeadsList() {
    if (leads.isEmpty) {
      return const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text('리드가 없습니다.'),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(DesignTokens.spacingBase),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final lead = leads[index];
        final contactInfo = lead['contact_info'] as Map<String, dynamic>? ?? {};
        final formData = lead['form_data'] as Map<String, dynamic>? ?? {};
        
        return Card(
          margin: EdgeInsets.only(bottom: DesignTokens.spacingBase),
          child: ExpansionTile(
            title: Text(
              contactInfo['name']?.toString() ?? '이름 없음',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📧 ${contactInfo['email'] ?? '없음'}'),
                Text('📞 ${contactInfo['phone'] ?? '없음'}'),
                Text('📊 상태: ${_getStatusLabel(lead['status'])}'),
                Text('📅 등록일: ${_formatDate(lead['created_at'])}'),
              ],
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(DesignTokens.spacingBase),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 설문 응답 내용',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: DesignTokens.spacingBase),
                    Container(
                      width: double.infinity,
                      child: Column(
                        children: _buildFormDataCards(formData),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(dynamic dateTime) {
    if (dateTime == null) return '알 수 없음';
    try {
      final dt = DateTime.parse(dateTime.toString());
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '알 수 없음';
    }
  }

  String _getStatusLabel(dynamic status) {
    switch (status?.toString()) {
      case 'pending': return '대기중';
      case 'in_progress': return '진행중';
      case 'completed': return '완료';
      case 'cancelled': return '취소';
      default: return '대기중';
    }
  }

  List<Widget> _buildFormDataCards(Map<String, dynamic> formData) {
    if (formData.isEmpty) {
      return [
        Container(
          padding: EdgeInsets.all(DesignTokens.spacingBase),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('폼 데이터가 없습니다.'),
        ),
      ];
    }

    List<Widget> cards = [];
    
    // Process main steps and sub-steps
    for (int stepId = 1; stepId <= 10; stepId++) {
      final stepKey = 'step_$stepId';
      final answer = formData[stepKey];
      
      if (answer != null) {
        final answerText = AnswerFormatter.formatAnswer(stepKey, answer);
        cards.add(_buildAnswerCard('$stepId번 질문', answerText));
        
        // Check for sub-steps (step 4 penalty questions)
        if (stepId == 4 && answer == 'penalty') {
          for (int subIndex = 0; subIndex < 5; subIndex++) {
            final subStepKey = 'step_4_penalty_$subIndex';
            final subAnswer = formData[subStepKey];
            if (subAnswer != null) {
              final subAnswerText = AnswerFormatter.formatAnswer(subStepKey, subAnswer);
              cards.add(_buildAnswerCard('4-${subIndex + 1}번 추가 질문', subAnswerText));
            }
          }
        }
      }
    }
    
    // Add memo if exists
    final memo = formData['memo'];
    if (memo != null && memo.toString().isNotEmpty) {
      cards.add(_buildAnswerCard('📝 메모', memo.toString()));
    }
    
    // Add documents if exists
    final documents = formData['documents'];
    if (documents != null) {
      if (documents is List && documents.isNotEmpty) {
        final docText = documents.map((doc) => doc['name'] ?? '파일').join(', ');
        cards.add(_buildAnswerCard('📎 첨부파일', '${documents.length}개 파일: $docText'));
      }
    }
    
    return cards;
  }

  Widget _buildAnswerCard(String question, String answer) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: DesignTokens.spacingSmall),
      padding: EdgeInsets.all(DesignTokens.spacingBase),
      constraints: const BoxConstraints(
        minHeight: 80, // Minimum height for consistency
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            child: Text(
              question,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          SizedBox(height: DesignTokens.spacingSmall),
          Container(
            width: double.infinity,
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4, // Better line height for readability
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
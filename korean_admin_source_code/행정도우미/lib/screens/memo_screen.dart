import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/wizard_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/step_card.dart';
import '../widgets/document_upload.dart';
import '../ui/design_tokens.dart';

class MemoScreen extends ConsumerStatefulWidget {
  const MemoScreen({super.key});

  @override
  ConsumerState<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends ConsumerState<MemoScreen> {
  final _memoController = TextEditingController();
  List<PlatformFile> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    // Load existing memo if available
    final wizardState = ref.read(wizardProvider);
    final existingMemo = wizardState.answers['memo'] as String?;
    if (existingMemo != null && existingMemo.isNotEmpty) {
      _memoController.text = existingMemo;
    }
    
    // Load existing files if available
    final existingFiles = wizardState.answers['documents'] as List<PlatformFile>?;
    if (existingFiles != null) {
      _selectedFiles = existingFiles;
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  void _saveMemo() {
    ref.read(wizardProvider.notifier).setAnswer('memo', _memoController.text);
  }
  
  void _saveDocuments() {
    ref.read(wizardProvider.notifier).setAnswer('documents', _selectedFiles);
  }
  
  void _onFilesSelected(List<PlatformFile> files) {
    setState(() {
      _selectedFiles = files;
    });
    _saveDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('행정도우미'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/summary'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(DesignTokens.spacingBase),
                child: StepCard(
                  stepNumber: '추가',
                  title: '상황에 대해 자세히 알려주시겠어요?',
                  subtitle: '선택사항 - 보다 정확한 상담을 위해 추가 정보를 입력해 주세요',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '어떤 내용이든 자유롭게 작성해 주시기 바랍니다:',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: DesignTokens.spacingBase),
                      Text(
                        '• 구체적인 상황이나 배경 설명\n'
                        '• 겪고 있는 어려움이나 문제점\n'
                        '• 원하는 결과나 목표\n'
                        '• 기타 상담에 도움이 될 정보',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: DesignTokens.spacingSection),
                      TextField(
                        controller: _memoController,
                        maxLines: 8,
                        maxLength: 1000,
                        decoration: InputDecoration(
                          hintText: '예) 작년부터 운영하던 카페에 갑자기 영업정지 통보가 왔는데, 어떤 문제인지 정확히 모르겠고 어떻게 대응해야 할지 막막합니다. 빨리 해결해서 다시 영업을 시작하고 싶습니다.',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
                          ),
                          filled: true,
                          fillColor: DesignTokens.bgAlt,
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                        onChanged: (value) => _saveMemo(),
                      ),
                      SizedBox(height: DesignTokens.spacingBase),
                      Container(
                        padding: EdgeInsets.all(DesignTokens.spacingBase),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            SizedBox(width: DesignTokens.spacingBase),
                            Expanded(
                              child: Text(
                                '이 정보는 행정사가 보다 정확한 상담을 준비하는 데 도움이 됩니다. 작성하지 않으셔도 다음 단계로 진행하실 수 있습니다.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: DesignTokens.spacingSection),
                      DocumentUpload(
                        selectedFiles: _selectedFiles,
                        onFilesSelected: _onFilesSelected,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacingBase),
      decoration: BoxDecoration(
        color: DesignTokens.bgAlt,
        border: Border(
          top: BorderSide(color: DesignTokens.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: '건너뛰기',
              variant: AppButtonVariant.outline,
              onPressed: () => context.go('/reservation'),
            ),
          ),
          SizedBox(width: DesignTokens.spacingBase),
          Expanded(
            flex: 2,
            child: AppButton(
              label: '다음',
              onPressed: () {
                _saveMemo();
                context.go('/reservation');
              },
            ),
          ),
        ],
      ),
    );
  }
}
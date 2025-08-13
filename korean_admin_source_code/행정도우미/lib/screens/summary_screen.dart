import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../data/steps.dart';
import '../providers/wizard_provider.dart';
import '../services/answer_formatter.dart';
import '../services/document_service.dart';
import '../widgets/answer_card.dart';
import '../widgets/app_button.dart';
import '../ui/design_tokens.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(wizardProvider);
    final answers = wizardState.answers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('입력 내용 확인'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(DesignTokens.spacingBase),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '입력하신 내용을 확인해주세요',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: DesignTokens.spacingBase),
                  Text(
                    '수정이 필요한 항목은 수정 버튼을 눌러주세요',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  SizedBox(height: DesignTokens.spacingSection),
                  ..._buildAnswerCards(context, ref, answers),
                  _buildMemoCard(context, ref, answers),
                  _buildDocumentCard(context, ref, answers),
                  // Add extra space at the bottom to ensure scrolling works
                  SizedBox(height: DesignTokens.spacingSection * 2),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(DesignTokens.spacingBase),
            decoration: BoxDecoration(
              color: DesignTokens.bgAlt,
              border: Border(
                top: BorderSide(color: DesignTokens.border),
              ),
            ),
            child: AppButton(
              label: '연락처 입력하기',
              onPressed: () => context.go('/contact'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnswerCards(BuildContext context, WidgetRef ref, Map<String, dynamic> answers) {
    final List<Widget> cards = [];
    
    print('📋 Building answer cards from answers: $answers');
    
    // Process main steps 1-10
    for (int stepId = 1; stepId <= 10; stepId++) {
      final step = WizardSteps.getStepById(stepId);
      if (step == null) continue;
      
      final stepKey = 'step_$stepId';
      final answer = answers[stepKey];
      
      if (answer != null) {
        final answerText = AnswerFormatter.formatAnswer(stepKey, answer);
        
        cards.add(
          Padding(
            padding: EdgeInsets.only(bottom: DesignTokens.spacingBase),
            child: AnswerCard(
              stepNumber: stepId.toString(),
              question: step.title,
              answer: answerText,
              onEdit: () {
                ref.read(wizardProvider.notifier).goToStep(stepId);
                context.pop();
              },
            ),
          ),
        );
        
        // Add sub-step answers for step 4
        if (stepId == 4 && step.subSteps != null) {
          final subSteps = step.subSteps![answer];
          if (subSteps != null) {
            for (int subIndex = 0; subIndex < subSteps.length; subIndex++) {
              final subStep = subSteps[subIndex];
              final subStepKey = 'step_4_${answer}_$subIndex';
              final subAnswer = answers[subStepKey];
              
              if (subAnswer != null) {
                final subAnswerText = AnswerFormatter.formatAnswer(subStepKey, subAnswer);
                
                cards.add(
                  Padding(
                    padding: EdgeInsets.only(bottom: DesignTokens.spacingBase),
                    child: AnswerCard(
                      stepNumber: '4-${subIndex + 1}',
                      question: subStep.title,
                      answer: subAnswerText,
                      onEdit: () {
                        ref.read(wizardProvider.notifier).goToStep(stepId);
                        context.pop();
                      },
                    ),
                  ),
                );
              }
            }
          }
        }
      }
    }
    
    print('📊 Built ${cards.length} answer cards');
    return cards;
  }

  Widget _buildMemoCard(BuildContext context, WidgetRef ref, Map<String, dynamic> answers) {
    final memo = answers['memo'] as String?;
    final hasContent = memo != null && memo.isNotEmpty;
    
    return Padding(
      padding: EdgeInsets.only(bottom: DesignTokens.spacingBase),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(DesignTokens.spacingBase),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: hasContent ? DesignTokens.primary.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '추가',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: hasContent ? DesignTokens.primary : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: DesignTokens.spacingBase),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '상황에 대한 메모',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          hasContent ? '작성됨' : '작성하지 않음',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: hasContent ? DesignTokens.primary : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.go('/memo'),
                    icon: Icon(
                      hasContent ? Icons.edit : Icons.add,
                      size: 16,
                    ),
                    label: Text(hasContent ? '수정' : '작성'),
                    style: TextButton.styleFrom(
                      foregroundColor: DesignTokens.primary,
                    ),
                  ),
                ],
              ),
              if (hasContent) ...[
                SizedBox(height: DesignTokens.spacingBase),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(DesignTokens.spacingBase),
                  decoration: BoxDecoration(
                    color: DesignTokens.bgAlt,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: DesignTokens.border),
                  ),
                  child: Text(
                    memo!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, WidgetRef ref, Map<String, dynamic> answers) {
    final documents = answers['documents'] as List<PlatformFile>?;
    final hasDocuments = documents != null && documents.isNotEmpty;
    
    return Padding(
      padding: EdgeInsets.only(bottom: DesignTokens.spacingBase),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(DesignTokens.spacingBase),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: hasDocuments ? DesignTokens.primary.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.attach_file,
                        size: 16,
                        color: hasDocuments ? DesignTokens.primary : Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(width: DesignTokens.spacingBase),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '첨부 서류',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          hasDocuments ? '${documents.length}개 파일 첨부됨' : '첨부된 파일 없음',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: hasDocuments ? DesignTokens.primary : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.go('/memo'),
                    icon: Icon(
                      hasDocuments ? Icons.edit : Icons.add,
                      size: 16,
                    ),
                    label: Text(hasDocuments ? '수정' : '추가'),
                    style: TextButton.styleFrom(
                      foregroundColor: DesignTokens.primary,
                    ),
                  ),
                ],
              ),
              if (hasDocuments) ...[
                SizedBox(height: DesignTokens.spacingBase),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(DesignTokens.spacingBase),
                  decoration: BoxDecoration(
                    color: DesignTokens.bgAlt,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: DesignTokens.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: documents.map((file) => Padding(
                      padding: EdgeInsets.only(bottom: DesignTokens.spacingSmall),
                      child: Row(
                        children: [
                          Text(
                            DocumentService.getFileIcon(file.name),
                            style: const TextStyle(fontSize: 20),
                          ),
                          SizedBox(width: DesignTokens.spacingSmall),
                          Expanded(
                            child: Text(
                              file.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            DocumentService.getFileSizeString(file.size),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

}
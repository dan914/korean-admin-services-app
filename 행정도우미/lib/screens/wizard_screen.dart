import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/steps.dart';
import '../providers/wizard_provider.dart';
import '../widgets/progress_bar.dart';
import '../widgets/step_card.dart';
import '../widgets/radio_option.dart';
import '../widgets/app_button.dart';
import '../ui/design_tokens.dart';

class WizardScreen extends ConsumerStatefulWidget {
  const WizardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends ConsumerState<WizardScreen> {
  @override
  Widget build(BuildContext context) {
    final wizardState = ref.watch(wizardProvider);
    final wizardNotifier = ref.read(wizardProvider.notifier);
    final currentStep = wizardNotifier.getCurrentStep();
    final currentSubStep = wizardNotifier.getCurrentSubStep();

    if (currentStep == null) {
      return Scaffold(
        backgroundColor: DesignTokens.bgDefault,
        body: Center(
          child: Text(
            '오류가 발생했습니다',
            style: TextStyle(
              fontSize: DesignTokens.fontLg,
              color: DesignTokens.textSecondary,
            ),
          ),
        ),
      );
    }

    final stepKey = wizardNotifier.getCurrentStepKey();
    final currentAnswer = wizardState.answers[stepKey];
    final stepNumber = wizardNotifier.getCurrentStepNumber();
    final totalSteps = wizardNotifier.getTotalSteps();
    final isLastStep = wizardNotifier.isLastStep();
    
    // Use sub-step if available, otherwise main step
    final displayTitle = currentSubStep?.title ?? currentStep.title;
    final displayOptions = currentSubStep?.options ?? currentStep.options;

    return Scaffold(
      backgroundColor: DesignTokens.bgDefault,
      body: SafeArea(
        child: Column(
          children: [
            // Mobile App Bar with Progress
            _buildMobileHeader(
              stepNumber: stepNumber,
              totalSteps: totalSteps,
              canGoBack: wizardState.stepHistory.length > 1 || wizardState.isInSubStep,
              onBack: () => wizardNotifier.previousStep(),
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(DesignTokens.spacingBase),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestionCard(
                      stepNumber: wizardState.isInSubStep 
                          ? '$stepNumber-${wizardState.currentSubStepIndex + 1}'
                          : stepNumber.toString(),
                      title: displayTitle,
                      subtitle: wizardState.isInSubStep ? '세부 선택' : null,
                      currentStep: stepNumber,
                      totalSteps: totalSteps,
                    ),
                    SizedBox(height: DesignTokens.spacingXl),
                    _buildOptionsGrid(displayOptions, currentAnswer, stepKey),
                  ],
                ),
              ),
            ),
            // Fixed Bottom Navigation
            _buildFixedBottomNavigation(
              currentAnswer: currentAnswer,
              isLastStep: isLastStep,
              onNext: () {
                print('🎯 Button pressed - isLastStep: $isLastStep, stepNumber: $stepNumber, totalSteps: $totalSteps');
                print('📍 Current step: $stepNumber/${totalSteps}');
                print('📋 Current answer: $currentAnswer');
                if (isLastStep) {
                  print('✅ This is the last step, navigating to memo');
                  context.go('/memo');
                } else {
                  print('➡️ Not the last step, going to next step');
                  ref.read(wizardProvider.notifier).nextStep();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader({
    required int stepNumber,
    required int totalSteps,
    required bool canGoBack,
    required VoidCallback onBack,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        DesignTokens.spacingBase,
        DesignTokens.spacingSm,
        DesignTokens.spacingBase,
        DesignTokens.spacingBase,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.bgAlt,
        border: Border(
          bottom: BorderSide(color: DesignTokens.borderLight, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with back button and title
          Row(
            children: [
              if (canGoBack)
                Container(
                  decoration: BoxDecoration(
                    color: DesignTokens.bgDefault,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  ),
                  child: IconButton(
                    onPressed: onBack,
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: DesignTokens.textPrimary,
                    ),
                    padding: EdgeInsets.all(DesignTokens.spacingSm),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
              if (canGoBack) SizedBox(width: DesignTokens.spacingBase),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '행정도우미',
                      style: TextStyle(
                        fontSize: DesignTokens.fontLg,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    Text(
                      '질문 $stepNumber / $totalSteps',
                      style: TextStyle(
                        fontSize: DesignTokens.fontSm,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Progress indicator
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingBase,
                  vertical: DesignTokens.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.primaryLight,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
                child: Text(
                  '${((stepNumber / totalSteps) * 100).round()}%',
                  style: TextStyle(
                    fontSize: DesignTokens.fontSm,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.primary,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: DesignTokens.spacingBase),
          
          // Progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: DesignTokens.borderLight,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: stepNumber / totalSteps,
              child: Container(
                decoration: BoxDecoration(
                  color: DesignTokens.primary,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard({
    required String stepNumber,
    required String title,
    String? subtitle,
    required int currentStep,
    required int totalSteps,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DesignTokens.spacingXl),
      decoration: BoxDecoration(
        color: DesignTokens.bgCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: DesignTokens.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingBase,
                  vertical: DesignTokens.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.primary,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
                child: Text(
                  'Q$stepNumber',
                  style: TextStyle(
                    fontSize: DesignTokens.fontSm,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(width: DesignTokens.spacingBase),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingBase,
                    vertical: DesignTokens.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.secondaryLight,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: DesignTokens.fontSm,
                      fontWeight: FontWeight.w500,
                      color: DesignTokens.secondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          SizedBox(height: DesignTokens.spacingLg),
          
          Text(
            title,
            style: TextStyle(
              fontSize: DesignTokens.fontXl,
              fontWeight: FontWeight.bold,
              color: DesignTokens.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(List<StepOption> options, dynamic currentAnswer, String stepKey) {
    return Column(
      children: options.map((option) {
        final isSelected = currentAnswer == option.code;
        final isUnknown = option.code == 'UNK';
        
        return Padding(
          padding: EdgeInsets.only(bottom: DesignTokens.spacingBase),
          child: _buildMobileOption(
            option: option,
            isSelected: isSelected,
            isUnknown: isUnknown,
            onTap: () {
              ref.read(wizardProvider.notifier).setAnswer(stepKey, option.code);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileOption({
    required StepOption option,
    required bool isSelected,
    required bool isUnknown,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(DesignTokens.spacingLg),
        decoration: BoxDecoration(
          color: isSelected 
              ? DesignTokens.primaryLight 
              : DesignTokens.bgCard,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(
            color: isSelected 
                ? DesignTokens.primary 
                : (isUnknown ? DesignTokens.warning : DesignTokens.borderLight),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: DesignTokens.primary.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Selection indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected 
                    ? DesignTokens.primary 
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected 
                      ? DesignTokens.primary 
                      : DesignTokens.borderLight,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isSelected 
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            
            SizedBox(width: DesignTokens.spacingBase),
            
            // Option text
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: DesignTokens.fontBase,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? DesignTokens.primary 
                      : DesignTokens.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            
            // Unknown indicator
            if (isUnknown)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingSm,
                  vertical: DesignTokens.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Text(
                  '잘 모르겠어요',
                  style: TextStyle(
                    fontSize: DesignTokens.fontXs,
                    color: DesignTokens.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedBottomNavigation({
    required dynamic currentAnswer,
    required bool isLastStep,
    required VoidCallback onNext,
  }) {
    final canProceed = currentAnswer != null && currentAnswer.toString().isNotEmpty;
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        DesignTokens.spacingBase,
        DesignTokens.spacingBase,
        DesignTokens.spacingBase,
        DesignTokens.spacingBase + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.bgAlt,
        border: Border(
          top: BorderSide(color: DesignTokens.borderLight, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!canProceed) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingBase,
                vertical: DesignTokens.spacingSm,
              ),
              decoration: BoxDecoration(
                color: DesignTokens.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusBase),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    color: DesignTokens.info,
                    size: 16,
                  ),
                  SizedBox(width: DesignTokens.spacingSm),
                  Text(
                    '답변을 선택해주세요',
                    style: TextStyle(
                      fontSize: DesignTokens.fontSm,
                      color: DesignTokens.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: DesignTokens.spacingBase),
          ],
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: canProceed ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: DesignTokens.textMuted.withOpacity(0.3),
                elevation: canProceed ? DesignTokens.elevationMedium : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastStep ? '질문 완료' : '다음 질문',
                    style: TextStyle(
                      fontSize: DesignTokens.fontLg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: DesignTokens.spacingSm),
                  Icon(
                    isLastStep ? Icons.check_rounded : Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
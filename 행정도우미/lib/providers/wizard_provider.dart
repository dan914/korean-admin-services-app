import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/steps.dart';
import '../utils/logger.dart';

class WizardState {
  final int currentStepId;
  final String? currentSubStepKey; // For step 4 sub-steps
  final int currentSubStepIndex; // For multi-substep navigation
  final Map<String, dynamic> answers;
  final List<int> stepHistory;
  final bool isLoading;
  final bool hasConsentAgreed;
  final DateTime? consentTimestamp;

  WizardState({
    required this.currentStepId,
    this.currentSubStepKey,
    this.currentSubStepIndex = 0,
    required this.answers,
    required this.stepHistory,
    this.isLoading = false,
    this.hasConsentAgreed = false,
    this.consentTimestamp,
  });

  WizardState copyWith({
    int? currentStepId,
    String? Function()? currentSubStepKey,
    int? currentSubStepIndex,
    Map<String, dynamic>? answers,
    List<int>? stepHistory,
    bool? isLoading,
    bool? hasConsentAgreed,
    DateTime? consentTimestamp,
  }) {
    return WizardState(
      currentStepId: currentStepId ?? this.currentStepId,
      currentSubStepKey: currentSubStepKey != null ? currentSubStepKey() : this.currentSubStepKey,
      currentSubStepIndex: currentSubStepIndex ?? this.currentSubStepIndex,
      answers: answers ?? this.answers,
      stepHistory: stepHistory ?? this.stepHistory,
      isLoading: isLoading ?? this.isLoading,
      hasConsentAgreed: hasConsentAgreed ?? this.hasConsentAgreed,
      consentTimestamp: consentTimestamp ?? this.consentTimestamp,
    );
  }

  bool get isInSubStep => currentSubStepKey != null;
}

class WizardNotifier extends StateNotifier<WizardState> {
  WizardNotifier()
      : super(WizardState(
          currentStepId: 1,
          answers: {},
          stepHistory: [1],
        ));

  void setAnswer(String key, dynamic answer) {
    final newAnswers = Map<String, dynamic>.from(state.answers);
    newAnswers[key] = answer;
    
    state = state.copyWith(answers: newAnswers);
  }

  void setConsentAgreed() {
    state = state.copyWith(
      hasConsentAgreed: true,
      consentTimestamp: DateTime.now(),
    );
  }

  void nextStep() {
    Logger.info('nextStep called - current state: stepId=${state.currentStepId}, subStepKey=${state.currentSubStepKey}');
    
    // Handle sub-step navigation for any step with sub-steps
    if (state.currentSubStepKey != null) {
      Logger.debug('Currently in sub-step, calling _handleSubStepNavigation');
      _handleSubStepNavigation();
      return;
    }

    // Handle entering sub-steps for any step
    final currentStep = WizardSteps.getStepById(state.currentStepId);
    if (currentStep != null && currentStep.subSteps != null) {
      final stepAnswer = state.answers['step_${state.currentStepId}'];
      Logger.debug('Checking for sub-steps: answer=$stepAnswer, has substeps=${currentStep.subSteps!.keys.toList()}');
      if (stepAnswer != null && currentStep.subSteps!.containsKey(stepAnswer)) {
        // Enter sub-step
        Logger.debug('Entering sub-step for answer: $stepAnswer');
        state = state.copyWith(
          currentSubStepKey: () => stepAnswer,
          currentSubStepIndex: 0,
        );
        return;
      }
    }

    // Regular step navigation
    if (state.currentStepId < WizardSteps.getTotalSteps()) {
      final nextStepId = state.currentStepId + 1;
      final newHistory = List<int>.from(state.stepHistory);
      newHistory.add(nextStepId);
      
      // IMPORTANT: Explicitly clear sub-step state when moving to next main step
      state = state.copyWith(
        currentStepId: nextStepId,
        currentSubStepKey: () => null,  // Clear any lingering sub-step key
        currentSubStepIndex: 0,
        stepHistory: newHistory,
      );
    }
  }

  void _handleSubStepNavigation() {
    final step = WizardSteps.getStepById(state.currentStepId);
    final subSteps = step?.subSteps?[state.currentSubStepKey];
    
    Logger.debug('_handleSubStepNavigation: stepId=${state.currentStepId}, subStepKey=${state.currentSubStepKey}, subStepIndex=${state.currentSubStepIndex}');
    Logger.debug('SubSteps length: ${subSteps?.length ?? 0}');
    
    if (subSteps != null && subSteps.isNotEmpty) {
      if (state.currentSubStepIndex < subSteps.length - 1) {
        // Go to next sub-step
        Logger.debug('Moving to next sub-step: ${state.currentSubStepIndex + 1}');
        state = state.copyWith(
          currentSubStepIndex: state.currentSubStepIndex + 1,
        );
      } else {
        // Finished all sub-steps, go to next main step
        if (state.currentStepId < WizardSteps.getTotalSteps()) {
          final nextStepId = state.currentStepId + 1;
          final newHistory = List<int>.from(state.stepHistory);
          newHistory.add(nextStepId);
          
          Logger.success('Finished sub-steps, moving to step $nextStepId');
          
          state = state.copyWith(
            currentStepId: nextStepId,
            currentSubStepKey: () => null,
            currentSubStepIndex: 0,
            stepHistory: newHistory,
          );
        }
      }
    } else {
      // No sub-steps found, clear the sub-step state and move to next step
      Logger.warning('No sub-steps found for key "${state.currentSubStepKey}" on step ${state.currentStepId}, clearing sub-step state');
      if (state.currentStepId < WizardSteps.getTotalSteps()) {
        final nextStepId = state.currentStepId + 1;
        final newHistory = List<int>.from(state.stepHistory);
        newHistory.add(nextStepId);
        
        state = state.copyWith(
          currentStepId: nextStepId,
          currentSubStepKey: () => null,
          currentSubStepIndex: 0,
          stepHistory: newHistory,
        );
      }
    }
  }

  void previousStep() {
    // Handle sub-step back navigation
    if (state.currentSubStepKey != null) {
      if (state.currentSubStepIndex > 0) {
        // Go back to previous sub-step
        state = state.copyWith(
          currentSubStepIndex: state.currentSubStepIndex - 1,
        );
      } else {
        // Go back to main step
        state = state.copyWith(
          currentSubStepKey: () => null,
          currentSubStepIndex: 0,
        );
      }
      return;
    }

    // Regular back navigation
    if (state.stepHistory.length > 1) {
      final newHistory = List<int>.from(state.stepHistory);
      newHistory.removeLast();
      
      state = state.copyWith(
        currentStepId: newHistory.last,
        currentSubStepKey: () => null,
        currentSubStepIndex: 0,
        stepHistory: newHistory,
      );
    }
  }

  void goToStep(int stepId) {
    final stepIndex = state.stepHistory.indexOf(stepId);
    
    if (stepIndex != -1) {
      final newHistory = state.stepHistory.sublist(0, stepIndex + 1);
      state = state.copyWith(
        currentStepId: stepId,
        currentSubStepKey: () => null,
        currentSubStepIndex: 0,
        stepHistory: newHistory,
      );
    }
  }

  void reset() {
    state = WizardState(
      currentStepId: 1,
      answers: {},
      stepHistory: [1],
    );
  }

  void loadDraft(Map<String, dynamic> draftData) {
    state = WizardState(
      currentStepId: draftData['currentStepId'] ?? 1,
      currentSubStepKey: draftData['currentSubStepKey'] as String?,
      currentSubStepIndex: draftData['currentSubStepIndex'] ?? 0,
      answers: Map<String, dynamic>.from(draftData['answers'] ?? {}),
      stepHistory: List<int>.from(draftData['stepHistory'] ?? [1]),
    );
  }

  int getCurrentStepNumber() {
    return state.currentStepId;
  }

  int getTotalSteps() {
    return WizardSteps.getTotalSteps();
  }

  bool isLastStep() {
    // Check if we're on the last main step (10)
    if (state.currentStepId != WizardSteps.getTotalSteps()) {
      return false;
    }
    
    // If we're on step 10 and not in a sub-step, it's the last step
    if (!state.isInSubStep) {
      return true;
    }
    
    // If we're in a sub-step of step 10, check if it's the last sub-step
    final step = WizardSteps.getStepById(state.currentStepId);
    final subSteps = step?.subSteps?[state.currentSubStepKey];
    
    if (subSteps != null) {
      return state.currentSubStepIndex >= subSteps.length - 1;
    }
    
    return true;
  }

  String getCurrentStepKey() {
    if (state.isInSubStep) {
      return 'step_${state.currentStepId}_${state.currentSubStepKey}_${state.currentSubStepIndex}';
    }
    return 'step_${state.currentStepId}';
  }

  WizardStep? getCurrentStep() {
    return WizardSteps.getStepById(state.currentStepId);
  }

  SubStep? getCurrentSubStep() {
    if (!state.isInSubStep) return null;
    
    final step = WizardSteps.getStepById(state.currentStepId);
    final subSteps = step?.subSteps?[state.currentSubStepKey];
    
    if (subSteps != null && state.currentSubStepIndex < subSteps.length) {
      return subSteps[state.currentSubStepIndex];
    }
    
    return null;
  }
}

final wizardProvider = StateNotifierProvider<WizardNotifier, WizardState>((ref) {
  return WizardNotifier();
});
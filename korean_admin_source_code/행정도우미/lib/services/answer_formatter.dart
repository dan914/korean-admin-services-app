import '../data/steps.dart';
import '../reference/agency_codes.dart';
import '../reference/region_codes.dart';
import '../reference/applicant_type_codes.dart';
import '../reference/doc_status_codes.dart';

class AnswerFormatter {
  static String formatAnswer(String key, dynamic value) {
    if (value == null) return '미응답';
    
    // Handle memo field
    if (key == 'memo') {
      return value.toString().isEmpty ? '작성하지 않음' : value.toString();
    }
    
    // Parse the key to get step number and sub-step info
    final parts = key.split('_');
    if (parts.isEmpty || parts[0] != 'step') return value.toString();
    
    final stepId = int.tryParse(parts[1] ?? '');
    if (stepId == null) return value.toString();
    
    // Handle sub-steps (e.g., step_4_penalty_0)
    if (parts.length > 2) {
      final subStepKey = parts[2];
      final subStepIndex = int.tryParse(parts[3] ?? '0') ?? 0;
      
      final step = WizardSteps.getStepById(stepId);
      if (step != null && step.subSteps != null && step.subSteps!.containsKey(subStepKey)) {
        final subSteps = step.subSteps![subStepKey];
        if (subSteps != null && subStepIndex < subSteps.length) {
          final subStep = subSteps[subStepIndex];
          final option = subStep.options.firstWhere(
            (opt) => opt.code == value,
            orElse: () => StepOption(code: value.toString(), label: value.toString()),
          );
          return option.label;
        }
      }
    }
    
    // Handle main steps
    final step = WizardSteps.getStepById(stepId);
    if (step != null) {
      // Special handling for steps with code references
      switch (stepId) {
        case 2: // Agency codes
          final agency = agencyCodes.firstWhere(
            (item) => item.code == value,
            orElse: () => agencyCodes.last, // UNK
          );
          return agency.ko;
        
        case 5: // Applicant type codes
          final applicant = applicantTypeCodes.firstWhere(
            (item) => item.code == value,
            orElse: () => applicantTypeCodes.last, // UNK
          );
          return applicant.ko;
        
        case 6: // Document status codes
          final docStatus = docStatusCodes.firstWhere(
            (item) => item.code == value,
            orElse: () => docStatusCodes.last, // UNK
          );
          return docStatus.ko;
        
        case 7: // Region codes
          final region = regionCodes.firstWhere(
            (item) => item.code == value,
            orElse: () => regionCodes.last, // UNK
          );
          return region.ko;
        
        default:
          // For other steps, find the matching option
          final option = step.options.firstWhere(
            (opt) => opt.code == value,
            orElse: () => StepOption(code: value.toString(), label: value.toString()),
          );
          return option.label;
      }
    }
    
    return value.toString();
  }
  
  static String getStepTitle(String key) {
    // Handle memo field
    if (key == 'memo') {
      return '추가. 상황에 대한 메모';
    }
    
    // Parse the key to get step number
    final parts = key.split('_');
    if (parts.isEmpty || parts[0] != 'step') return key;
    
    final stepId = int.tryParse(parts[1] ?? '');
    if (stepId == null) return key;
    
    // Handle sub-steps
    if (parts.length > 2) {
      final subStepKey = parts[2];
      final subStepIndex = int.tryParse(parts[3] ?? '0') ?? 0;
      
      final step = WizardSteps.getStepById(stepId);
      if (step != null && step.subSteps != null && step.subSteps!.containsKey(subStepKey)) {
        final subSteps = step.subSteps![subStepKey];
        if (subSteps != null && subStepIndex < subSteps.length) {
          final subStep = subSteps[subStepIndex];
          return '${stepId}-${subStepIndex + 1}. ${subStep.title}';
        }
      }
    }
    
    // Handle main steps
    final step = WizardSteps.getStepById(stepId);
    if (step != null) {
      return '$stepId. ${step.title}';
    }
    
    return key;
  }
  
  static Map<String, String> formatAllAnswers(Map<String, dynamic> formData) {
    final formatted = <String, String>{};
    
    for (final entry in formData.entries) {
      final title = getStepTitle(entry.key);
      final answer = formatAnswer(entry.key, entry.value);
      formatted[title] = answer;
    }
    
    return formatted;
  }
}
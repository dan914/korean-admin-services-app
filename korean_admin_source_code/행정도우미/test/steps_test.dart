import 'package:flutter_test/flutter_test.dart';
import 'package:admin_helper/data/steps.dart';

void main() {
  group('Enhanced Steps with UNK Options', () {
    test('All steps should have UNK as first option', () {
      for (final step in WizardSteps.steps) {
        expect(step.options.isNotEmpty, true, reason: 'Step ${step.id} should have options');
        expect(step.options.first.code, 'UNK', reason: 'Step ${step.id} should start with UNK option');
        expect(step.options.first.label, '잘 모르겠음', reason: 'Step ${step.id} UNK should have correct Korean label');
      }
    });

    test('Step 2 should use detailed agency codes', () {
      final step2 = WizardSteps.getStepById(2);
      expect(step2, isNotNull);
      expect(step2!.options.length, greaterThan(10), reason: 'Step 2 should have many agency options');
      
      // Check for specific agencies
      final agencyCodes = step2.options.map((o) => o.code).toList();
      expect(agencyCodes.contains('1010000'), true, reason: 'Should contain 기획재정부');
      expect(agencyCodes.contains('1120000'), true, reason: 'Should contain 보건복지부');
    });

    test('Step 5 should use detailed applicant type codes', () {
      final step5 = WizardSteps.getStepById(5);
      expect(step5, isNotNull);
      expect(step5!.options.length, greaterThan(5), reason: 'Step 5 should have many applicant types');
      
      final typeCodes = step5.options.map((o) => o.code).toList();
      expect(typeCodes.contains('1'), true, reason: 'Should contain 개인');
      expect(typeCodes.contains('4'), true, reason: 'Should contain 외국인');
    });

    test('Step 7 should use detailed region codes', () {
      final step7 = WizardSteps.getStepById(7);
      expect(step7, isNotNull);
      expect(step7!.options.length, greaterThan(10), reason: 'Step 7 should have many regions');
      
      final regionCodes = step7.options.map((o) => o.code).toList();
      expect(regionCodes.contains('11'), true, reason: 'Should contain Seoul (11)');
      expect(regionCodes.contains('31'), true, reason: 'Should contain Gyeonggi (31)');
    });

    test('Step 4 sub-steps should also have UNK options', () {
      final step4 = WizardSteps.getStepById(4);
      expect(step4, isNotNull);
      expect(step4!.subSteps, isNotNull);
      
      for (final category in step4.subSteps!.keys) {
        final subSteps = step4.subSteps![category]!;
        for (final subStep in subSteps) {
          expect(subStep.options.isNotEmpty, true);
          expect(subStep.options.first.code, 'UNK');
          expect(subStep.options.first.label, '잘 모르겠음');
        }
      }
    });

    test('Total steps should be 10', () {
      expect(WizardSteps.getTotalSteps(), 10);
    });
  });
}
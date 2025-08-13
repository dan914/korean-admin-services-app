import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'ui/app_theme.dart';
import 'widgets/app_button.dart';
import 'widgets/radio_option.dart';
import 'widgets/step_card.dart';
import 'widgets/progress_bar.dart';
import 'widgets/answer_card.dart';

void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      name: '행정도우미 Design System',
      themes: [
        WidgetbookTheme(
          name: 'Light',
          data: AppTheme.lightTheme,
        ),
      ],
      categories: [
        WidgetbookCategory(
          name: 'Components',
          widgets: [
            WidgetbookComponent(
              name: 'AppButton',
              useCases: [
                WidgetbookUseCase(
                  name: 'Primary',
                  builder: (context) => Center(
                    child: AppButton(
                      label: context.knobs.text(
                        label: 'Label',
                        initialValue: '다음',
                      ),
                      onPressed: context.knobs.boolean(
                        label: 'Enabled',
                        initialValue: true,
                      )
                          ? () {}
                          : null,
                      isLoading: context.knobs.boolean(
                        label: 'Loading',
                        initialValue: false,
                      ),
                      icon: context.knobs.boolean(
                        label: 'Has Icon',
                        initialValue: false,
                      )
                          ? Icons.arrow_forward
                          : null,
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Outline',
                  builder: (context) => Center(
                    child: AppButton(
                      label: '이전',
                      variant: AppButtonVariant.outline,
                      onPressed: () {},
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Text',
                  builder: (context) => Center(
                    child: AppButton(
                      label: '건너뛰기',
                      variant: AppButtonVariant.text,
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'RadioOption',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioOption<String>(
                          value: 'option1',
                          groupValue: context.knobs.options(
                            label: 'Selected',
                            options: ['option1', 'option2', 'none'],
                            initialOption: 'option1',
                          ),
                          label: '개인사업자',
                          subtitle: '개인이 운영하는 사업체',
                          onChanged: (_) {},
                        ),
                        const SizedBox(height: 16),
                        RadioOption<String>(
                          value: 'option2',
                          groupValue: context.knobs.options(
                            label: 'Selected',
                            options: ['option1', 'option2', 'none'],
                            initialOption: 'option1',
                          ),
                          label: '법인사업자',
                          subtitle: '법인으로 등록된 사업체',
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'StepCard',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => StepCard(
                    stepNumber: '1',
                    title: '업체 형태 선택',
                    subtitle: '운영하실 업체의 형태를 선택해주세요',
                    child: Column(
                      children: [
                        RadioOption<String>(
                          value: 'individual',
                          groupValue: 'individual',
                          label: '개인사업자',
                          onChanged: (_) {},
                        ),
                        const SizedBox(height: 16),
                        RadioOption<String>(
                          value: 'corporation',
                          groupValue: 'individual',
                          label: '법인사업자',
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'ProgressBar',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: ProgressBar(
                      currentStep: context.knobs.number(
                        label: 'Current Step',
                        initialValue: 3,
                      ).toInt(),
                      totalSteps: 10,
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'AnswerCard',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => AnswerCard(
                    stepNumber: '1',
                    question: '업체 형태',
                    answer: '개인사업자',
                    onEdit: context.knobs.boolean(
                      label: 'Editable',
                      initialValue: true,
                    )
                        ? () {}
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
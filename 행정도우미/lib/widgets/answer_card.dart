import 'package:flutter/material.dart';
import '../ui/design_tokens.dart';

class AnswerCard extends StatelessWidget {
  final String stepNumber;
  final String question;
  final String answer;
  final VoidCallback? onEdit;

  const AnswerCard({
    Key? key,
    required this.stepNumber,
    required this.question,
    required this.answer,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
                    color: DesignTokens.secondary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      stepNumber,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: DesignTokens.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                SizedBox(width: DesignTokens.spacingBase),
                Expanded(
                  child: Text(
                    question,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: DesignTokens.textMuted,
                        ),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit, size: 20),
                    color: DesignTokens.primary,
                    onPressed: onEdit,
                  ),
              ],
            ),
            SizedBox(height: DesignTokens.spacingBase / 2),
            Padding(
              padding: EdgeInsets.only(left: 48),
              child: Text(
                answer,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
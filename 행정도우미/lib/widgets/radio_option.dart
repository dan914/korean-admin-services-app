import 'package:flutter/material.dart';
import '../ui/design_tokens.dart';

class RadioOption<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final String label;
  final String? subtitle;
  final ValueChanged<T?> onChanged;
  final bool isUnknown;

  const RadioOption({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.label,
    this.subtitle,
    required this.onChanged,
    this.isUnknown = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    
    // Special styling for "잘 모르겠음" (UNK) option
    final unknownColor = const Color(0xFFB0B0B0);
    final borderColor = isUnknown 
        ? (isSelected ? unknownColor : unknownColor.withOpacity(0.5))
        : (isSelected ? DesignTokens.primary : DesignTokens.border);
    final backgroundColor = isUnknown
        ? (isSelected ? unknownColor.withOpacity(0.1) : Colors.grey.withOpacity(0.05))
        : (isSelected ? DesignTokens.primary.withOpacity(0.05) : DesignTokens.bgAlt);

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingBase,
          vertical: DesignTokens.spacingBase,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Add question mark icon for UNK options
            if (isUnknown) ...[
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? unknownColor : unknownColor.withOpacity(0.3),
                ),
                child: Icon(
                  Icons.help_outline,
                  size: 16,
                  color: isSelected ? Colors.white : unknownColor,
                ),
              ),
            ] else ...[
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: DesignTokens.primary,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
            SizedBox(width: DesignTokens.spacingBase),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
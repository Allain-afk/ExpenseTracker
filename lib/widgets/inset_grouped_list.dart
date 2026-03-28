import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class InsetGroupedList extends StatelessWidget {
  final List<Widget> children;
  final String? headerText;
  final String? footerText;
  final EdgeInsetsGeometry margin;

  const InsetGroupedList({
    super.key,
    required this.children,
    this.headerText,
    this.footerText,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (headerText != null)
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 10, top: 16),
            child: Text(
              headerText!,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
              ),
            ),
          ),
        Container(
          margin: margin,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.border.withValues(alpha: 0.85)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Divider(
                        height: 0.5,
                        thickness: 0.5,
                        color: AppTheme.border,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        if (footerText != null)
          Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 8,
              bottom: 16,
            ),
            child: Text(
              footerText!,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

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
            padding: const EdgeInsets.only(left: 32, bottom: 8, top: 16),
            child: Text(
              headerText!.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        Container(
          margin: margin,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10), // Standard iOS inset roundedness
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
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
                        color: Colors.grey.shade300,
                      ),
                    ),
                ]
              ],
            ),
          ),
        ),
        if (footerText != null)
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, top: 8, bottom: 16),
            child: Text(
              footerText!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
      ],
    );
  }
}

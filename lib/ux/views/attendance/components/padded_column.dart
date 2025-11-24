import 'package:flutter/material.dart';

class PaddedColumn extends StatelessWidget {
  const PaddedColumn({
    super.key,
    required this.children,
    this.padding,
    this.crossAxisAlignment,
    this.mainAxisAlignment,
    this.mainAxisSize = MainAxisSize.max,
  });

  final List<Widget> children;
  final EdgeInsets? padding;
  final CrossAxisAlignment? crossAxisAlignment;
  final MainAxisAlignment? mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        mainAxisSize: mainAxisSize,
        children: children,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PaddedColumn extends StatelessWidget {
  const PaddedColumn(
      {super.key,
      required this.children,
      this.padding,
      this.crossAxisAlignment});

  final List<Widget> children;
  final EdgeInsets? padding;
  final CrossAxisAlignment? crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

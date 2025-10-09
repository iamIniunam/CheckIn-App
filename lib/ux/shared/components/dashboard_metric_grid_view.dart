import 'package:flutter/material.dart';

class DashboardMetricGridView extends StatelessWidget {
  const DashboardMetricGridView(
      {super.key,
      required this.crossAxisCount,
      required this.children,
      this.padding,
      this.physics,
      this.crossAxisSpacing,
      this.mainAxisSpacing,
      this.childAspectRatio});

  final int crossAxisCount;
  final List<Widget> children;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: padding,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing ?? 10,
      mainAxisSpacing: mainAxisSpacing ?? 8,
      childAspectRatio: childAspectRatio ?? 1,
      children: children,
    );
  }
}

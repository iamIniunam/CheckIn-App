// import 'package:flutter/material.dart';

// class DashboardMetricGridView extends StatelessWidget {
//   const DashboardMetricGridView(
//       {super.key,
//       required this.crossAxisCount,
//       required this.children,
//       this.padding,
//       this.physics,
//       this.crossAxisSpacing,
//       this.mainAxisSpacing,
//       this.childAspectRatio});

//   final int crossAxisCount;
//   final List<Widget> children;
//   final EdgeInsets? padding;
//   final ScrollPhysics? physics;
//   final double? crossAxisSpacing;
//   final double? mainAxisSpacing;
//   final double? childAspectRatio;

//   @override
//   Widget build(BuildContext context) {
//     return GridView.count(
//       padding: padding,
//       physics: physics ?? const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       crossAxisCount: crossAxisCount,
//       crossAxisSpacing: crossAxisSpacing ?? 10,
//       mainAxisSpacing: mainAxisSpacing ?? 8,
//       childAspectRatio: childAspectRatio ?? 1,
//       children: children,
//     );
//   }
// }

import 'package:flutter/material.dart';

class DashboardMetricGridView extends StatelessWidget {
  const DashboardMetricGridView({
    super.key,
    required this.children,
    this.padding,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 10.0,
    this.mainAxisSpacing = 8.0,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  final List<Widget> children;
  final EdgeInsets? padding;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final rows = (children.length + crossAxisCount - 1) ~/ crossAxisCount;

    List<Widget> rowWidgets = List.generate(rows, (rowIndex) {
      final start = rowIndex * crossAxisCount;

      // Build the list of widgets for this row, inserting spacing between
      // columns but not after the last item.
      List<Widget> cols = [];
      for (int i = 0; i < crossAxisCount; i++) {
        final idx = start + i;
        cols.add(Expanded(
          child:
              indexIsAvailable(idx) ? children[idx] : const SizedBox.shrink(),
        ));
        if (i != crossAxisCount - 1) {
          cols.add(SizedBox(width: crossAxisSpacing));
        }
      }

      return Padding(
        padding: EdgeInsets.only(top: rowIndex == 0 ? 0 : mainAxisSpacing),
        child: Row(children: cols),
      );
    });

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: ListView(physics: physics, shrinkWrap: true, children: rowWidgets),
    );
  }

  Widget horizontalSpacer() {
    return const SizedBox(
      width: 7,
    );
  }

  bool indexIsAvailable(int index) {
    return index < children.length;
  }

  Widget getWidgetAtIndex(int index) {
    return Expanded(
      child:
          indexIsAvailable(index) ? children[index] : const SizedBox.shrink(),
    );
  }
}

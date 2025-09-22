// import 'package:flutter/material.dart';

// class DashboardMetricGridView extends StatelessWidget {
//   const DashboardMetricGridView({super.key, required this.children});

//   final List<Widget> children;

//   @override
//   Widget build(BuildContext context) {
//     return Visibility(
//       visible: children.isNotEmpty,
//       child: Column(
//         children: [
//           Row(
//             children: [
//               getWidgetAtIndex(0),
//               horizontalSpacer(),
//               getWidgetAtIndex(1),
//               horizontalSpacer(),
//               getWidgetAtIndex(2),
//             ],
//           ),
//           Visibility(
//             visible: indexIsAvailable(3),
//             child: Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: Row(
//                 children: [
//                   getWidgetAtIndex(3),
//                   horizontalSpacer(),
//                   getWidgetAtIndex(4),
//                   horizontalSpacer(),
//                   getWidgetAtIndex(5),
//                 ],
//               ),
//             ),
//           ),
//           Visibility(
//             visible: indexIsAvailable(3),
//             child: Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: Row(
//                 children: [
//                   getWidgetAtIndex(6),
//                   horizontalSpacer(),
//                   getWidgetAtIndex(7),
//                   horizontalSpacer(),
//                   getWidgetAtIndex(8),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget horizontalSpacer(){
//     return const SizedBox(width: 10);
//   }

//   bool indexIsAvailable(int index){
//     return index < children.length;
//   }

//   Widget getWidgetAtIndex(int index){
//     return Expanded(
//       child: indexIsAvailable(index)?
//         children[index] : const SizedBox.shrink(),
//     );
//   }
// }

import 'package:flutter/material.dart';

class DashboardMetricGridView extends StatelessWidget {
  const DashboardMetricGridView(
      {super.key,
      required this.crossAxisCount,
      required this.children,
      this.padding,
      this.physics,
      this.crossAxisSpacing,
      this.mainAxisSpacing});

  final int crossAxisCount;
  final List<Widget> children;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: padding,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing ?? 10,
      mainAxisSpacing: mainAxisSpacing ?? 8,
      children: children,
    );
  }
}

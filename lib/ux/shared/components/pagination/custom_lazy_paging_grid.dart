import 'package:attendance_app/ux/shared/components/page_state_indicator.dart';
import 'package:attendance_app/ux/shared/components/pagination/custom_paged_grid_view.dart';
import 'package:attendance_app/ux/shared/components/small_circular_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';


class CustomLazyPagingGrid<KeyType, ItemType> extends StatelessWidget {
  final Widget Function(BuildContext context, ItemType item, int index) itemBuilder;
  final Widget? header, footer, emptyPageWidget;
  final Widget? loadIndicator, errorPageWidget;
  final Widget? appendIndicator;
  final ScrollController? scrollController;
  final PagingController<KeyType, ItemType> pagingController;
  final SliverGridDelegate gridDelegate;
  final bool shrinkWrap;
  final EdgeInsets? padding;
  final bool showNewPageProgressIndicatorAsGridChild;
  final bool showNewPageErrorIndicatorAsGridChild;
  final double? cacheExtent;
  final bool? primary;
  final int? appendIndicatorCount;
  final ScrollPhysics? physics;
  final String? errorText;

  const CustomLazyPagingGrid({
    super.key,
    required this.itemBuilder,
    required this.pagingController,
    required this.gridDelegate,
    this.header,
    this.footer,
    this.emptyPageWidget,
    this.loadIndicator,
    this.appendIndicator,
    this.scrollController,
    this.errorPageWidget,
    this.shrinkWrap = false,
    this.padding,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.cacheExtent,
    this.primary,
    this.appendIndicatorCount,
    this.physics,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPagedGridView<KeyType, ItemType>(
      gridDelegate: gridDelegate,
      pagingController: pagingController,
      shrinkWrap: shrinkWrap,
      primary: primary,
      scrollController: scrollController,
      appendIndicatorCount: appendIndicatorCount,
      padding: padding,
      showNewPageProgressIndicatorAsGridChild: showNewPageProgressIndicatorAsGridChild,
      showNewPageErrorIndicatorAsGridChild: showNewPageErrorIndicatorAsGridChild,
      builderDelegate: PagedChildBuilderDelegate<ItemType>(
        itemBuilder: (context, item, index) {
          return itemBuilder(context, item, index);
        },
        firstPageErrorIndicatorBuilder: (_) {
          return errorPageWidget ?? PageErrorIndicator(text: errorText,);
        },
        noItemsFoundIndicatorBuilder: (context) => emptyPageWidget ?? const SizedBox(),
        firstPageProgressIndicatorBuilder: (_) => loadIndicator ?? const PageLoadingIndicator(),
        newPageProgressIndicatorBuilder: (_) => const SmallCircularProgressIndicator(),
    ));
  }
}

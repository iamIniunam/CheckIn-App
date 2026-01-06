import 'package:attendance_app/ux/shared/components/pagination/custom_paged_sliver_grid.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// A [GridView] with pagination capabilities.
///
/// Wraps a [PagedSliverGrid] in a [BoxScrollView] so that it can be
/// used without the need for a [CustomScrollView]. Similar to a [GridView].
class CustomPagedGridView<PageKeyType, ItemType> extends BoxScrollView {
  const CustomPagedGridView({
    required this.pagingController,
    required this.builderDelegate,
    required this.gridDelegate,
    // Matches [ScrollView.controller].
    ScrollController? scrollController,
    // Matches [ScrollView.scrollDirection].
    super.scrollDirection,
    // Matches [ScrollView.reverse].
    super.reverse,
    // Matches [ScrollView.primary].
    super.primary,
    // Matches [ScrollView.physics].
    super.physics,
    // Matches [ScrollView.shrinkWrap].
    super.shrinkWrap,
    // Matches [BoxScrollView.padding].
    super.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    // Matches [ScrollView.cacheExtent].
    super.cacheExtent,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    // Matches [ScrollView.dragStartBehavior].
    super.dragStartBehavior,
    // Matches [ScrollView.keyboardDismissBehavior].
    super.keyboardDismissBehavior,
    // Matches [ScrollView.restorationId].
    super.restorationId,
    // Matches [ScrollView.clipBehavior].
    super.clipBehavior,
    super.key,
    this.showAnyLoadingIndicator = true,
    this.appendIndicatorCount,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        super(
          controller: scrollController,
        );

  /// Matches [PagedLayoutBuilder.pagingController].
  final PagingController<PageKeyType, ItemType> pagingController;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// Matches [GridView.gridDelegate].
  final SliverGridDelegate gridDelegate;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Matches [PagedSliverGrid.showNewPageProgressIndicatorAsGridChild].
  final bool showNewPageProgressIndicatorAsGridChild;

  /// Matches [PagedSliverGrid.showNewPageErrorIndicatorAsGridChild].
  final bool showNewPageErrorIndicatorAsGridChild;

  /// Matches [PagedSliverGrid.showNoMoreItemsIndicatorAsGridChild].
  final bool showNoMoreItemsIndicatorAsGridChild;

  /// Matches [PagedSliverGrid.shrinkWrapFirstPageIndicators].
  final bool _shrinkWrapFirstPageIndicators;

  final bool showAnyLoadingIndicator;

  /// Allows to provide the number of columns in the grid, only used for showing loading indicators.
  final int? appendIndicatorCount;

  @override
  Widget buildChildLayout(BuildContext context) => CustomPagedSliverGrid<PageKeyType, ItemType>(
        builderDelegate: builderDelegate,
        pagingController: pagingController,
        gridDelegate: gridDelegate,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        showNewPageProgressIndicatorAsGridChild: showNewPageProgressIndicatorAsGridChild,
        showNewPageErrorIndicatorAsGridChild: showNewPageErrorIndicatorAsGridChild,
        showNoMoreItemsIndicatorAsGridChild: showNoMoreItemsIndicatorAsGridChild,
        shrinkWrapFirstPageIndicators: _shrinkWrapFirstPageIndicators,
        appendIndicatorCount: appendIndicatorCount,
      );
}

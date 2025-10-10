import 'package:flutter/material.dart';

/// Lightweight shimmer implementation using [ShaderMask].
/// Use `Shimmer` to wrap any child and get a shimmer animation.
/// Also provides convenience widgets: `ShimmerBox` and `ShimmerList`.

class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration period;
  final Color baseColor;
  final Color highlightColor;

  const Shimmer({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 1200),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.period,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final width = bounds.width;
            // Sliding gradient from left to right
            final dx = (2 * width) * _controller.value - width;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.25, 0.5, 0.75],
              transform: _SlidingGradientTransform(dx: dx),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double dx;
  const _SlidingGradientTransform({required this.dx});

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0.0, 0.0);
  }
}

/// Convenience box with rounded corners used as a shimmer placeholder.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final EdgeInsets margin;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
      child: const SizedBox.shrink(),
    );
  }
}

/// Render a vertical list of shimmer boxes.
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double spacing;
  final double itemHeight;
  final EdgeInsets padding;

  const ShimmerList({
    super.key,
    this.itemCount = 6,
    this.spacing = 12,
    this.itemHeight = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: List.generate(itemCount, (i) {
          return Padding(
            padding: EdgeInsets.only(bottom: i == itemCount - 1 ? 0 : spacing),
            child: Row(
              children: [
                Expanded(
                  child: ShimmerBox(height: itemHeight),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

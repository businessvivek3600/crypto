import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/sized_utils.dart';

enum SkeletonAnimation { none, pulse }

enum SkeletonStyle { box, circle, text }

class Skeleton extends StatefulWidget {
  final Color? textColor;
  final double width;
  final double height;
  final double padding;
  final SkeletonAnimation animation;
  final Duration? animationDuration;
  final SkeletonStyle style;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  const Skeleton({
    super.key,
    this.textColor,
    this.width = 200.0,
    this.height = 60.0,
    this.padding = 0,
    this.animation = SkeletonAnimation.pulse,
    this.animationDuration,
    this.style = SkeletonStyle.box,
    this.border,
    this.borderRadius,
  });

  @override
  _SkeletonState createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animation == SkeletonAnimation.pulse) {
      _controller = AnimationController(
        duration:
            widget.animationDuration ?? const Duration(milliseconds: 1000),
        reverseDuration:
            widget.animationDuration ?? const Duration(milliseconds: 1000),
        vsync: this,
        lowerBound: .6,
        upperBound: 1,
      )..addStatusListener((AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            _controller.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _controller.forward();
          }
        });
      _controller.forward();
    } else {
      _controller = AnimationController(
        vsync: this,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color themeTextColor = Theme.of(context).textTheme.bodyLarge!.color!;
    double themeOpacity =
        Theme.of(context).brightness == Brightness.light ? 0.11 : 0.13;
    BorderRadiusGeometry borderRadius = widget.borderRadius ??
        () {
          switch (widget.style) {
            case SkeletonStyle.circle:
              return BorderRadius.all(Radius.circular(widget.width / 2));
            case SkeletonStyle.text:
              return const BorderRadius.all(Radius.circular(4));
            default:
              return BorderRadius.zero;
          }
        }();

    return Padding(
      padding: EdgeInsetsDirectional.all(widget.padding),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: (widget.animation == SkeletonAnimation.pulse)
              ? _controller.value
              : 1,
          child: Container(
            width: widget.width,
            height: (widget.style == SkeletonStyle.circle)
                ? widget.width
                : widget.height,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: widget.border,
              color:
                  widget.textColor ?? themeTextColor.withOpacity(themeOpacity),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SkeletonText extends StatelessWidget {
  final double height;
  final double padding;

  const SkeletonText({
    super.key,
    required this.height,
    this.padding = 0,
  });

  @override
  Widget build(BuildContext context) =>
      Skeleton(style: SkeletonStyle.text, height: height, padding: padding);
}

Shimmer buildShimmer(
    {Widget? child,
    double radius = 2,
    double w = 30,
    double h = 13,
    Color? color,
    BoxShape shape = BoxShape.rectangle}) {
  return Shimmer.fromColors(
    baseColor: getTheme.colorScheme.primary.withOpacity(0.1),
    highlightColor: getTheme.colorScheme.primary.withOpacity(0.2),
    period: const Duration(milliseconds: 1000),
    child: child ??
        Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
              borderRadius: shape != BoxShape.circle
                  ? BorderRadius.circular(radius)
                  : null,
              color: color ?? Colors.grey[100],
              shape: shape),
        ),
  );
}

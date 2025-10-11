import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AnimatedScrollItem extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double offsetY;
  final double scale;

  const AnimatedScrollItem({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.offsetY = 50,
    this.scale = 0.95,
  }) : super(key: key);

  @override
  State<AnimatedScrollItem> createState() => _AnimatedScrollItemState();
}

class _AnimatedScrollItemState extends State<AnimatedScrollItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  late Animation<double> _scale;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _slide = Tween<Offset>(
      begin: Offset(0, widget.offsetY / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _scale = Tween<double>(
      begin: widget.scale,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0.2 && !_visible) {
      _visible = true;
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(hashCode.toString()),
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Opacity(
            opacity: _opacity.value,
            child: Transform.translate(
              offset: _slide.value * 100,
              child: Transform.scale(
                scale: _scale.value,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

@immutable
class ExpandableFab2 extends StatefulWidget {
  const ExpandableFab2({
    super.key,
    this.initialOpen,
    required this.children,
  });
  final bool? initialOpen;
  final double distance = 100.0;
  final List<Widget> children;

  @override
  State<ExpandableFab2> createState() => _ExpandableFab2State();
}

class _ExpandableFab2State extends State<ExpandableFab2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ]);
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
        child: Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: _toggle,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.close,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    ));
  }

  Widget _buildTapToOpenFab() {
    return SizedBox(
        child: IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: _toggle,
            child: const Icon(Icons.api),
          ),
        ),
      ),
    ));
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = (180 - 30.0 - 30.0) / (count - 1);
    for (var i = 0, angleInDegrees = 30.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(_ExpandingActionButton(
        directionInDegrees: angleInDegrees,
        maxDistance: widget.distance,
        progress: _expandAnimation,
        child: widget.children[i],
      ));
    }
    return children;
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SnappingScrollPhysics extends ScrollPhysics {
  final double itemDimension;

  const SnappingScrollPhysics({
    required this.itemDimension,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  SnappingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnappingScrollPhysics(
      itemDimension: itemDimension,
      parent: buildParent(ancestor),
    );
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = position.pixels / itemDimension;

    // Tăng độ nhạy cuộn khi fling
    if (velocity.abs() > tolerance.velocity) {
      page += velocity.sign * 0.5; // có thể thay bằng velocity * hệ số
    }

    final double target = page.roundToDouble() * itemDimension;
    return target.clamp(position.minScrollExtent, position.maxScrollExtent);
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tol = toleranceFor(position);
    final double target = _getTargetPixels(position, tol, velocity);

    if ((velocity.abs() < tol.velocity) &&
        (position.pixels - target).abs() < tol.distance) {
      return null;
    }

    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tol,
    );
  }
}

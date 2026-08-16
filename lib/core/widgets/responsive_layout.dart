import 'package:flutter/material.dart';

class AppBreakpoints {
  const AppBreakpoints._();

  static const double tablet = 600;
  static const double desktop = 900;
  static const double maxAppWidth = 840;
}

class ResponsiveAppViewport extends StatelessWidget {
  const ResponsiveAppViewport({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFEAF4F8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.maxAppWidth,
          ),
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    required this.child,
    this.maxWidth = 760,
    this.alignment = Alignment.topCenter,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

int responsiveColumnCount(
  double width, {
  int phone = 1,
  int tablet = 2,
  int desktop = 3,
}) {
  if (width >= AppBreakpoints.desktop) return desktop;
  if (width >= AppBreakpoints.tablet) return tablet;
  return phone;
}

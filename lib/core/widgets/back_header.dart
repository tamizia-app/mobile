import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import 'app_header.dart';

class BackHeader extends StatelessWidget {
  const BackHeader({
    required this.title,
    this.outsideCard = false,
    this.onBack,
    super.key,
  });
  final String title;
  final bool outsideCard;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) => AppHeader(
    title: title,
    showBack: true,
    onBack:
        onBack ??
        () => Navigator.pushReplacementNamed(context, AppRoutes.login),
  );
}

import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import 'info_banner.dart';

class PrivacyNotice extends StatelessWidget {
  const PrivacyNotice({super.key});
  @override
  Widget build(BuildContext context) =>
      const InfoBanner(text: AppStrings.privacyNotice);
}

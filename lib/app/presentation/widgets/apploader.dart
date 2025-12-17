import 'package:flutter/material.dart';

import '../../../core/utils/app_lottie.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: AppLottie(assetName: "loader", width: 90, height: 90));
  }
}
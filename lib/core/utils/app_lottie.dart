import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLottie extends StatelessWidget {
  final String assetName;
  final double? width, height;

  const AppLottie({super.key, required this.assetName, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset("assets/lottie/$assetName.json", width: width, height: height);
  }
}
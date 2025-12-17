import 'package:flutter/material.dart';
import 'package:todo_app/core/extensions/margin_extension.dart';

import '../../../core/constants/style.dart';
import '../../../core/utils/app_lottie.dart';

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({
    super.key,
    required this.message,
    this.onComplete,
    this.duration = const Duration(milliseconds: 2000),
  });

  final String message;
  final VoidCallback? onComplete;
  final Duration duration;

  static void show({
    required BuildContext context,
    required String message,
    VoidCallback? onComplete,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    // Show the dialog
    final dialogContext = GlobalKey<NavigatorState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final dialogContext = context;
        Future.delayed(duration, () {
          Navigator.of(dialogContext).pop(); // Close the dialog
          if (onComplete != null) {
            onComplete; // Execute the onComplete callback
          }
        });
        return SuccessDialog(
          message: message,
          onComplete: onComplete,
          duration: duration,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLottie(assetName: "success"),
            16.hBox,
            Text(
              message,
              style: AppTextStyles.textStyle_400_14.copyWith(
                fontSize: 13.53,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

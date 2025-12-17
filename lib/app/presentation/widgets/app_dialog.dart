import 'package:flutter/material.dart';
import 'package:todo_app/app/presentation/widgets/app_button.dart';

import '../../../core/constants/style.dart';
import '../../../core/utils/screen_utils.dart';


Future<bool?> appShowDialog(
  BuildContext context, {
  required String dialog,
  required String btnText,
  Function()? onTap,
  Function()? onTapNo,
}) {
  bool isProcessing = false;

  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        content: Text(
          dialog,
          textAlign: TextAlign.center,
          style: AppTextStyles.textStyle_500_14.copyWith(fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 16),
        actions: [
          AppButton(
            text: btnText,
            isExpand: false,
            isFilledBtn: false,
            onPressed: () {
              if (onTapNo != null) {
                onTapNo.call();
              } else {
                close(context);
              }
            },
            minHeight: 34,
          ),
          AppButton(
            text: "Yes",
            isExpand: false,
            onPressed: () {
              if (!isProcessing) {
                isProcessing = true;
                onTap?.call();
              }
            },
            minHeight: 34,
          ),
        ],
      );
    },
  );
}

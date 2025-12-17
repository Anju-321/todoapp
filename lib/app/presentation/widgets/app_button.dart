import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/style.dart';

class AppButton extends StatelessWidget {
  const AppButton(
      {super.key,
      this.onPressed,
      required this.text,
      this.btnRadius = 4,
      this.icon,
      this.isExpand = true,
      this.isRounded = true,
      this.isFilledBtn = true,
      this.isLoaderBtn = false,
      this.minHeight,
      this.textstyle,
      this.borderSideClr,
      this.btnClr = primaryClr,
      this.elevation,
      this.bgclr,
      this.isLightBaground = false});

  final void Function()? onPressed;
  final String text;
  final Color btnClr;
  final Color? borderSideClr, bgclr;
  final Widget? icon;
  final TextStyle? textstyle;
  final bool isExpand, isRounded, isFilledBtn, isLoaderBtn;
  final double? minHeight;
  final double btnRadius;
  final double? elevation;
  final bool isLightBaground;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isExpand ? double.infinity : null,
      height: minHeight,
      child: icon == null
          ? TextButton(
              onPressed: isLoaderBtn ? null : onPressed,
              style: _buildStyle(),
              child: ButtonText(
                text: text,
                btnClr: btnClr,
                isLoaderBtn: isLoaderBtn,
                isFilledBtn: isFilledBtn,
                isLightBaground: isLightBaground,
              ),
            )
          : TextButton.icon(
              onPressed: isLoaderBtn ? null : onPressed,
              style: _buildStyle(),
              icon: icon!,
              label: ButtonText(
                text: text,
                textstyle: textstyle,
                btnClr: btnClr,
                isLoaderBtn: isLoaderBtn,
                isFilledBtn: isFilledBtn,
                isLightBaground: isLightBaground,
              ),
            ),
    );
  }

  ButtonStyle _buildStyle() {
    return TextButton.styleFrom(
        elevation: elevation ?? (isFilledBtn ? 4 : 0),
        shadowColor: isFilledBtn ? btnClr : null,
        iconColor: Colors.white,
        padding: minHeight == null
            ? EdgeInsets.symmetric(horizontal: 16, vertical: isExpand ? 14 : 14)
            : null,
        backgroundColor: isFilledBtn ? btnClr : bgclr ?? Colors.white,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: borderSideClr ?? btnClr),
            borderRadius:
                BorderRadius.all(Radius.circular(isRounded ? btnRadius : 0))));
  }
}

class ButtonText extends StatelessWidget {
  const ButtonText(
      {super.key,
      required this.text,
      required this.btnClr,
      this.textstyle,
      required this.isFilledBtn,
      this.isLightBaground = false,
      this.isLoaderBtn = false,
      this.textClr = Colors.white});

  final String text;
  final Color btnClr;
  final TextStyle? textstyle;
  final bool isFilledBtn, isLoaderBtn;
  final bool isLightBaground;
  final Color textClr;

  @override
  Widget build(BuildContext context) {
    return isLoaderBtn
        ? const CupertinoActivityIndicator(
            color: Colors.black,
            animating: true,
          )
        : Text(
            text,
            style: textstyle ??
                (AppTextStyles.textStyle_600_14_poppins.copyWith(
                    color: isFilledBtn && isLightBaground
                        ? textClr
                        : isFilledBtn
                            ? Colors.white
                            : btnClr)),
          );
  }
}

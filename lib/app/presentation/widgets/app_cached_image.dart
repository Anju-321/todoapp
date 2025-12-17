import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/style.dart';

class CachedImage extends StatelessWidget {
  const CachedImage(
      {super.key,
      this.radius = 6.0,
      required this.imageUrl,
      this.height,
      this.width,
      this.bgClr,
      this.ismailImage,
      this.isAssetImg = false,
      this.isPreview = true,
      this.padding,
      this.fit,
      this.isDifferentRadius,
      this.borderRadiusType,
      this.access,
      this.ontap,
      this.vehicleType,
      this.gateName});

  final double radius;
  final String? imageUrl, access, vehicleType, gateName;
  final double? height, width;
  final Color? bgClr;
  final void Function()? ontap;

  final bool isAssetImg, isPreview;
  final bool? isDifferentRadius, ismailImage;
  final EdgeInsetsGeometry? padding;
  final BoxFit? fit;
  final BorderRadiusGeometry? borderRadiusType;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: ClipRRect(
        borderRadius: isDifferentRadius == true
            ? borderRadiusType ?? BorderRadius.circular(0)
            : BorderRadius.circular(radius),
        child: Container(
          padding: padding,
          color: bgClr ?? Colors.transparent,
          child: isAssetImg
              ? Image.asset(
                  imageUrl ?? "",
                  fit: BoxFit.cover,
                  height: height,
                  width: width,
                )
              : CachedNetworkImage(
                  fit: fit ?? BoxFit.fill,
                  height: height,
                  width: width,
                  imageUrl: imageUrl.toString(),
                  errorWidget: (_, __, ___) => Text(
                        vehicleType ?? "",
                        style: AppTextStyles.textStyle_700_14_poppins
                            .copyWith(color: whiteClr, fontSize: 22),
                      ),
                  //  (_, __, ___) => Image.asset(
                  //       "assets/images/default_image.png",
                  //       fit: fit ?? BoxFit.cover,
                  //       height: height,
                  //       width: width,
                  //     ),
                  placeholder: (_, __) => const ColoredBox(
                      color: Colors.transparent,
                      child: Center(child: CupertinoActivityIndicator()))),
        ),
      ),
    );
  }
}

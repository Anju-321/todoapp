import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_lottie.dart';

Future open<T extends StateStreamableSource>(
    BuildContext context, Widget page) {
  return Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) {
        try {
          return BlocProvider.value(value: context.read<T>(), child: page);
        } catch (_) {
          return page;
        }
      },
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
}

Future openClosingCurrent<T extends StateStreamableSource>(
    BuildContext context, Widget page) {
  return Navigator.pushReplacement(
    context, 
    PageRouteBuilder(
      pageBuilder: (_, __, ___) {
        try {
          return BlocProvider.value(value: context.read<T>(), child: page);
        } catch (_) {
          return page;
        }
      },
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
  
}

Future openAsNewPage(BuildContext context, Widget page) =>
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (route) => false
    );

// void openAsNewPage(BuildContext context, Widget page) {
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(builder: (context) => page),
//   );
// }


close(BuildContext context, {dynamic result}) => Navigator.pop(context, result);

closeDialog(BuildContext context, {dynamic result}) =>
    Navigator.of(context, rootNavigator: true).pop(result);



Future<void> showLoader(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible:
        false, // Prevent dismissing the dialog by tapping outside
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Transform.scale(
              scale: 1.8,
              child: const AppLottie(
                assetName: "loader",
                width: 80,
                height: 80,
              ),
            ),
          ),
        ),
      );
    },
  );
}

void hideLoader(BuildContext context) {
  // Check if the dialog is still visible before attempting to close
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
}

void showToastOnTop(BuildContext context, String message, {bool isError = true}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 10, // Add some margin from the top
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isError ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  // Insert the overlay entry
  overlay.insert(overlayEntry);

  // Remove the overlay entry after the duration
  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}



void showToast(BuildContext context, String message, {bool isError = true}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: isError ? Colors.red : Colors.green,
    duration: const Duration(seconds: 2),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

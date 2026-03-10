import 'package:flutter/material.dart';
import '../utils/constants.dart';


// I made two static helper methods here so I don't have to repeat
// snackbar boilerplate code everywhere. Red for errors, gold for success.


class CustomSnackbar {
  static void showError(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: kErrorRed,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
    ));
  }


  static void showSuccess(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.black)),
      backgroundColor: kAccentGold,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

import 'package:flutter/material.dart';
import '../utils/constants.dart';


// I wrap any screen with this widget and pass isLoading: true to show
// a gold spinner on top of everything. I use it on login, signup,
// and the add/edit place screens.


class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  const LoadingOverlay({required this.isLoading, required this.child, super.key});


  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      child,
      if (isLoading)
        Container(
          color: Colors.black54,
          child: const Center(
            child: CircularProgressIndicator(color: kAccentGold),
          ),
        ),
    ]);
  }
}

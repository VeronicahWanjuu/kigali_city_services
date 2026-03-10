import 'package:flutter/material.dart';
import '../utils/constants.dart';


// I show this centred widget whenever a list has nothing to display.
// The optional button lets me give the user something to do, like 'Add Place'.


class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;


  const EmptyStateWidget({
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonLabel,
    this.onButtonTap,
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: kTextSecondary, size: 64),
          const SizedBox(height: 16),
          Text(title, style: kHeadingMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(subtitle!, style: kCaptionText, textAlign: TextAlign.center),
            ),
          ],
          if (buttonLabel != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onButtonTap,
              child: Text(buttonLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

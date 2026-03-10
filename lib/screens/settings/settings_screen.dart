import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_snackbar.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final user = auth.currentUser;
    return Scaffold(
      backgroundColor: kPrimaryDark,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          // profile avatar showing first letter of display name
          Center(child: Column(children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: kAccentGold.withValues(alpha: 0.2),
              child: Text(
                user?.displayName.isNotEmpty == true
                  ? user!.displayName[0].toUpperCase() : '?',
                style: const TextStyle(color: kAccentGold, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(user?.displayName ?? '', style: kHeadingMedium),
            const SizedBox(height: 4),
            Text(user?.email ?? '', style: kCaptionText),
          ])),
          const SizedBox(height: 32),
          // notifications toggle
          Container(
            decoration: BoxDecoration(color: kCardDark, borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: const Text('Notifications', style: kBodyText),
              subtitle: const Text('Receive app notifications', style: kCaptionText),
              trailing: Switch(
                value: user?.notificationsEnabled ?? false,
                onChanged: (val) async {
                  await context.read<AppAuthProvider>().updateNotificationPreference(val);
                  if (context.mounted) {
                    CustomSnackbar.showSuccess(context,
                      val ? 'Notifications enabled' : 'Notifications disabled');
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // member since date
          Container(
            decoration: BoxDecoration(color: kCardDark, borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: const Text('Member since', style: kBodyText),
              trailing: Text(
                user?.createdAt != null
                  ? '${user!.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                  : 'Unknown',
                style: kCaptionText,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // sign out button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.read<AppAuthProvider>().signOut(),
              icon: const Icon(Icons.logout, color: kErrorRed),
              label: const Text('Sign Out', style: TextStyle(color: kErrorRed)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kErrorRed),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../models/customer_profile.dart';
import '../providers/auth_provider.dart';

/// Admin and delivery users belong to their own apps/panels. This screen keeps
/// the role routing honest in the customer app without building those areas.
class RolePlaceholderScreen extends StatelessWidget {
  const RolePlaceholderScreen({super.key, required this.profile});

  final CustomerProfile profile;

  @override
  Widget build(BuildContext context) {
    final isAdmin = profile.role.name == 'admin';
    return Scaffold(
      appBar: AppBar(title: const Text('Account role')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.admin_panel_settings_outlined,
              size: 72,
              color: TatitoColors.brandGreen,
            ),
            const SizedBox(height: 18),
            Text(
              isAdmin ? 'Use the Admin Panel' : 'Use the Delivery App',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: TatitoColors.brandBlack,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isAdmin
                  ? 'Signed in as ${profile.name}. Admin tools live at /admin on the Laravel backend, not in the customer app.'
                  : 'Signed in as ${profile.name}. Assigned deliveries live in the Tatito delivery partner app.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: TatitoColors.textMuted, height: 1.5),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

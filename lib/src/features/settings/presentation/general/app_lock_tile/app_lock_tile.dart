import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../widgets/input_popup/domain/settings_prop_type.dart';
import '../../../../../widgets/input_popup/settings_prop_tile.dart';
import '../../../../app_lock/providers/app_lock_providers.dart';

class AppLockTile extends ConsumerWidget {
  const AppLockTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const SizedBox.shrink();
    }

    final isAppLockEnabled = ref.watch(appLockEnabledProvider) ?? false;

    return SettingsPropTile(
      title: 'App Lock (Fingerprint)',
      subtitle: 'Require biometric authentication to open the app',
      leading: const Icon(Icons.fingerprint_rounded),
      type: SettingsPropType<void>.switchTile(
        value: isAppLockEnabled,
        onChanged: (value) async {
          if (value) {
            // Check if can authenticate before enabling
            final localAuth = ref.read(localAuthProvider);
            final canCheck = await localAuth.canCheckBiometrics;
            if (!canCheck) {
              return; // Could show a toast here
            }
          }
          ref.read(appLockEnabledProvider.notifier).update(value);
          if (!value) {
            ref.read(appLockedProvider.notifier).state = false;
          } else {
            // Immediately lock to require auth or simply let it require on next startup
            ref.read(appLockedProvider.notifier).state = true;
          }
        },
      ),
    );
  }
}

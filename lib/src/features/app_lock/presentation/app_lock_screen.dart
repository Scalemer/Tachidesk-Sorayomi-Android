import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../providers/app_lock_providers.dart';

class AppLockScreen extends ConsumerWidget {
  const AppLockScreen({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocked = ref.watch(appLockedProvider);

    if (!isLocked) {
      return child;
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_rounded, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'App Locked',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () async {
                final localAuth = ref.read(localAuthProvider);
                try {
                  final didAuthenticate = await localAuth.authenticate(
                    localizedReason: 'Please authenticate to unlock Sorayomi',
                    biometricOnly: true,
                    stickyAuth: true,
                  );
                  if (didAuthenticate) {
                    ref.read(appLockedProvider.notifier).state = false;
                  }
                } on PlatformException catch (_) {
                  // Fallback: if biometric is not available or fails, maybe just allow for now?
                  // Or show an error toast.
                }
              },
              icon: const Icon(Icons.fingerprint_rounded),
              label: const Text('Unlock with Fingerprint'),
            ),
          ],
        ),
      ),
    );
  }
}

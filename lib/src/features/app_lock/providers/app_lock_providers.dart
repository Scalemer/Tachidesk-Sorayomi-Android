import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../constants/db_keys.dart';
import '../../../utils/mixin/shared_preferences_client_mixin.dart';

part 'app_lock_providers.g.dart';

@riverpod
class AppLockEnabled extends _$AppLockEnabled
    with SharedPreferenceClientMixin<bool> {
  @override
  bool? build() => initialize(DBKeys.appLockEnabled);
}

final appLockedProvider = StateProvider<bool>((ref) {
  final enabled = ref.watch(appLockEnabledProvider) ?? false;
  return enabled;
});

final localAuthProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

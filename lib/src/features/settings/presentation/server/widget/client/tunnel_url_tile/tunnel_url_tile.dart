import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../../constants/db_keys.dart';
import '../../../../../../../utils/mixin/shared_preferences_client_mixin.dart';
import '../../../../../../../widgets/input_popup/domain/settings_prop_type.dart';
import '../../../../../../../widgets/input_popup/settings_prop_tile.dart';

part 'tunnel_url_tile.g.dart';

@riverpod
class TunnelUrlEnabled extends _$TunnelUrlEnabled
    with SharedPreferenceClientMixin<bool> {
  @override
  bool? build() => initialize(DBKeys.tunnelUrlEnabled);
}

class TunnelUrlTile extends ConsumerWidget {
  const TunnelUrlTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tunnelUrlEnabled = ref.watch(tunnelUrlEnabledProvider);
    return SettingsPropTile(
      title: 'Tunnel URL Connecter',
      subtitle: 'Use server URL as a direct tunnel URL (ignores port)',
      leading: const Icon(Icons.compare_arrows_rounded),
      type: SettingsPropType<void>.switchTile(
        value: tunnelUrlEnabled ?? DBKeys.tunnelUrlEnabled.initial,
        onChanged: (value) async {
          ref.read(tunnelUrlEnabledProvider.notifier).update(value);
        },
      ),
    );
  }
}

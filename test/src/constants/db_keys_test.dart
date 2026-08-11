// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter_test/flutter_test.dart';
import 'package:tachidesk_sorayomi/src/constants/db_keys.dart';

void main() {
  test('uses the recovered network defaults', () {
    expect(DBKeys.serverRequestTimeout.initial, 30000);
    expect(DBKeys.autoRefreshOnTimeout.initial, isTrue);
    expect(DBKeys.autoRefreshRetryDelay.initial, 1500);
  });
}

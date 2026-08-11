// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter_test/flutter_test.dart';
import 'package:tachidesk_sorayomi/src/constants/enum.dart';
import 'package:tachidesk_sorayomi/src/features/manga_book/presentation/reader/utils/last_page_swipe_utils.dart';

void main() {
  test('existing persisted reader mode indexes stay stable', () {
    expect(
      ReaderMode.values.take(8),
      const [
        ReaderMode.defaultReader,
        ReaderMode.continuousVertical,
        ReaderMode.singleHorizontalLTR,
        ReaderMode.singleHorizontalRTL,
        ReaderMode.continuousHorizontalLTR,
        ReaderMode.continuousHorizontalRTL,
        ReaderMode.singleVertical,
        ReaderMode.webtoon,
      ],
    );
    expect(ReaderMode.doubleHorizontalLTR.index, 8);
    expect(ReaderMode.doubleHorizontalRTL.index, 9);
  });

  test('double-page swipe directions follow reading direction', () {
    expect(
      LastPageSwipeUtils.getExpectedSwipeDirection(
        ReaderMode.doubleHorizontalLTR,
      ),
      SwipeDirection.left,
    );
    expect(
      LastPageSwipeUtils.getExpectedSwipeDirection(
        ReaderMode.doubleHorizontalRTL,
      ),
      SwipeDirection.right,
    );
  });
}

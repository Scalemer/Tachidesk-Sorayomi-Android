// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter_test/flutter_test.dart';
import 'package:tachidesk_sorayomi/src/features/manga_book/presentation/reader/utils/double_page_spread.dart';

void main() {
  List<List<int>> indexesOf(List<DoublePageSpread> spreads) =>
      spreads.map((spread) => spread.pageIndexes).toList();

  group('buildDoublePageSpreads', () {
    test('handles empty, single, odd, and even page counts', () {
      expect(
        indexesOf(buildDoublePageSpreads(landscapePages: const [])),
        isEmpty,
      );
      expect(
        indexesOf(buildDoublePageSpreads(landscapePages: const [false])),
        const [
          [0],
        ],
      );
      expect(
        indexesOf(
          buildDoublePageSpreads(
            landscapePages: const [false, false, false],
          ),
        ),
        const [
          [0, 1],
          [2],
        ],
      );
      expect(
        indexesOf(
          buildDoublePageSpreads(
            landscapePages: const [false, false, false, false],
          ),
        ),
        const [
          [0, 1],
          [2, 3],
        ],
      );
    });

    test('offsets the first page without duplicating pages', () {
      expect(
        indexesOf(
          buildDoublePageSpreads(
            landscapePages: const [false, false, false, false, false],
            offsetFirstPage: true,
          ),
        ),
        const [
          [0],
          [1, 2],
          [3, 4],
        ],
      );
    });

    test('landscape pages occupy a full spread and preserve later pairing', () {
      expect(
        indexesOf(
          buildDoublePageSpreads(
            landscapePages: const [
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false,
            ],
          ),
        ),
        const [
          [0, 1],
          [2],
          [3],
          [4],
          [5, 6],
          [7],
        ],
      );
    });

    test('landscape pages preserve offset pairing', () {
      expect(
        indexesOf(
          buildDoublePageSpreads(
            landscapePages: const [
              false,
              false,
              false,
              true,
              false,
              false,
              false,
              false,
            ],
            offsetFirstPage: true,
          ),
        ),
        const [
          [0],
          [1, 2],
          [3],
          [4, 5],
          [6, 7],
        ],
      );
    });
  });

  group('spreadIndexForPage', () {
    final spreads = buildDoublePageSpreads(
      landscapePages: const [false, false, true, false, false],
    );

    test('maps either visible page to its spread', () {
      expect(spreadIndexForPage(spreads, 0), 0);
      expect(spreadIndexForPage(spreads, 1), 0);
      expect(spreadIndexForPage(spreads, 2), 1);
      expect(spreadIndexForPage(spreads, 3), 2);
      expect(spreadIndexForPage(spreads, 4), 2);
    });

    test('clamps stale progress values', () {
      expect(spreadIndexForPage(spreads, -10), 0);
      expect(spreadIndexForPage(spreads, 100), spreads.length - 1);
      expect(spreadIndexForPage(const [], 100), 0);
    });

    test('uses the last visible source page as canonical progress', () {
      expect(spreads[0].canonicalPageIndex, 1);
      expect(spreads[1].canonicalPageIndex, 2);
      expect(spreads[2].canonicalPageIndex, 4);
    });
  });

  test('reading direction only changes the visual page order', () {
    const spread = DoublePageSpread(
      primaryPageIndex: 4,
      secondaryPageIndex: 5,
    );

    expect(
      spread.visualPageIndexes(rightToLeft: false),
      const [4, 5],
    );
    expect(
      spread.visualPageIndexes(rightToLeft: true),
      const [5, 4],
    );
    expect(spread.canonicalPageIndex, 5);
  });
}

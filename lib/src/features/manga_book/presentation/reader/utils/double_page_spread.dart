// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/foundation.dart';

/// A reader spread containing one page or two adjacent portrait pages.
///
/// Page indexes always retain chapter/source order. Reading direction is a
/// presentation concern and must not change these values.
@immutable
class DoublePageSpread {
  const DoublePageSpread({
    required this.primaryPageIndex,
    this.secondaryPageIndex,
  });

  final int primaryPageIndex;
  final int? secondaryPageIndex;

  int get canonicalPageIndex => secondaryPageIndex ?? primaryPageIndex;

  List<int> get pageIndexes => [
        primaryPageIndex,
        if (secondaryPageIndex case final secondary?) secondary,
      ];

  List<int> visualPageIndexes({required bool rightToLeft}) =>
      rightToLeft ? pageIndexes.reversed.toList() : pageIndexes;

  bool containsPage(int pageIndex) =>
      primaryPageIndex == pageIndex || secondaryPageIndex == pageIndex;

  DoublePageSpread withSecondaryPage(int pageIndex) => DoublePageSpread(
        primaryPageIndex: primaryPageIndex,
        secondaryPageIndex: pageIndex,
      );
}

/// Builds stable double-page spreads from chapter pages.
///
/// A landscape image occupies two virtual page slots. This keeps portrait
/// pages after it paired correctly instead of shifting the same image through
/// two neighboring spreads. When [offsetFirstPage] is enabled the cover is
/// displayed alone and pairing starts at page 1.
List<DoublePageSpread> buildDoublePageSpreads({
  required List<bool> landscapePages,
  bool offsetFirstPage = false,
}) {
  if (landscapePages.isEmpty) return const [];

  final spreads = <DoublePageSpread>[];
  var precedingLandscapePageCount = 0;

  for (var pageIndex = 0; pageIndex < landscapePages.length; pageIndex++) {
    final isLandscape = landscapePages[pageIndex];
    final virtualPageIndex = pageIndex + precedingLandscapePageCount;
    final isVirtualPageEven = virtualPageIndex.isEven;
    final partnerOffset = offsetFirstPage
        ? (isVirtualPageEven ? -1 : 1)
        : (isVirtualPageEven ? 1 : -1);
    final partnerIndex = pageIndex + partnerOffset;
    final hasValidPartner = partnerIndex >= 0 &&
        partnerIndex < landscapePages.length &&
        !isLandscape &&
        !landscapePages[partnerIndex] &&
        !(offsetFirstPage && pageIndex == 0);

    if (hasValidPartner && partnerIndex < pageIndex) {
      final previousSpread = spreads.last;
      if (previousSpread.primaryPageIndex == partnerIndex &&
          previousSpread.secondaryPageIndex == null) {
        spreads[spreads.length - 1] =
            previousSpread.withSecondaryPage(pageIndex);
      } else {
        spreads.add(DoublePageSpread(primaryPageIndex: pageIndex));
      }
    } else {
      spreads.add(DoublePageSpread(primaryPageIndex: pageIndex));
    }

    if (isLandscape) precedingLandscapePageCount++;
  }

  return spreads;
}

/// Returns the spread containing [pageIndex], clamping stale progress values.
int spreadIndexForPage(
  List<DoublePageSpread> spreads,
  int pageIndex,
) {
  if (spreads.isEmpty) return 0;

  final lastPageIndex = spreads.last.canonicalPageIndex;
  final clampedPageIndex = pageIndex.clamp(0, lastPageIndex);
  final spreadIndex =
      spreads.indexWhere((spread) => spread.containsPage(clampedPageIndex));

  return spreadIndex < 0 ? spreads.length - 1 : spreadIndex;
}

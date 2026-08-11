// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../constants/app_constants.dart';
import '../../../../../../utils/extensions/cache_manager_extensions.dart';
import '../../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../../utils/misc/app_utils.dart';
import '../../../../../../widgets/custom_circular_progress_indicator.dart';
import '../../../../../../widgets/server_image.dart';
import '../../../../../settings/presentation/reader/widgets/reader_scroll_animation_tile/reader_scroll_animation_tile.dart';
import '../../../../domain/chapter/chapter_model.dart';
import '../../../../domain/chapter_page/chapter_page_model.dart';
import '../../../../domain/manga/manga_model.dart';
import '../../utils/double_page_spread.dart';
import '../reader_wrapper.dart';

class DoublePageReaderMode extends HookConsumerWidget {
  const DoublePageReaderMode({
    super.key,
    required this.manga,
    required this.chapter,
    required this.chapterPages,
    required this.reverse,
    required this.offsetFirstPage,
    this.onPageChanged,
    this.showReaderLayoutAnimation = false,
  });

  final MangaDto manga;
  final ChapterDto chapter;
  final ChapterPagesDto chapterPages;
  final bool reverse;
  final bool offsetFirstPage;
  final ValueSetter<int>? onPageChanged;
  final bool showReaderLayoutAnimation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageCount = chapterPages.pages.length;
    final cacheManager = useMemoized(() => DefaultCacheManager());
    final landscapePages = useState(List<bool>.filled(pageCount, false));

    useEffect(() {
      landscapePages.value = List<bool>.filled(pageCount, false);
      return null;
    }, [pageCount]);

    final spreads = useMemoized(
      () => buildDoublePageSpreads(
        landscapePages: landscapePages.value,
        offsetFirstPage: offsetFirstPage,
      ),
      [landscapePages.value, offsetFirstPage],
    );
    final initialPageIndex = chapter.isRead.ifNull()
        ? 0
        : chapter.lastPageRead
            .getValueOnNullOrNegative()
            .clamp(0, pageCount > 0 ? pageCount - 1 : 0);
    final initialSpreadIndex = spreadIndexForPage(spreads, initialPageIndex);
    final scrollController = usePageController(initialPage: initialSpreadIndex);
    final currentPageIndex = useState(
      spreads.isEmpty ? 0 : spreads[initialSpreadIndex].canonicalPageIndex,
    );
    final previousSpreads = useRef(spreads);
    final previousOffset = useRef(offsetFirstPage);

    useEffect(() {
      if (spreads.isEmpty) return null;

      var anchorPageIndex = currentPageIndex.value;
      if (previousOffset.value != offsetFirstPage && offsetFirstPage) {
        final oldSpreadIndex = spreadIndexForPage(
          previousSpreads.value,
          currentPageIndex.value,
        );
        anchorPageIndex =
            previousSpreads.value[oldSpreadIndex].primaryPageIndex;
      }

      final targetSpreadIndex = spreadIndexForPage(spreads, anchorPageIndex);
      currentPageIndex.value = spreads[targetSpreadIndex].canonicalPageIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients &&
            scrollController.page?.round() != targetSpreadIndex) {
          scrollController.jumpToPage(targetSpreadIndex);
        }
      });
      previousSpreads.value = spreads;
      previousOffset.value = offsetFirstPage;
      return null;
    }, [spreads]);

    useEffect(() {
      void listener() {
        final page = scrollController.page;
        if (page == null || spreads.isEmpty) return;
        final spreadIndex = page.round().clamp(0, spreads.length - 1);
        final sourcePageIndex = spreads[spreadIndex].canonicalPageIndex;
        if (currentPageIndex.value != sourcePageIndex) {
          currentPageIndex.value = sourcePageIndex;
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController, spreads]);

    useEffect(() {
      onPageChanged?.call(currentPageIndex.value);
      if (spreads.isEmpty) return null;

      final currentSpreadIndex =
          spreadIndexForPage(spreads, currentPageIndex.value);
      final firstSpread = (currentSpreadIndex - 1).clamp(0, spreads.length - 1);
      final lastSpread = (currentSpreadIndex + 2).clamp(0, spreads.length - 1);
      for (var spreadIndex = firstSpread;
          spreadIndex <= lastSpread;
          spreadIndex++) {
        for (final pageIndex in spreads[spreadIndex].pageIndexes) {
          cacheManager.getServerFile(ref, chapterPages.pages[pageIndex]);
        }
      }
      return null;
    }, [currentPageIndex.value, spreads]);

    void reportImageSize(int pageIndex, Size imageSize) {
      if (pageIndex >= landscapePages.value.length) return;
      final isLandscape = imageSize.width > imageSize.height;
      if (landscapePages.value[pageIndex] == isLandscape) return;

      if (spreads.isNotEmpty) {
        final visibleSpread =
            spreads[spreadIndexForPage(spreads, currentPageIndex.value)];
        if (visibleSpread.containsPage(pageIndex)) {
          currentPageIndex.value = visibleSpread.primaryPageIndex;
        }
      }

      final updatedLandscapePages = [...landscapePages.value];
      updatedLandscapePages[pageIndex] = isLandscape;
      landscapePages.value = updatedLandscapePages;
    }

    Widget buildImage(
      int pageIndex, {
      required double width,
      required Alignment alignment,
    }) =>
        ServerImage(
          showReloadButton: true,
          fit: BoxFit.contain,
          alignment: alignment,
          size: Size(width, context.height),
          appendApiToUrl: false,
          imageUrl: chapterPages.pages[pageIndex],
          onImageLoaded: (size) => reportImageSize(pageIndex, size),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CenterSorayomiShimmerIndicator(
            value: downloadProgress.progress,
          ),
        );

    Widget buildSpread(DoublePageSpread spread) {
      final secondaryPageIndex = spread.secondaryPageIndex;
      if (secondaryPageIndex == null) {
        return buildImage(
          spread.primaryPageIndex,
          width: context.width,
          alignment: Alignment.center,
        );
      }

      final visualPageIndexes = spread.visualPageIndexes(rightToLeft: reverse);
      final leftPage = Expanded(
        child: buildImage(
          visualPageIndexes.first,
          width: context.width / 2,
          alignment: Alignment.centerRight,
        ),
      );
      final rightPage = Expanded(
        child: buildImage(
          visualPageIndexes.last,
          width: context.width / 2,
          alignment: Alignment.centerLeft,
        ),
      );
      return Row(children: [leftPage, rightPage]);
    }

    final isAnimationEnabled =
        ref.read(readerScrollAnimationProvider).ifNull(true);

    return ReaderWrapper(
      scrollDirection: Axis.horizontal,
      chapter: chapter,
      manga: manga,
      chapterPages: chapterPages,
      currentIndex: currentPageIndex.value,
      onChanged: (pageIndex) {
        if (spreads.isEmpty) return;
        scrollController.jumpToPage(spreadIndexForPage(spreads, pageIndex));
      },
      showReaderLayoutAnimation: showReaderLayoutAnimation,
      onPrevious: () => scrollController.previousPage(
        duration: isAnimationEnabled ? kDuration : kInstantDuration,
        curve: kCurve,
      ),
      onNext: () => scrollController.nextPage(
        duration: isAnimationEnabled ? kDuration : kInstantDuration,
        curve: kCurve,
      ),
      pageController: scrollController,
      pageIndexMapper: (spreadIndex) => spreads.isEmpty
          ? 0
          : spreads[spreadIndex.clamp(0, spreads.length - 1)]
              .canonicalPageIndex,
      child: PageView.builder(
        reverse: reverse,
        controller: scrollController,
        allowImplicitScrolling: true,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: spreads.isEmpty ? 1 : spreads.length,
        itemBuilder: (context, spreadIndex) {
          if (spreads.isEmpty) {
            return const Center(child: CenterSorayomiShimmerIndicator());
          }

          return AppUtils.wrapOn(
            !kIsWeb && (Platform.isAndroid || Platform.isIOS)
                ? (child) => InteractiveViewer(maxScale: 5, child: child)
                : null,
            buildSpread(spreads[spreadIndex]),
          );
        },
      ),
    );
  }
}

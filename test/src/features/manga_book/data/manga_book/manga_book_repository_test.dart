// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:tachidesk_sorayomi/src/features/manga_book/data/manga_book/manga_book_repository.dart';

void main() {
  group('MangaBookRepository.getChapterPages', () {
    test('retries once when the first page list is empty', () async {
      final fakeLink = _QueuedChapterPagesLink([
        _chapterPagesResponse(const []),
        _chapterPagesResponse(const ['1.jpg', '2.jpg']),
      ]);
      final repository = MangaBookRepository(
        _client(fakeLink),
        chapterPagesRetryDelay: Duration.zero,
      );

      final result = await repository.getChapterPages(chapterId: 42);

      expect(result?.pages, ['1.jpg', '2.jpg']);
      expect(fakeLink.callCount, 2);
    });

    test('does not retry when the first page list is populated', () async {
      final fakeLink = _QueuedChapterPagesLink([
        _chapterPagesResponse(const ['1.jpg']),
      ]);
      final repository = MangaBookRepository(
        _client(fakeLink),
        chapterPagesRetryDelay: Duration.zero,
      );

      final result = await repository.getChapterPages(chapterId: 42);

      expect(result?.pages, ['1.jpg']);
      expect(fakeLink.callCount, 1);
    });

    test('stops after one retry when both page lists are empty', () async {
      final fakeLink = _QueuedChapterPagesLink([
        _chapterPagesResponse(const []),
        _chapterPagesResponse(const []),
      ]);
      final repository = MangaBookRepository(
        _client(fakeLink),
        chapterPagesRetryDelay: Duration.zero,
      );

      final result = await repository.getChapterPages(chapterId: 42);

      expect(result?.pages, isEmpty);
      expect(fakeLink.callCount, 2);
    });
  });
}

GraphQLClient _client(Link link) => GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );

Map<String, dynamic> _chapterPagesResponse(List<String> pages) => {
      '__typename': 'Mutation',
      'fetchChapterPages': {
        '__typename': 'FetchChapterPagesPayload',
        'chapter': {
          '__typename': 'ChapterType',
          'id': 42,
          'pageCount': pages.length,
        },
        'pages': pages,
      },
    };

class _QueuedChapterPagesLink extends Link {
  _QueuedChapterPagesLink(this.responses);

  final List<Map<String, dynamic>> responses;
  int callCount = 0;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    final response = responses[callCount];
    callCount += 1;
    return Stream.value(Response(data: response, response: const {}));
  }
}

// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:graphql/client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../global_providers/global_providers.dart';
import '../../../../graphql/__generated__/schema.graphql.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../library/domain/category/category_model.dart';
import '../../domain/chapter/chapter_model.dart';
import '../../domain/chapter_batch/chapter_batch_model.dart';
import '../../domain/chapter_page/chapter_page_model.dart';
import '../../domain/manga/manga_model.dart';
import './__generated__/query.graphql.dart';

part 'manga_book_repository.g.dart';

class MangaBookRepository {
  const MangaBookRepository(
    this.client, {
    this.chapterPagesRetryDelay = const Duration(milliseconds: 1500),
  });

  final GraphQLClient client;
  final Duration chapterPagesRetryDelay;

  Future<MangaDto?> addMangaToLibrary(int mangaId) => client
      .mutate$UpdateManga(
        Options$Mutation$UpdateManga(
          variables: Variables$Mutation$UpdateManga(
            input: Input$UpdateMangaInput(
              id: mangaId,
              patch: Input$UpdateMangaPatchInput(inLibrary: true),
            ),
          ),
        ),
      )
      .getData((data) => data.updateManga?.manga);

  Future<void> removeMangaFromLibrary(int mangaId) => client
      .mutate$UpdateManga(
        Options$Mutation$UpdateManga(
          variables: Variables$Mutation$UpdateManga(
            input: Input$UpdateMangaInput(
              id: mangaId,
              patch: Input$UpdateMangaPatchInput(inLibrary: false),
            ),
          ),
        ),
      )
      .getData((data) => data.updateManga?.manga);

  Future<void> modifyBulkChapters(ChapterBatch batch) =>
      client.mutate$UpdateChapters(
        Options$Mutation$UpdateChapters(
          variables: Variables$Mutation$UpdateChapters(input: batch),
        ),
      );

  Future<void> deleteChapters(List<int> chapterIds) =>
      client.mutate$DeleteDownloadedChapters(
        Options$Mutation$DeleteDownloadedChapters(
          variables: Variables$Mutation$DeleteDownloadedChapters(
            input: Input$DeleteDownloadedChaptersInput(ids: chapterIds),
          ),
        ),
      );

  // Mangas
  Future<MangaDto?> getManga({
    required int mangaId,
  }) =>
      client
          .query$GetManga(Options$Query$GetManga(
            variables: Variables$Query$GetManga(id: mangaId),
          ))
          .getData((data) => data.manga);

  Future<List<CategoryDto>?> getMangaCategoryList({
    required int mangaId,
  }) async =>
      client
          .query$GetMangaCategories(
            Options$Query$GetMangaCategories(
              variables: Variables$Query$GetMangaCategories(id: mangaId),
            ),
          )
          .getData((data) => data.manga.categories.nodes);

  Future<void> addMangaToCategory(int mangaId, int categoryId) =>
      client.mutate$UpdateMangaCategories(
        Options$Mutation$UpdateMangaCategories(
          variables: Variables$Mutation$UpdateMangaCategories(
            updateCategoryInput: Input$UpdateMangaCategoriesInput(
              id: mangaId,
              patch: Input$UpdateMangaCategoriesPatchInput(
                addToCategories: [categoryId],
              ),
            ),
          ),
        ),
      );

  Future<void> removeMangaFromCategory(int mangaId, int categoryId) =>
      client.mutate$UpdateMangaCategories(
        Options$Mutation$UpdateMangaCategories(
          variables: Variables$Mutation$UpdateMangaCategories(
            updateCategoryInput: Input$UpdateMangaCategoriesInput(
              id: mangaId,
              patch: Input$UpdateMangaCategoriesPatchInput(
                removeFromCategories: [categoryId],
              ),
            ),
          ),
        ),
      );

  // Chapters

  Future<ChapterDto?> getChapter({
    required int chapterId,
  }) async =>
      client
          .query$GetChapter(
            Options$Query$GetChapter(
              variables: Variables$Query$GetChapter(
                id: chapterId,
              ),
            ),
          )
          .getData((data) => data.chapter);

  Future<ChapterPagesDto?> getChapterPages({
    required int chapterId,
  }) async {
    Future<ChapterPagesDto?> fetchPages() => client
        .mutate$GetChapterPages(
          Options$Mutation$GetChapterPages(
            variables: Variables$Mutation$GetChapterPages(
              input: Input$FetchChapterPagesInput(chapterId: chapterId),
            ),
          ),
        )
        .getData((data) => data.fetchChapterPages);

    final result = await fetchPages();
    if (result?.pages.isNotEmpty ?? false) {
      return result;
    }

    // Some Suwayomi sources return an empty page list while the first request
    // warms the chapter cache. Retry once so the reader can recover without
    // requiring the user to leave and reopen the chapter.
    await Future<void>.delayed(chapterPagesRetryDelay);
    return fetchPages();
  }

  Future<void> putChapter({
    required int chapterId,
    required ChapterChange patch,
  }) async =>
      client.mutate$UpdateChapter(
        Options$Mutation$UpdateChapter(
          variables: Variables$Mutation$UpdateChapter(
            input: Input$UpdateChapterInput(
              id: chapterId,
              patch: patch,
            ),
          ),
        ),
      );

  Future<void> patchMangaMeta({
    required int mangaId,
    required String key,
    required dynamic value,
  }) async =>
      client.mutate$SetMangaMeta(
        Options$Mutation$SetMangaMeta(
          variables: Variables$Mutation$SetMangaMeta(
            input: Input$SetMangaMetaInput(
              meta: Input$MangaMetaTypeInput(
                key: key,
                mangaId: mangaId,
                value: value,
              ),
            ),
          ),
        ),
      );

  Future<List<ChapterDto>?> getChapterList(int mangaId) async => client
      .mutate$GetChaptersByMangaId(
        Options$Mutation$GetChaptersByMangaId(
          variables: Variables$Mutation$GetChaptersByMangaId(
            input: Input$FetchChaptersInput(
              mangaId: mangaId,
            ),
          ),
        ),
      )
      .getData((data) => data.fe…576 tokens truncated…initial,
      port: ref.watch(serverPortProvider),
      addPort: ref.watch(serverPortToggleProvider).ifNull(),
      isGraphQl: true,
    ),
    followRedirects: true,
    // httpResponseDecoder: httpResponseDecoder,
    defaultHeaders: {'Content-Type': 'application/json; charset=utf-8'},
    httpClient: TimeoutHttpClient(
      Duration(milliseconds: timeoutMs),
      retries: autoRetry ? 1 : 0,
      retryDelay: Duration(milliseconds: retryDelayMs),
    ),
  );

  // Auto retry is handled by TimeoutHttpClient retries instead of RetryLink

  // Basic authentication link
  if (authType == AuthType.basic && credentials.isNotBlank) {
    final AuthLink authLink = AuthLink(getToken: () => credentials);
    link = authLink.concat(link);
  }

  final loggerLink = LoggerLink();
  return GraphQLClient(
    link: loggerLink.concat(link),
    defaultPolicies: DefaultPolicies(
      query: Policies(fetch: FetchPolicy.noCache),
    ),
    cache: GraphQLCache(store: ref.watch(hiveStoreProvider)),
  );
}

@riverpod
GraphQLClient graphQlSubscriptionClient(Ref ref) {
  final authType = ref.watch(authTypeKeyProvider) ?? DBKeys.authType.initial;
  final credentials = ref.watch(credentialsProvider);
  Link link = WebSocketLink(
      Endpoints.baseApi(
        baseUrl: ref.watch(serverUrlProvider) ?? DBKeys.serverUrl.initial,
        port: ref.watch(serverPortProvider),
        addPort: ref.watch(serverPortToggleProvider).ifNull(),
        isGraphQl: true,
        isWebsocket: true,
      ),
      subProtocol: GraphQLProtocol.graphqlTransportWs);
  if (authType == AuthType.basic && credentials.isNotBlank) {
    final AuthLink authLink = AuthLink(getToken: () => credentials);
    link = authLink.concat(link);
  }
  final loggerLink = LoggerLink();
  return GraphQLClient(
    link: loggerLink.concat(link),
    defaultPolicies: DefaultPolicies(
      query: Policies(fetch: FetchPolicy.noCache),
    ),
    cache: GraphQLCache(store: ref.watch(hiveStoreProvider)),
  );
}

@riverpod
ValueNotifier<GraphQLClient> graphQlClientNotifier(Ref ref) {
  final notifier = ValueNotifier(ref.watch(graphQlClientProvider));
  // Dispose of the notifier when the provider is destroyed
  ref.onDispose(notifier.dispose);

  // Notify listeners of this provider whenever the ValueNotifier updates.
  notifier.addListener(ref.notifyListeners);

  return notifier;
}

@riverpod
class AuthTypeKey extends _$AuthTypeKey
    with SharedPreferenceEnumClientMixin<AuthType> {
  @override
  AuthType? build() => initialize(
        DBKeys.authType,
        enumList: AuthType.values,
      );
}

@riverpod
class L10n extends _$L10n with SharedPreferenceClientMixin<Locale> {
  Map<String, String> toJson(Locale locale) => {
        if (locale.countryCode.isNotBlank) "countryCode": locale.countryCode!,
        if (locale.languageCode.isNotBlank) "languageCode": locale.languageCode,
        if (locale.scriptCode.isNotBlank) "scriptCode": locale.scriptCode!,
      };
  Locale? fromJson(dynamic json) =>
      json is! Map<String, dynamic> || (json["languageCode"] == null)
          ? null
          : Locale.fromSubtags(
              languageCode: json["languageCode"]!.toString(),
              scriptCode: json["scriptCode"]?.toString(),
              countryCode: json["countryCode"]?.toString(),
            );
  @override
  Locale? build() => initialize(
        DBKeys.l10n,
        fromJson: fromJson,
        toJson: toJson,
      );
}

@riverpod
SharedPreferences sharedPreferences(ref) => throw UnimplementedError();

@riverpod
HiveStore hiveStore(Ref ref) => throw UnimplementedError();

@riverpod
Queue rateLimitQueue(Ref ref, [String? query]) {
  final queue = Queue(
    parallel: 3,
    delay: const Duration(milliseconds: 500),
  );
  ref.onDispose(() {
    queue.cancel();
  });
  return queue;
}

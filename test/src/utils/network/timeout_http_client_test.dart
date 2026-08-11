// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tachidesk_sorayomi/src/utils/network/timeout_http_client.dart';

void main() {
  test('retries a timed-out request once and preserves its contents', () async {
    final requests = <http.Request>[];
    final innerClient = MockClient((request) {
      requests.add(request);
      if (requests.length == 1) {
        return Completer<http.Response>().future;
      }
      return Future.value(http.Response('ok', 200));
    });
    final client = TimeoutHttpClient(
      const Duration(milliseconds: 10),
      retries: 1,
      retryDelay: Duration.zero,
      innerClient: innerClient,
    );
    addTearDown(client.close);

    final response = await client.post(
      Uri.parse('https://example.invalid/graphql'),
      headers: const {'content-type': 'application/json'},
      body: '{"query":"mutation Test { test }"}',
    );

    expect(response.statusCode, 200);
    expect(requests, hasLength(2));
    expect(requests[1].method, requests[0].method);
    expect(requests[1].url, requests[0].url);
    expect(requests[1].headers, requests[0].headers);
    expect(requests[1].body, requests[0].body);
  });

  test('does not retry when retries is zero', () async {
    var callCount = 0;
    final client = TimeoutHttpClient(
      const Duration(milliseconds: 10),
      innerClient: MockClient((request) {
        callCount += 1;
        return Completer<http.Response>().future;
      }),
    );
    addTearDown(client.close);

    await expectLater(
      client.get(Uri.parse('https://example.invalid/graphql')),
      throwsA(isA<TimeoutException>()),
    );
    expect(callCount, 1);
  });
}

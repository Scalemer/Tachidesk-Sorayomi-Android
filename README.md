<p align="center">
 <img width=200px height=200px src="assets/icons/launcher/sorayomi_icon.png" alt="Sorayomi logo"/>
</p>

<h1 align="center"> Sorayomi </h1>

<div align="center">

[![Platform](https://img.shields.io/badge/platform-Android-lightgrey)][release]
[![Discord](https://img.shields.io/discord/801021177333940224.svg?label=discord&labelColor=7289da&color=2c2f33&style=flat)](https://discord.gg/DDZdqZWaHA)

</div>

<div align="center">

[![GitHub Stars](https://img.shields.io/github/stars/Suwayomi/Tachidesk-Sorayomi)](https://github.com/Suwayomi/Tachidesk-Sorayomi)
[![GitHub License](https://img.shields.io/github/license/Suwayomi/Tachidesk-Sorayomi)](https://github.com/Suwayomi/Tachidesk-Sorayomi/blob/main/LICENSE)
[![Android](https://github.com/Scalemer/Tachidesk-Sorayomi-Android/actions/workflows/android.yml/badge.svg)](https://github.com/Scalemer/Tachidesk-Sorayomi-Android/actions/workflows/android.yml)
[![stable release](https://img.shields.io/github/release/Scalemer/Tachidesk-Sorayomi-Android.svg?maxAge=3600&label=download)](https://github.com/Scalemer/Tachidesk-Sorayomi-Android/releases)

</div>



<p align="center">
A free and open source manga reader based on <a href="https://flutter.dev/">Flutter</a> to read manga from a <a href="https://github.com/Suwayomi/Tachidesk-Server">Suwayomi-Server</a> instance.</br></br>
Sorayomi need to connect with an already hosted server.</br></br>
Sorayomi supports Linux, Windows, MacOS, Web, iOS and Android.
</p>

---

## Scalemer Android fork

This repository is an Android-focused personal fork of
[Suwayomi/Tachidesk-Sorayomi](https://github.com/Suwayomi/Tachidesk-Sorayomi).
It keeps the upstream last-page swipe-to-next-chapter behavior and adds the
chapter-loading fix recovered from the earlier iOS fork:

- If the first chapter-page response is empty, wait 1.5 seconds and retry once.
- Use a 30-second request timeout by default, with one timeout retry enabled.
- Build and test installable Android APKs with the dedicated Android workflow.

The exact audit of the earlier fork is recorded in [CUSTOM_CHANGES.md](CUSTOM_CHANGES.md).
The app still requires a running Suwayomi Server.

---

## Is this application usable? Should I test it?

Here is a list of current features for interaction with Sorayomi:

- Managing installed Extensions.
- Interaction with your library.
- Browsing installed sources.
- Viewing manga and chapters.
- Reading, downloading, and managing chapters.
- Viewing chapter updates

**Note:** Keep in mind that Sorayomi and Suwayomi-Server are alpha software, so it can have issues. See [Support and help](#support-and-help) if it happens.


### Supported Suwayomi versions

These are the versions of [Suwayomi-Server][suwayomi-server] that Sorayomi supports.

#### [Release build][release]

- [Suwayomi-Server][suwayomi-server] v0.6.6+


## Downloading and Running the app

### Android

Run the [Android workflow](https://github.com/Scalemer/Tachidesk-Sorayomi-Android/actions/workflows/android.yml)
and download its artifact. The `all.apk` build works on all supported Android
architectures; the ABI-specific APKs are smaller.

Without repository signing secrets, CI signs the APK with a temporary debug
key. Configure the four secrets documented below before distributing builds
that must upgrade one another. For official builds on other platforms, use the
[upstream releases](https://github.com/Suwayomi/Tachidesk-Sorayomi/releases).


## Post installation

  - Configure your server address in `Navigation bar > more screen > Server URL`.

## Building from source

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

You can install Flutter & Dart from [Official website](https://docs.flutter.dev/get-started/install)

  - Dart sdk
  - Flutter 3.32.5
  - Java 17 for Android builds

### Building

1.  Clone the repository:

```
  $ git clone https://github.com/Scalemer/Tachidesk-Sorayomi-Android.git
  $ cd Tachidesk-Sorayomi-Android/
```
2.  You can install all dependencies by running this command in terminal:

```
  $ flutter pub get
```

3. Generate sources and run the tests:

```
  $ flutter gen-l10n
  $ dart run build_runner build --delete-conflicting-outputs
  $ flutter test
```

4. Build an Android APK or start debugging:

```
  $ flutter build apk --release
  $ flutter run
```

For persistent release signing, add `android/key.properties` and a keystore as
described in Flutter's Android deployment guide. CI accepts the following
repository secrets: `PLAY_STORE_UPLOAD_KEY` (base64-encoded keystore),
`KEYSTORE_KEY_ALIAS`, `KEYSTORE_STORE_PASSWORD`, and `KEYSTORE_KEY_PASSWORD`.

- Pull-Request Suggestion
  - Install GitHooks after cloning the repo using `git config --local core.hooksPath .githooks`

## Support and help

-   Join Suwayomi's [discord server](https://discord.gg/DDZdqZWaHA) to hang out with the community and receive support and help.


## Built Using

- [Flutter](https://flutter.dev/) is an open source framework by Google for building beautiful, natively compiled, multi-platform applications from a single codebase.

- [Flutter Riverpod](https://pub.dev/packages/riverpod/) - A simple way to access state while robust and testable.

- [Riverpod Architecture](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/) - File architecture developed by [@bizz84](https://github.com/bizz84)

Find other dependencies in [pubspec.yaml](pubspec.yaml)

## Credit

- The `Suwayomi-server` project is developed by [@AriaMoradi](https://github.com/AriaMoradi) and contributors,

- The `Tachidesk-Sorayomi` project is developed by [@DattatreyaReddy](https://github.com/DattatreyaReddy) and contributors,

- CI-CD for `Tachidesk-Sorayomi` is developed by [@mahor1221](https://github.com/mahor1221) and contributors.

## Translation
Feel free to translate the project on [Weblate](https://hosted.weblate.org/projects/suwayomi/tachidesk-sorayomi/)

<details><summary>Translation Progress</summary>
<a href="https://hosted.weblate.org/engage/suwayomi/">
<img src="https://hosted.weblate.org/widgets/suwayomi/-/tachidesk-sorayomi/multi-auto.svg" alt="Translation status" />
</a>
</details>

## License

A link for [Tachidesk is provided here](https://github.com/Suwayomi/Tachidesk) and is licensed under `Mozilla Public License v2.0`.

You can obtain a copy of `Mozilla Public License v2.0` from https://mozilla.org/MPL/2.0/


    Copyright (C) Contributors to the Suwayomi project

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.


[release]: https://github.com/Scalemer/Tachidesk-Sorayomi-Android/releases
[suwayomi-server]: https://github.com/Suwayomi/Suwayomi-Server
[suwayomi-server-preview]: https://github.com/Suwayomi/Suwayomi-Server-preview/releases

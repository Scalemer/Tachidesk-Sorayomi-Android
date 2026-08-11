// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../constants/app_sizes.dart';
import '../constants/endpoints.dart';
import '../constants/enum.dart';
import '../features/settings/presentation/server/widget/client/server_port_tile/server_port_tile.dart';
import '../features/settings/presentation/server/widget/client/server_url_tile/server_url_tile.dart';
import '../features/settings/presentation/server/widget/credential_popup/credentials_popup.dart';
import '../global_providers/global_providers.dart';
import '../utils/extensions/custom_extensions.dart';
import '../utils/misc/app_utils.dart';
import 'custom_circular_progress_indicator.dart';

class ServerImage extends HookConsumerWidget {
  const ServerImage({
    super.key,
    required this.imageUrl,
    this.size,
    this.fit,
    this.appendApiToUrl = false,
    this.progressIndicatorBuilder,
    this.wrapper,
    this.showReloadButton = false,
    this.alignment = Alignment.center,
    this.onImageLoaded,
  });

  final String imageUrl;
  final Size? size;
  final BoxFit? fit;
  final bool appendApiToUrl;
  final Widget Function(BuildContext, String, DownloadProgress)?
      progressIndicatorBuilder;
  final Widget Function(Widget child)? wrapper;
  final bool showReloadButton;
  final Alignment alignment;
  final ValueChanged<Size>? onImageLoaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = useState(UniqueKey());
    // Providers
    final authType = ref.watch(authTypeKeyProvider);
    final basicToken = ref.watch(credentialsProvider);

    final baseApi = "${Endpoints.baseApi(
      baseUrl: ref.watch(serverUrlProvider),
      port: ref.watch(serverPortProvider),
      addPort: ref.watch(serverPortToggleProvider).ifNull(),
      appendApiToUrl: appendApiToUrl,
    )}"
        "$imageUrl";

    final Map<String, String>? httpHeaders =
        (authType == AuthType.basic && basicToken != null)
            ? ({"Authorization": basicToken})
            : null;

    final ImageRenderMethodForWeb renderMethod;
    if (authType == AuthType.basic && basicToken != null) {
      renderMethod = ImageRenderMethodForWeb.HttpGet;
    } else {
      renderMethod = ImageRenderMethodForWeb.HtmlImage;
    }

    finalProgressIndicatorBuilder(
            BuildContext context, String url, DownloadProgress progress) =>
        AppUtils.wrapOn(
          wrapper,
          progressIndicatorBuilder?.call(context, url, progress) ??
              const CenterSorayomiShimmerIndicator(),
        );

    Widget errorWidget(BuildContext context, String error, stackTrace) {
      if (showReloadButton) {
        return AppUtils.wrapOn(
          wrapper,
          Padding(
            padding: KEdgeInsets.a8.size,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.grey,
                  ),
                  const Gap(32),
                  TextButton(
                    onPressed: () {
                      key.value = (UniqueKey());
                    },
                    child: Text(context.l10n.reload),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return AppUtils.wrapOn(
          wrapper,
          const Icon(
            Icons.broken_image_rounded,
            color: Colors.grey,
          ),
        );
      }
    }

    return CachedNetworkImage(
      key: key.value,
      imageUrl: baseApi,
      height: size?.height,
      cacheManager: DefaultCacheManager(),
      httpHeaders: httpHeaders,
      width: size?.width,
      fit: fit ?? BoxFit.cover,
      alignment: alignment,
      imageRenderMethodForWeb: renderMethod,
      imageBuilder: onImageLoaded == null
          ? null
          : (context, imageProvider) => _SizeReportingImage(
                imageProvider: imageProvider,
                height: size?.height,
                width: size?.width,
                fit: fit ?? BoxFit.cover,
                alignment: alignment,
                onImageLoaded: onImageLoaded!,
              ),
      progressIndicatorBuilder: finalProgressIndicatorBuilder,
      errorWidget: errorWidget,
    );
  }
}

class _SizeReportingImage extends StatefulWidget {
  const _SizeReportingImage({
    required this.imageProvider,
    required this.fit,
    required this.alignment,
    required this.onImageLoaded,
    this.height,
    this.width,
  });

  final ImageProvider<Object> imageProvider;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Alignment alignment;
  final ValueChanged<Size> onImageLoaded;

  @override
  State<_SizeReportingImage> createState() => _SizeReportingImageState();
}

class _SizeReportingImageState extends State<_SizeReportingImage> {
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  Size? _reportedSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant _SizeReportingImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageProvider != widget.imageProvider) {
      _reportedSize = null;
      _resolveImage();
    }
  }

  void _resolveImage() {
    final imageStream = widget.imageProvider.resolve(
      createLocalImageConfiguration(
        context,
        size: widget.width != null && widget.height != null
            ? Size(widget.width!, widget.height!)
            : null,
      ),
    );
    if (_imageStream?.key == imageStream.key) return;

    _removeImageStreamListener();
    _imageStream = imageStream;
    _imageStreamListener = ImageStreamListener((imageInfo, _) {
      final imageSize = Size(
        imageInfo.image.width.toDouble(),
        imageInfo.image.height.toDouble(),
      );
      if (_reportedSize == imageSize) return;
      _reportedSize = imageSize;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onImageLoaded(imageSize);
      });
    });
    _imageStream!.addListener(_imageStreamListener!);
  }

  void _removeImageStreamListener() {
    final listener = _imageStreamListener;
    if (listener != null) _imageStream?.removeListener(listener);
    _imageStreamListener = null;
  }

  @override
  void dispose() {
    _removeImageStreamListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Image(
        image: widget.imageProvider,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        alignment: widget.alignment,
        gaplessPlayback: true,
      );
}

class ServerImageWithCpi extends StatelessWidget {
  const ServerImageWithCpi({
    super.key,
    required this.url,
    required this.outerSize,
    required this.innerSize,
    required this.isLoading,
  });
  final bool isLoading;
  final Size outerSize;
  final Size innerSize;
  final String url;
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox.fromSize(
        size: outerSize,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            ServerImage(
              imageUrl: url,
              size: innerSize,
              progressIndicatorBuilder: (context, url, progress) =>
                  const CenterSorayomiShimmerIndicator(),
            )
          ],
        ),
      );
    } else {
      return ServerImage(imageUrl: url, size: outerSize);
    }
  }
}

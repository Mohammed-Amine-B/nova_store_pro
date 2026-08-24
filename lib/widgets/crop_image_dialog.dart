import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../l10n/generated/app_localizations.dart';

const int _maxCropInputDimension = 1200;
const int _minCropInputDimension = 600;

class CropImageDialog extends StatefulWidget {
  final Uint8List imageBytes;
  const CropImageDialog({super.key, required this.imageBytes});

  @override
  State<CropImageDialog> createState() => _CropImageDialogState();
}

class _CropImageDialogState extends State<CropImageDialog> {
  final _controller = CropController();
  bool _cropping = false;
  String? _error;
  Uint8List? _normalizedBytes;

  @override
  void initState() {
    super.initState();
    _prepareImage();
  }

  /// Normalizes the source image to a consistent size range before it reaches
  /// the Crop widget, so tiny and huge source photos behave the same way in
  /// the crop viewport instead of showing at wildly different scales. The
  /// installed crop_your_image version has no fit/scale constructor param, so
  /// this narrows the input range from both ends instead: large images are
  /// downscaled to fit within 1200px, and images whose shorter side is under
  /// 600px are upscaled up to that minimum (both preserving aspect ratio).
  Future<void> _prepareImage() async {
    var result = widget.imageBytes;
    try {
      final decoded = img.decodeImage(widget.imageBytes);
      if (decoded != null) {
        img.Image? resized;
        if (decoded.width > _maxCropInputDimension || decoded.height > _maxCropInputDimension) {
          resized = img.copyResize(
            decoded,
            width: decoded.width >= decoded.height ? _maxCropInputDimension : null,
            height: decoded.height > decoded.width ? _maxCropInputDimension : null,
          );
        } else {
          final shorterSide = decoded.width < decoded.height ? decoded.width : decoded.height;
          if (shorterSide < _minCropInputDimension) {
            resized = img.copyResize(
              decoded,
              width: decoded.width <= decoded.height ? _minCropInputDimension : null,
              height: decoded.height < decoded.width ? _minCropInputDimension : null,
            );
          }
        }
        if (resized != null) {
          result = Uint8List.fromList(img.encodeJpg(resized, quality: 90));
        }
      }
    } catch (_) {
      result = widget.imageBytes;
    }
    if (!mounted) return;
    setState(() => _normalizedBytes = result);
  }

  void _onCropped(CropResult result) {
    final l10n = AppLocalizations.of(context)!;
    switch (result) {
      case CropSuccess(:final croppedImage):
        Navigator.of(context).pop(croppedImage);
      case CropFailure(:final cause):
        setState(() {
          _cropping = false;
          _error = l10n.couldNotCropImage(cause.toString());
        });
    }
  }

  void _crop() {
    setState(() {
      _cropping = true;
      _error = null;
    });
    _controller.crop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E7C7B),
        foregroundColor: Colors.white,
        title: Text(l10n.cropPhotoTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(
          children: [
            if (_error != null) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(12),
                child: Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _normalizedBytes == null
                      ? const Center(child: CircularProgressIndicator())
                      : Crop(
                          image: _normalizedBytes!,
                          controller: _controller,
                          aspectRatio: 1,
                          interactive: true,
                          baseColor: Colors.black,
                          radius: 12,
                          onCropped: _onCropped,
                        ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0E7C7B)),
                        onPressed: _cropping ? null : _crop,
                        child: Text(_cropping ? l10n.croppingEllipsis : l10n.cropSaveAction),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a full-screen square crop editor. Returns the cropped JPEG/PNG bytes,
/// or null if the user cancelled.
Future<Uint8List?> showCropImageDialog(BuildContext context, Uint8List imageBytes) {
  return Navigator.of(context).push<Uint8List>(
    MaterialPageRoute(
      builder: (context) => CropImageDialog(imageBytes: imageBytes),
      fullscreenDialog: true,
    ),
  );
}

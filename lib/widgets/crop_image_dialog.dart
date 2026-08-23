import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E7C7B),
        foregroundColor: Colors.white,
        title: Text(l10n.cropPhotoTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          if (_error != null)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
              padding: const EdgeInsets.all(12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Crop(
                  image: widget.imageBytes,
                  controller: _controller,
                  aspectRatio: 1,
                  interactive: true,
                  baseColor: Colors.black,
                  radius: 16,
                  onCropped: _onCropped,
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0E7C7B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
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

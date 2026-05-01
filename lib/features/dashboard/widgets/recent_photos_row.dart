import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import '../../../data/models/capture_entry.dart';

/// Displays up to 3 recent photo thumbnails in a row.
/// Tapping a thumbnail opens a full-screen image viewer.
class RecentPhotosRow extends StatelessWidget {
  final List<CaptureEntry> recentPhotos;

  const RecentPhotosRow({super.key, required this.recentPhotos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Only show photos whose files still exist on disk.
    final validPhotos = recentPhotos
        .where((e) =>
            e.imagePath != null && File(e.imagePath!).existsSync())
        .take(3)
        .toList();

    if (validPhotos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_library,
                size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n?.recentPhotos ?? 'Recent Photos',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (int i = 0; i < validPhotos.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _PhotoThumbnail(entry: validPhotos[i]),
              ),
            ],
            // Fill remaining slots with empty Expanded to keep equal sizing
            for (int i = validPhotos.length; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              const Expanded(child: SizedBox.shrink()),
            ],
          ],
        ),
      ],
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  final CaptureEntry entry;

  const _PhotoThumbnail({required this.entry});

  @override
  Widget build(BuildContext context) {
    final file = File(entry.imagePath!);

    return GestureDetector(
      onTap: () => _showFullScreen(context, file, entry.text),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            cacheWidth: 300,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              child: const Icon(Icons.broken_image, size: 24),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreen(BuildContext context, File file, String? caption) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: true,
        pageBuilder: (context, animation2, animation3) =>
            _FullScreenPhoto(file: file, caption: caption),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _FullScreenPhoto extends StatelessWidget {
  final File file;
  final String? caption;

  const _FullScreenPhoto({required this.file, this.caption});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(file, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              if (caption != null && caption!.isNotEmpty)
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: Text(
                    caption!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      shadows: [
                        Shadow(blurRadius: 8, color: Colors.black54),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PhotoResult {
  final String appPath;
  final bool savedToGallery;

  const PhotoResult({required this.appPath, required this.savedToGallery});
}

class PhotoService {
  static final PhotoService _instance = PhotoService._();
  factory PhotoService() => _instance;
  PhotoService._();

  final ImagePicker _picker = ImagePicker();

  static const _photoDir = 'hopeos_photos';

  Future<Directory> _getPhotoDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory(p.join(appDir.path, _photoDir));
    if (!photoDir.existsSync()) {
      await photoDir.create(recursive: true);
    }
    return photoDir;
  }

  Future<PhotoResult?> captureFromCamera() async {
    return _pickAndSave(ImageSource.camera);
  }

  Future<PhotoResult?> pickFromGallery() async {
    return _pickAndSave(ImageSource.gallery);
  }

  Future<PhotoResult?> _pickAndSave(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (picked == null) return null;

      final photoDir = await _getPhotoDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = p.extension(picked.path).isNotEmpty
          ? p.extension(picked.path)
          : '.jpg';
      final fileName = 'hopeos_$timestamp$extension';
      final savedFile = File(p.join(photoDir.path, fileName));

      await File(picked.path).copy(savedFile.path);

      bool savedToGallery = false;
      try {
        await Gal.putImage(savedFile.path, album: 'HopeOS');
        savedToGallery = true;
      } catch (e) {
        debugPrint('Failed to save to gallery: $e');
      }

      return PhotoResult(
        appPath: savedFile.path,
        savedToGallery: savedToGallery,
      );
    } catch (e) {
      debugPrint('Photo capture failed: $e');
      return null;
    }
  }

  Future<bool> requestGalleryPermission() async {
    try {
      return await Gal.hasAccess(toAlbum: true);
    } catch (e) {
      debugPrint('Gallery permission check failed: $e');
      return false;
    }
  }

  Future<bool> requestGalleryAccess() async {
    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (hasAccess) return true;
      await Gal.requestAccess(toAlbum: true);
      return await Gal.hasAccess(toAlbum: true);
    } catch (e) {
      debugPrint('Gallery access request failed: $e');
      return false;
    }
  }
}

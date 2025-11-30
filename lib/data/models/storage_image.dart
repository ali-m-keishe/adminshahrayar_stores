import 'package:meta/meta.dart';

/// Represents a single object stored inside a Supabase storage bucket.
@immutable
class StorageImage {
  final String name;
  final String path;
  final String publicUrl;
  final DateTime? createdAt;
  final int? sizeInBytes;

  const StorageImage({
    required this.name,
    required this.path,
    required this.publicUrl,
    this.createdAt,
    this.sizeInBytes,
  });
}

/// Simple pagination response when listing storage objects.
@immutable
class StorageImagesPage {
  final List<StorageImage> images;
  final bool hasMore;
  final int totalCount; // Total number of images available

  const StorageImagesPage({
    required this.images,
    required this.hasMore,
    this.totalCount = 0,
  });
}

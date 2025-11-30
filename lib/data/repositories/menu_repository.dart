// lib/data/repositories/menu_repository.dart

import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../models/addon.dart';
import '../models/item_size.dart';
import '../models/storage_image.dart';
import 'package:path/path.dart' as path;

class MenuRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Use a single known bucket ('images') to match your Supabase dashboard.
  // Store existing files at bucket root, and new uploads under 'uploads/'.
  static const String _bucketName = 'images';
  static const List<String> _folderPreferences = [
    'uploads',
    '',
  ];
  _StorageLocation? _cachedStorageLocation;

  Future<_StorageLocation> _resolveStorageLocation() async {
    if (_cachedStorageLocation != null) return _cachedStorageLocation!;

    for (final folder in _folderPreferences) {
      try {
        await _supabase.storage.from(_bucketName).list(path: folder);
        _cachedStorageLocation =
            _StorageLocation(bucket: _bucketName, pathPrefix: folder);
        return _cachedStorageLocation!;
      } catch (_) {
        continue;
      }
    }

    // Fallback to bucket root if folder probing fails
    _cachedStorageLocation =
        const _StorageLocation(bucket: _bucketName, pathPrefix: '');
    return _cachedStorageLocation!;
  }

  String _composeStoragePath(_StorageLocation location, String fileName) {
    final sanitized = fileName
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '');

    // Always keep new uploads under an 'uploads/' folder inside the bucket.
    // If pathPrefix is empty, this becomes 'uploads/<file>'; otherwise
    // '<pathPrefix>/uploads/<file>'.
    final basePath = location.pathPrefix.isEmpty
        ? 'uploads'
        : '${location.pathPrefix}/uploads';
    return '$basePath/$sanitized';
  }

  Future<String> uploadImageBytes(
    Uint8List bytes, {
    required String originalFileName,
  }) async {
    final extension = path.extension(originalFileName);
    final baseName = path.basenameWithoutExtension(originalFileName);
    final sanitizedName = baseName
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '');
    final uniqueFileName =
        '${DateTime.now().millisecondsSinceEpoch}_$sanitizedName$extension';
    final fileName = uniqueFileName.isNotEmpty
        ? uniqueFileName
        : '${DateTime.now().millisecondsSinceEpoch}_image.jpg';

    // Always upload to 'uploads' folder (not nested)
    final storagePath = 'uploads/$fileName';

    await _supabase.storage.from(_bucketName).uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ),
        );

    return _supabase.storage.from(_bucketName).getPublicUrl(storagePath);
  }

  // Add this method to fetch categories (folders)
  Future<List<String>> fetchStorageCategories() async {
    try {
      // Your categories are inside uploads/uploads/
      const String basePath = 'uploads/uploads';

      print('🔍 Fetching categories from path: $basePath');

      // List all items in the uploads/uploads folder
      final objects =
          await _supabase.storage.from(_bucketName).list(path: basePath);

      // Filter to get only folders (your category folders)
      final folders = <String>[];

      for (final item in objects) {
        // In Supabase, folders typically don't have a file extension
        // and don't have mimetype metadata
        if (!item.name.contains('.') && // No file extension
            item.metadata?['mimetype'] == null) {
          // No mimetype means it's a folder
          folders.add(item.name);
        }
      }

      // Sort alphabetically
      folders.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      print('✅ Found ${folders.length} categories: $folders');
      return folders;
    } catch (e) {
      print('❌ Error fetching storage categories: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Create a new storage category (folder)
  Future<void> createStorageCategory(String categoryName) async {
    try {
      // Sanitize category name
      final sanitizedName = categoryName
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '');

      if (sanitizedName.isEmpty) {
        throw Exception('Invalid category name');
      }

      // Categories are stored at uploads/uploads/[category_name]
      final categoryPath = 'uploads/uploads/$sanitizedName';

      print('📁 Creating category folder: $categoryPath');

      // In Supabase Storage, folders are created implicitly when you upload a file
      // We'll create a placeholder .keep file to establish the folder
      final placeholderPath = '$categoryPath/.keep';
      final placeholderContent = Uint8List.fromList('category'.codeUnits);

      await _supabase.storage.from(_bucketName).uploadBinary(
            placeholderPath,
            placeholderContent,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      print('✅ Category created successfully: $sanitizedName');
    } catch (e) {
      print('❌ Error creating storage category: $e');
      rethrow;
    }
  }

  // Add this method to MenuRepository class
  Future<bool> deleteImageFromStorage({required String imagePath}) async {
    try {
      print('🗑️ Deleting image from path: $imagePath');

      // Remove the image from storage
      await _supabase.storage.from(_bucketName).remove([imagePath]);

      print('✅ Image deleted successfully from storage');
      return true;
    } catch (e) {
      print('❌ Error deleting image from storage: $e');
      return false;
    }
  }

  // Delete a storage category (folder and all its contents)
  Future<void> deleteStorageCategory(String categoryName) async {
    try {
      // Sanitize category name
      final sanitizedName = categoryName
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '');

      if (sanitizedName.isEmpty) {
        throw Exception('Invalid category name');
      }

      final categoryPath = 'uploads/uploads/$sanitizedName';

      print('🗑️ Deleting category: $categoryPath');

      // List all files in the category folder
      final objects =
          await _supabase.storage.from(_bucketName).list(path: categoryPath);

      // Delete all files in the category
      final filesToDelete = <String>[];
      for (final item in objects) {
        if (item.name.isNotEmpty) {
          filesToDelete.add('$categoryPath/${item.name}');
        }
      }

      // Delete all files
      if (filesToDelete.isNotEmpty) {
        await _supabase.storage.from(_bucketName).remove(filesToDelete);
      }

      // Also try to delete the .keep file if it exists
      try {
        await _supabase.storage
            .from(_bucketName)
            .remove(['$categoryPath/.keep']);
      } catch (_) {
        // .keep file might not exist, that's okay
      }

      print('✅ Category deleted successfully: $sanitizedName');
    } catch (e) {
      print('❌ Error deleting storage category: $e');
      rethrow;
    }
  }

// Updated method to fetch images from a specific category
  Future<StorageImagesPage> fetchCategoryImages({
    required String category,
    required int limit,
    required int offset,
  }) async {
    try {
      // Build the full path: uploads/uploads/[category name]
      final categoryPath = 'uploads/uploads/$category';

      print('🔍 Fetching images from path: $categoryPath');

      // List all items in the category folder
      final objects =
          await _supabase.storage.from(_bucketName).list(path: categoryPath);

      // Filter to only include image files
      final imageFiles = objects.where((file) {
        if (file.name.isEmpty) return false;

        final fileName = file.name.toLowerCase();
        // Check for image extensions
        final isImage = fileName.endsWith('.jpg') ||
            fileName.endsWith('.jpeg') ||
            fileName.endsWith('.png') ||
            fileName.endsWith('.gif') ||
            fileName.endsWith('.webp') ||
            fileName.endsWith('.bmp');

        return isImage;
      }).toList();

      print('✅ Found ${imageFiles.length} images in $category');

      // Sort by name or creation date
      imageFiles.sort((a, b) => a.name.compareTo(b.name));

      // Apply pagination
      final totalImages = imageFiles.length;
      final pagedFiles = imageFiles.skip(offset).take(limit).toList();

      // Convert to StorageImage objects
      final images = <StorageImage>[];
      for (final file in pagedFiles) {
        try {
          // Build the full path for this image
          final relativePath = '$categoryPath/${file.name}';

          DateTime? createdAt;
          try {
            if (file.createdAt != null) {
              createdAt = file.createdAt is String
                  ? DateTime.tryParse(file.createdAt as String)
                  : file.createdAt as DateTime?;
            }
          } catch (_) {
            createdAt = null;
          }

          final size = file.metadata?['size'];

          images.add(StorageImage(
            name: file.name,
            path: relativePath,
            publicUrl:
                _supabase.storage.from(_bucketName).getPublicUrl(relativePath),
            createdAt: createdAt,
            sizeInBytes: size is int ? size : null,
          ));
        } catch (e) {
          print('⚠️ Error processing file ${file.name}: $e');
          continue;
        }
      }

      print(
          '✅ Returning ${images.length} images for $category (total: $totalImages)');

      return StorageImagesPage(
        images: images,
        hasMore: offset + pagedFiles.length < totalImages,
        totalCount: totalImages,
      );
    } catch (e, stack) {
      print('❌ Error fetching images from $category: $e');
      print('Stack trace: $stack');
      return StorageImagesPage(images: [], hasMore: false, totalCount: 0);
    }
  }

// Updated upload method to support category selection
  Future<String> uploadImageToCategory({
    required Uint8List bytes,
    required String originalFileName,
    required String category,
  }) async {
    try {
      print('📤 Uploading image to category: $category');

      final extension = path.extension(originalFileName).toLowerCase();
      final baseName = path.basenameWithoutExtension(originalFileName);

      // Sanitize filename
      final sanitizedName = baseName
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '');

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_${sanitizedName}${extension}';
      final fileName =
          uniqueFileName.isNotEmpty ? uniqueFileName : '${timestamp}_image.jpg';

      // Upload to: uploads/uploads/[category]/[filename]
      final storagePath = 'uploads/uploads/$category/$fileName';

      print('📁 Uploading to path: $storagePath');

      await _supabase.storage.from(_bucketName).uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final publicUrl =
          _supabase.storage.from(_bucketName).getPublicUrl(storagePath);
      print('✅ Upload successful! URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      rethrow;
    }
  }

  Future<StorageImagesPage> fetchAllStorageImages({
    required int limit,
    required int offset,
  }) async {
    try {
      // First get all categories
      final categories = await fetchStorageCategories();
      final allImages = <StorageImage>[];

      // Fetch images from each category
      for (final category in categories) {
        final categoryImages = await fetchCategoryImages(
          category: category,
          limit: 1000, // Get all images from each category
          offset: 0,
        );
        allImages.addAll(categoryImages.images);
      }

      // Sort all images by date (newest first)
      allImages.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      // Apply pagination to the combined list
      final pagedImages = allImages.skip(offset).take(limit).toList();

      return StorageImagesPage(
        images: pagedImages,
        hasMore: offset + pagedImages.length < allImages.length,
        totalCount: allImages.length,
      );
    } catch (e) {
      print('❌ Error fetching all images: $e');
      return StorageImagesPage(images: [], hasMore: false, totalCount: 0);
    }
  }

  /// 🔹 Fetch all categories
  Future<List<Category>> getAllCategories() async {
    try {
      print('Fetching all categories from Supabase...');
      final response = await _supabase
          .from('categories')
          .select('*')
          .order('created_at', ascending: false);

      print('✅ Categories fetched: ${response.length}');

      return (response as List)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      print('❌ Error fetching categories: $e');
      print(stack);
      return [];
    }
  }

  /// 🔹 Fetch all addons
  Future<List<Addon>> getAllAddons() async {
    try {
      print('Fetching all addons from Supabase...');
      final response = await _supabase
          .from('addons')
          .select('*')
          .order('created_at', ascending: false);

      print('✅ Addons fetched: ${response.length}');

      return (response as List)
          .map((json) => Addon.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      print('❌ Error fetching addons: $e');
      print(stack);
      return [];
    }
  }

  /// 🔹 Add a new addon
  Future<void> addAddon(Addon addon) async {
    try {
      print('🟢 Adding new addon: ${addon.name}');

      final data = {
        'name': addon.name,
        'price': addon.price,
        'created_at': addon.createdAt.toIso8601String(),
        // don't include 'id' here - it's auto-generated
      };

      await _supabase.from('addons').insert(data);
      print('✅ Addon added successfully!');
    } catch (e, stack) {
      print('❌ Error adding addon: $e');
      print(stack);
      rethrow;
    }
  }

  /// 🔹 Delete addon
  Future<void> deleteAddon(int id) async {
    try {
      print('🗑️ Deleting addon ID: $id');
      await _supabase.from('addons').delete().eq('id', id);
      print('✅ Addon deleted successfully!');
    } catch (e, stack) {
      print('❌ Error deleting addon: $e');
      print(stack);
      rethrow;
    }
  }

  // 🔹 Add a new category
  Future<void> addCategory(Category category) async {
    try {
      print('🟢 Adding new category: ${category.name}');

      final data = {
        'name': category.name,
        'image': category.image,
        'created_at': category.createdAt.toIso8601String(),
        // don't include 'id' here
      };

      await _supabase.from('categories').insert(data);
      print('✅ Category added successfully!');
    } catch (e, stack) {
      print('❌ Error adding category: $e');
      print(stack);
      rethrow;
    }
  }

// 🔹 Update existing category
  Future<void> updateCategory(Category category) async {
    try {
      print('✏️ Updating category ID: ${category.id}');
      await _supabase
          .from('categories')
          .update(category.toJson())
          .eq('id', category.id);
      print('✅ Category updated successfully!');
    } catch (e, stack) {
      print('❌ Error updating category: $e');
      print(stack);
      rethrow;
    }
  }

// 🔹 Delete category (optional)
  Future<void> deleteCategory(int id) async {
    try {
      print('🗑️ Deleting category ID: $id');
      await _supabase.from('categories').delete().eq('id', id);
      print('✅ Category deleted successfully!');
    } catch (e, stack) {
      print('❌ Error deleting category: $e');
      print(stack);
      rethrow;
    }
  }

  /// 🔹 Fetch all menu items (with category + optional addons & sizes)
  Future<List<MenuItem>> getAllMenuItems() async {
    try {
      final response = await _supabase.from('items').select('''
      *,
      category:category_id (id, name, image, created_at),
      item_addons (
        addon:addon_id (*)
      ),
      item_sizes (*)
    ''').order('created_at', ascending: false);

      final items = (response as List).map((json) {
        final map = Map<String, dynamic>.from(json);

        // Flatten item_addons → addons
        if (map['item_addons'] != null) {
          map['addons'] = (map['item_addons'] as List)
              .map((e) => e['addon'])
              .where((a) => a != null)
              .toList();
        }

        // Flatten item_sizes → sizes (all sizes)
        if (map['item_sizes'] != null) {
          map['sizes'] = (map['item_sizes'] as List).toList();
        }

        if (map['category'] != null) {
          map['category_name'] = map['category']['name'];
        }

        return MenuItem.fromJson(map);
      }).toList();

      return items;
    } catch (e, stack) {
      print('❌ Error fetching menu items: $e');
      print(stack);
      return [];
    }
  }

  /// 🔹 Fetch paginated menu items with optional category filter
  Future<Map<String, dynamic>> getPaginatedMenuItems({
    required int limit,
    required int offset,
    int? categoryId,
  }) async {
    try {
      print(
          '🔍 Fetching paginated items: limit=$limit, offset=$offset, categoryId=$categoryId');

      // Build queries with proper filter chain
      dynamic countQuery;
      dynamic itemQuery;

      if (categoryId != null) {
        // With category filter
        countQuery =
            _supabase.from('items').select('id').eq('category_id', categoryId);

        itemQuery = _supabase
            .from('items')
            .select('''
              *,
              category:category_id (id, name, image, created_at),
              item_addons (
                addon:addon_id (*)
              ),
              item_sizes (*)
            ''')
            .eq('category_id', categoryId)
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
      } else {
        // Without category filter
        countQuery = _supabase.from('items').select('id');

        itemQuery = _supabase
            .from('items')
            .select('''
              *,
              category:category_id (id, name, image, created_at),
              item_addons (
                addon:addon_id (*)
              ),
              item_sizes (*)
            ''')
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
      }

      // Get total count
      final countResult = await countQuery;
      final totalCount = (countResult as List).length;

      // Execute item query
      final itemsResponse = await itemQuery;

      // Parse items
      final items = (itemsResponse as List).map((json) {
        final map = Map<String, dynamic>.from(json);

        // Flatten item_addons → addons
        if (map['item_addons'] != null) {
          map['addons'] = (map['item_addons'] as List)
              .map((e) => e['addon'])
              .where((a) => a != null)
              .toList();
        }

        // Flatten item_sizes → sizes (all sizes)
        if (map['item_sizes'] != null) {
          map['sizes'] = (map['item_sizes'] as List).toList();
        }

        if (map['category'] != null) {
          map['category_name'] = map['category']['name'];
        }

        return MenuItem.fromJson(map);
      }).toList();

      print('✅ Fetched ${items.length} items (total: $totalCount)');

      return {
        'items': items,
        'totalCount': totalCount,
      };
    } catch (e, stack) {
      print('❌ Error fetching paginated menu items: $e');
      print(stack);
      return {
        'items': <MenuItem>[],
        'totalCount': 0,
      };
    }
  }

  Future<StorageImagesPage> fetchStorageImages({
    required int limit,
    required int offset,
  }) async {
    try {
      List<StorageImage> allImages = [];

      // Fetch images from both the root and the 'uploads' folder
      // This handles your duplicate folder situation
      final List<String> pathsToCheck = ['', 'uploads'];

      for (final path in pathsToCheck) {
        try {
          final objects =
              await _supabase.storage.from(_bucketName).list(path: path);

          // Filter to only include image files (not folders)
          final imageFiles = objects.where((file) {
            final fileName = file.name.toLowerCase();
            return fileName.endsWith('.jpg') ||
                fileName.endsWith('.jpeg') ||
                fileName.endsWith('.png') ||
                fileName.endsWith('.gif') ||
                fileName.endsWith('.webp');
          }).toList();

          // Convert to StorageImage objects
          for (final file in imageFiles) {
            final relativePath =
                path.isEmpty ? file.name : '$path/${file.name}';

            DateTime? createdAt;
            try {
              createdAt = file.createdAt is String
                  ? DateTime.tryParse(file.createdAt as String)
                  : file.createdAt as DateTime?;
            } catch (_) {
              createdAt = null;
            }

            final size = file.metadata?['size'];

            allImages.add(StorageImage(
              name: file.name,
              path: relativePath,
              publicUrl: _supabase.storage
                  .from(_bucketName)
                  .getPublicUrl(relativePath),
              createdAt: createdAt,
              sizeInBytes: size is int ? size : null,
            ));
          }

          // Also check for nested uploads/uploads situation
          if (path == 'uploads') {
            try {
              final nestedObjects = await _supabase.storage
                  .from(_bucketName)
                  .list(path: 'uploads/uploads');

              final nestedImages = nestedObjects.where((file) {
                final fileName = file.name.toLowerCase();
                return fileName.endsWith('.jpg') ||
                    fileName.endsWith('.jpeg') ||
                    fileName.endsWith('.png') ||
                    fileName.endsWith('.gif') ||
                    fileName.endsWith('.webp');
              }).toList();

              for (final file in nestedImages) {
                final relativePath = 'uploads/uploads/${file.name}';

                DateTime? createdAt;
                try {
                  createdAt = file.createdAt is String
                      ? DateTime.tryParse(file.createdAt as String)
                      : file.createdAt as DateTime?;
                } catch (_) {
                  createdAt = null;
                }

                final size = file.metadata?['size'];

                allImages.add(StorageImage(
                  name: file.name,
                  path: relativePath,
                  publicUrl: _supabase.storage
                      .from(_bucketName)
                      .getPublicUrl(relativePath),
                  createdAt: createdAt,
                  sizeInBytes: size is int ? size : null,
                ));
              }
            } catch (_) {
              // Nested uploads/uploads doesn't exist, that's fine
            }
          }
        } catch (e) {
          print('Error fetching from path "$path": $e');
          continue;
        }
      }

      // Sort by creation date (newest first)
      allImages.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      // Apply pagination
      final pagedImages = allImages.skip(offset).take(limit).toList();

      return StorageImagesPage(
        images: pagedImages,
        hasMore: offset + pagedImages.length < allImages.length,
        totalCount: allImages.length,
      );
    } catch (e, stack) {
      print('❌ Error fetching storage images: $e');
      print(stack);
      rethrow;
    }
  }

  /// 🔹 Add a new menu item (with optional addons and sizes)
  Future<void> addMenuItem({
    required String name,
    required String description,
    required double price,
    required int categoryId,
    String? imageUrl,
    List<Addon>? addons,
    List<ItemSize>? sizes,
  }) async {
    try {
      print('🟢 Adding new menu item: $name');

      final String finalImageUrl = imageUrl?.trim() ?? '';

      // 1️⃣ Insert the main menu item
      final response = await _supabase.from('items').insert({
        'name': name,
        'price': price,
        'description': description,
        'category_id': categoryId,
        'image': finalImageUrl,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      final newItem = (response as List).first as Map<String, dynamic>;
      final newItemId = newItem['id'] as int;

      // 2️⃣ Link addons (if any selected) - CORRECTLY inserts into junction table
      if (addons != null && addons.isNotEmpty) {
        final addonData = addons
            .map((a) => {
                  'item_id': newItemId,
                  'addon_id': a.id,
                  'created_at': DateTime.now().toIso8601String(),
                })
            .toList();

        await _supabase.from('item_addons').insert(addonData);
        print('✅ Linked ${addons.length} addons to item $newItemId');
      }

      // 3️⃣ Add sizes (if any)
      if (sizes != null && sizes.isNotEmpty) {
        final sizeData = sizes
            .map((s) => {
                  'item_id': newItemId,
                  'size_name': s.sizeName,
                  'additional_price': s.additionalPrice,
                  'created_at': DateTime.now().toIso8601String(),
                })
            .toList();

        await _supabase.from('item_sizes').insert(sizeData);
        print('✅ Added ${sizes.length} sizes to item $newItemId');
      }

      print('✅ Menu item added successfully!');
    } catch (e, stack) {
      print('❌ Error adding menu item: $e');
      print(stack);
      rethrow;
    }
  }

  /// 🔹 Delete a menu item by ID
  Future<void> deleteMenuItem(int id) async {
    try {
      print('🗑️ Deleting menu item with ID: $id');
      await _supabase.from('items').delete().eq('id', id);
      print('✅ Menu item deleted successfully!');
    } catch (e, stack) {
      print('❌ Error deleting menu item: $e');
      print(stack);
      rethrow;
    }
  }

  /// 🔹 Update a menu item by ID (with addons and sizes)
  Future<void> updateMenuItem({
    required int itemId,
    required String name,
    required String description,
    required double price,
    required int categoryId,
    String? existingImageUrl,
    String? newImageUrl,
    List<Addon>? addons,
    List<ItemSize>? sizes,
  }) async {
    try {
      print('✏️ Updating menu item with ID: $itemId');

      String finalImageUrl = (existingImageUrl ?? '').trim();
      if (newImageUrl != null && newImageUrl.isNotEmpty) {
        finalImageUrl = newImageUrl.trim();
      }

      // 1️⃣ Update the main item fields
      await _supabase.from('items').update({
        'name': name,
        'price': price,
        'description': description.isEmpty ? null : description,
        'category_id': categoryId,
        'image': finalImageUrl,
      }).eq('id', itemId);

      // 2️⃣ Update addons: Delete old ones and insert new ones
      await _supabase.from('item_addons').delete().eq('item_id', itemId);

      if (addons != null && addons.isNotEmpty) {
        final addonData = addons
            .map((a) => {
                  'item_id': itemId,
                  'addon_id': a.id,
                  'created_at': DateTime.now().toIso8601String(),
                })
            .toList();
        await _supabase.from('item_addons').insert(addonData);
        print('✅ Updated ${addons.length} addons for item $itemId');
      }

      // 3️⃣ Update sizes: Delete old ones and insert new ones
      await _supabase.from('item_sizes').delete().eq('item_id', itemId);

      if (sizes != null && sizes.isNotEmpty) {
        final sizeData = sizes
            .map((s) => {
                  'item_id': itemId,
                  'size_name': s.sizeName,
                  'additional_price': s.additionalPrice,
                  'created_at': DateTime.now().toIso8601String(),
                })
            .toList();
        await _supabase.from('item_sizes').insert(sizeData);
        print('✅ Updated ${sizes.length} sizes for item $itemId');
      }

      print('✅ Menu item updated successfully!');
    } catch (e, stack) {
      print('❌ Error updating menu item: $e');
      print(stack);
      rethrow;
    }
  }
}

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository();
});

class _StorageLocation {
  final String bucket;
  final String pathPrefix;

  const _StorageLocation({required this.bucket, required this.pathPrefix});
}

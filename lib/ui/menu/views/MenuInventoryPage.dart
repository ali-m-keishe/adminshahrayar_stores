import 'package:adminshahrayar_stores/data/models/category.dart';
import 'package:adminshahrayar_stores/data/models/menu_item.dart';
import 'package:adminshahrayar_stores/data/models/addon.dart';
import 'package:adminshahrayar_stores/data/models/item_size.dart';
import 'package:adminshahrayar_stores/data/models/storage_image.dart';
import 'package:adminshahrayar_stores/main_screen.dart';
import 'package:adminshahrayar_stores/ui/menu/viewmodels/menu_viemodel.dart';
import 'package:adminshahrayar_stores/ui/menu/views/archived_items_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  String? selectedCategory;
  int? selectedCategoryId;
  int currentPage = 0;
  final int itemsPerPage = 6;

  int? sortColumnIndex;
  bool isAscending = true;
  int? _lastSelectedIndex;

  @override
  void initState() {
    super.initState();
    // Load initial paginated data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPage();
    });
  }

  void _loadPage() {
    final viewModel = ref.read(menuViewModelProvider.notifier);
    final offset = currentPage * itemsPerPage;
    viewModel.loadPaginatedMenuItems(
      limit: itemsPerPage,
      offset: offset,
      categoryId: selectedCategoryId,
    );
  }

  void _onCategoryChanged(String? categoryName, int? categoryId) {
    setState(() {
      selectedCategory = categoryName;
      selectedCategoryId = categoryId;
      currentPage = 0; // Reset to first page
    });
    _loadPage();
  }

  void _onPageChanged(int newPage) {
    setState(() {
      currentPage = newPage;
    });
    _loadPage();
  }

  void _sort<T>(
    Comparable<T> Function(MenuItem item) getField,
    int columnIndex,
    bool ascending,
    List<MenuItem> items,
  ) {
    // Create a copy to avoid mutating the original list
    final sortedItems = List<MenuItem>.from(items);
    sortedItems.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;
    });
    // Note: The sorted list is not persisted - sorting is handled server-side
    // This is just for UI feedback on which column is sorted
  }

  // ✅ Show details of a menu item
  void _showMenuItemDetails(BuildContext context, MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          item.name,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.image.isNotEmpty)
                Center(
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                      color: Colors.grey.shade800,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: Colors.grey.shade900,
                        child: Image.network(
                          item.image,
                          height: 300,
                          width: 300,
                          fit: BoxFit.contain, // Fit entire image without cropping
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 48),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              if (item.description.isNotEmpty)
                Text('Description: ${item.description}',
                    style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Text('Price: \$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Category ID: ${item.categoryId}',
                  style: const TextStyle(color: Colors.white70)),
              if (item.addons != null && item.addons!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(color: Colors.white24),
                const Text('Addons:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                ...item.addons!.map((a) => Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Text('- ${a.name} (\$${a.price})',
                          style: const TextStyle(color: Colors.white70)),
                    )),
              ],
              if (item.sizes != null && item.sizes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(color: Colors.white24),
                const Text('Sizes:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                ...item.sizes!.map((s) => Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Text(
                          '- ${s.sizeName} (+\$${s.additionalPrice.toStringAsFixed(2)})',
                          style: const TextStyle(color: Colors.white70)),
                    )),
              ]
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  // ✅ Category dialog
  void _showAddEditCategoryDialog(BuildContext context, {Category? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final imageController = TextEditingController(text: category?.image ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(isEditing ? 'Edit Category' : 'Add Category',
              style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Colors.white70))),
              const SizedBox(height: 12),
              TextField(
                  controller: imageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Image URL',
                      labelStyle: TextStyle(color: Colors.white70))),
            ],
          ),
          actions: [
            if (isEditing)
              TextButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                            backgroundColor: Colors.grey.shade900,
                            title: const Text('Confirm Delete',
                                style: TextStyle(color: Colors.white)),
                            content: const Text(
                                'Are you sure you want to delete this category?',
                                style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel')),
                              ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'))
                            ],
                          ));
                  if (confirm == true) {
                    final viewModel = ref.read(menuViewModelProvider.notifier);
                    await viewModel.deleteCategory(category.id);
                    await viewModel.refreshMenu();
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                label: const Text('Delete',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.redAccent))),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final newCategory = Category(
                    id: isEditing ? category.id : 0,
                    name: name,
                    image: imageController.text.trim(),
                    createdAt: isEditing ? category.createdAt : DateTime.now());
                final viewModel = ref.read(menuViewModelProvider.notifier);
                if (isEditing) {
                  await viewModel.editCategory(newCategory);
                } else {
                  await viewModel.addCategory(newCategory);
                }
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  // ✅ Addon dialog (Add/Delete only, no editing)
  void _showAddAddonDialog(BuildContext context) async {
    final menuState = ref.read(menuViewModelProvider);

    await menuState.whenOrNull(
      data: (state) async {
        final addons = state.addons;

        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: Colors.grey.shade900,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text('Manage Addons',
                style: TextStyle(color: Colors.white)),
            content: SizedBox(
              width: 400,
              height: 400,
              child: Column(
                children: [
                  // Add new addon section
                  Card(
                    color: Colors.grey.shade800,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Add New Addon',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              _showCreateAddonDialog(context);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Create Addon'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  // Existing addons list
                  const Text('Existing Addons',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: addons.isEmpty
                        ? const Center(
                            child: Text('No addons available',
                                style: TextStyle(color: Colors.white70)))
                        : ListView.builder(
                            itemCount: addons.length,
                            itemBuilder: (context, index) {
                              final addon = addons[index];
                              return Card(
                                color: Colors.grey.shade800,
                                child: ListTile(
                                  title: Text(addon.name,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  subtitle: Text(
                                      '\$${addon.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  trailing: IconButton(
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                          context: dialogContext,
                                          builder: (_) => AlertDialog(
                                                backgroundColor:
                                                    Colors.grey.shade900,
                                                title: const Text(
                                                    'Confirm Delete',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                content: Text(
                                                    'Are you sure you want to delete "${addon.name}"?',
                                                    style: const TextStyle(
                                                        color: Colors.white70)),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child:
                                                          const Text('Cancel')),
                                                  ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Colors
                                                                      .redAccent),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      child:
                                                          const Text('Delete'))
                                                ],
                                              ));
                                      if (confirm == true) {
                                        final viewModel = ref.read(
                                            menuViewModelProvider.notifier);
                                        await viewModel.deleteAddon(addon.id);
                                        Navigator.pop(dialogContext);
                                      }
                                    },
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child:
                    const Text('Close', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Create new addon dialog
  void _showCreateAddonDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Create New Addon',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Addon Name',
                    labelStyle: TextStyle(color: Colors.white70))),
            const SizedBox(height: 12),
            TextField(
                controller: priceController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: Colors.white70))),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.redAccent))),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0;

              if (name.isEmpty || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid name and price'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final newAddon = Addon(
                  id: 0, name: name, price: price, createdAt: DateTime.now());

              final viewModel = ref.read(menuViewModelProvider.notifier);
              await viewModel.addAddon(newAddon);
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // ✅ MODIFIED: Add/Edit Menu Item dialog with Supabase image picker
  void _showAddEditMenuItemDialog(BuildContext context, {MenuItem? item}) {
    final isEditing = item != null;
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final priceController =
        TextEditingController(text: item?.price.toString() ?? '');
    
    // Get categories from the menu state
    final menuState = ref.read(menuViewModelProvider);
    final categories = menuState.value?.categories ?? [];

    final List<Addon> addons = List.from(item?.addons ?? []);
    final List<ItemSize> sizes = List.from(item?.sizes ?? []);

    final String? originalImageUrl = (item?.image != null && 
            item!.image.trim().isNotEmpty)
        ? item.image
        : null;
    String? workingImageUrl = originalImageUrl;
    
    // Track isActive status (default to true for new items)
    bool workingIsActive = item?.isActive ?? true;

    // Find the initial selected category by ID (for editing) or set to first category (for adding)
    Category? initialSelectedCategory;
    if (isEditing) {
      // isEditing is true means item is not null - Dart flow analysis understands this
      final editingItem = item;
      initialSelectedCategory = categories.firstWhere(
        (cat) => cat.id == editingItem.categoryId,
        orElse: () => categories.isNotEmpty ? categories.first : Category(
          id: 0,
          name: '',
          image: '',
          createdAt: DateTime.now(),
        ),
      );
    } else if (categories.isNotEmpty) {
      initialSelectedCategory = categories.first;
    }
    
    // Use a mutable variable that can be updated in the StatefulBuilder
    Category? selectedCategory = initialSelectedCategory;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          backgroundColor: Colors.grey.shade900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(isEditing ? 'Edit Item' : 'Add Item',
              style: const TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Colors.white70))),
                TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Colors.white70))),
                TextField(
                    controller: priceController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Price',
                        labelStyle: TextStyle(color: Colors.white70))),
                // In _showAddEditMenuItemDialog method, replace the image section with this:

                const SizedBox(height: 16),
                const Text('Image',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

// Updated image container with fixed square size
                Center(
                  child: Container(
                    height: 400, // Fixed square size
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                      color: Colors.grey.shade800,
                    ),
                    child: workingImageUrl != null &&
                            workingImageUrl!.isNotEmpty
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  color: Colors.grey.shade900,
                                  child: Image.network(
                                    workingImageUrl!,
                                    height: 400,
                                    width: 400,
                                    fit: BoxFit.contain, // Fit entire image without cropping
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Center(
                                      child: Icon(Icons.broken_image,
                                          size: 48, color: Colors.white70),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor:
                                      Colors.black.withOpacity(0.7),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    iconSize: 18,
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        workingImageUrl = null;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image,
                                    size: 48, color: Colors.white70),
                                SizedBox(height: 8),
                                Text('No image selected',
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

// Center the button as well
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(workingImageUrl == null
                        ? "Choose Photo"
                        : "Change Photo"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      await _showStorageImagePicker(
                        parentContext: context,
                        onSelected: (url) {
                          setState(() {
                            workingImageUrl = url;
                          });
                        },
                      );
                    },
                  ),
                ),

// Make the URL display more compact
                if (workingImageUrl != null && workingImageUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.link,
                              size: 16, color: Colors.white54),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              workingImageUrl!
                                  .split('/')
                                  .last, // Show only filename
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Copy full URL',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: workingImageUrl!));
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Image URL copied'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy,
                                color: Colors.white70, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Category>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  dropdownColor: Colors.grey.shade800,
                  style: const TextStyle(color: Colors.white),
                  items: categories.map((category) {
                    return DropdownMenuItem<Category>(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (Category? newCategory) {
                    if (newCategory != null) {
                      setState(() {
                        selectedCategory = newCategory;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                // Add isActive toggle switch (only show when editing)
                if (isEditing) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Item Status',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            workingIsActive
                                ? 'Item is currently active'
                                : 'Item is currently archived',
                            style: TextStyle(
                              color: workingIsActive
                                  ? Colors.green
                                  : Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: workingIsActive,
                        onChanged: (bool newValue) async {
                          // If trying to set to false (archive), show confirmation
                          if (!newValue && workingIsActive) {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                backgroundColor: Colors.grey.shade900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: const Text(
                                  'Archive Item',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                  'Are you sure you want to archive this item? It will be moved to archived items and hidden from the main menu.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                    ),
                                    child: const Text('Archive'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              setState(() {
                                workingIsActive = false;
                              });
                            }
                          } else {
                            // Setting to true (activate) - no confirmation needed
                            setState(() {
                              workingIsActive = newValue;
                            });
                          }
                        },
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.orange,
                        inactiveTrackColor: Colors.orange.withOpacity(0.5),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24),
                ],
                const SizedBox(height: 16),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Addons',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      IconButton(
                          onPressed: () {
                            _showSelectAddonsDialog(context, (a) {
                              setState(() => addons.add(a));
                            });
                          },
                          icon: const Icon(Icons.add, color: Colors.blueAccent))
                    ]),
                ...addons.map((a) => ListTile(
                      title: Text(a.name,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text('\$${a.price}',
                          style: const TextStyle(color: Colors.white70)),
                      trailing: IconButton(
                          onPressed: () => setState(() => addons.remove(a)),
                          icon: const Icon(Icons.delete,
                              color: Colors.redAccent)),
                    )),
                const Divider(color: Colors.white24),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sizes',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      IconButton(
                          onPressed: () {
                            _showAddSizeDialog(context, (s) {
                              setState(() => sizes.add(s));
                            });
                          },
                          icon: const Icon(Icons.add, color: Colors.blueAccent))
                    ]),
                ...sizes.map((s) => ListTile(
                      title: Text(s.sizeName,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text('+\$${s.additionalPrice}',
                          style: const TextStyle(color: Colors.white70)),
                      trailing: IconButton(
                          onPressed: () => setState(() => sizes.remove(s)),
                          icon: const Icon(Icons.delete,
                              color: Colors.redAccent)),
                    )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.redAccent))),
          ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  final viewModel = ref.read(menuViewModelProvider.notifier);
                  final name = nameController.text.trim();
                  final description = descController.text.trim();
                  final price = double.tryParse(priceController.text) ?? 0;
                  
                  // Get category ID from selected category
                  final categoryId = selectedCategory?.id ?? 0;
                  
                  if (categoryId == 0) {
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a category'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }

                  if (isEditing) {
                    final bool hasNewImage = workingImageUrl != null &&
                        workingImageUrl != originalImageUrl;

                    await viewModel.editMenuItem(
                      name: name,
                      description: description,
                      price: price,
                      categoryId: categoryId,
                      itemId: item.id,
                      imageUrl: hasNewImage ? workingImageUrl : null,
                      originalImageUrl: originalImageUrl,
                      addons: addons,
                      sizes: sizes,
                      isActive: workingIsActive,
                    );
                  } else {
                    await viewModel.addMenuItem(
                      name: name,
                      description: description,
                      price: price,
                      categoryId: categoryId,
                      imageUrl: workingImageUrl,
                      addons: addons,
                      sizes: sizes,
                    );
                  }

                  if (context.mounted) {
                    Navigator.pop(context); // Close loading
                    Navigator.pop(context); // Close dialog
                    _loadPage();
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'))
        ],
      ),
    );
  }

  Future<void> _showStorageImagePicker({
    required BuildContext parentContext,
    required ValueChanged<String> onSelected,
  }) async {
    final viewModel = ref.read(menuViewModelProvider.notifier);
    const imagesPerPage = 10;

    // State variables
    List<String> categories = [];
    String? selectedCategory;
    List<StorageImage> storageImages = [];
    bool isLoading = true;
    bool hasMore = false;
    bool isUploading = false;
    String? errorMessage;
    int currentPage = 0;
    int totalImages = 0; // Track total images for pagination display
    bool initialized = false;

    await showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Load categories on first run
            Future<void> loadCategories() async {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              try {
                final fetchedCategories =
                    await viewModel.fetchStorageCategories();
                setState(() {
                  categories = fetchedCategories;
                  isLoading = false;
                });
              } catch (e) {
                setState(() {
                  errorMessage = 'Failed to load categories';
                  isLoading = false;
                });
              }
            }

            Future<void> loadCategoryImages(String category, int page) async {
              setState(() {
                isLoading = true;
                errorMessage = null;
                // Only update selectedCategory if it's different
                if (selectedCategory != category) {
                  selectedCategory = category;
                  currentPage = 0; // Reset to first page when changing category
                  storageImages = []; // Clear previous images
                }
              });
              try {
                final result = await viewModel.fetchCategoryImages(
                  category: category,
                  limit: imagesPerPage,
                  offset: page * imagesPerPage,
                );
                setState(() {
                  storageImages = result.images;
                  currentPage = page;
                  hasMore = result.hasMore;
                  // Use total count from the result
                  totalImages = result.totalCount;
                  isLoading = false;
                });
              } catch (e) {
                setState(() {
                  errorMessage = 'Failed to load images';
                  storageImages = [];
                  hasMore = false;
                  totalImages = 0;
                  isLoading = false;
                });
              }
            }

            // Show dialog to add a new category
            Future<void> _showAddCategoryDialog({
              required BuildContext context,
              required StateSetter setState,
              required Future<void> Function() loadCategories,
            }) async {
              final categoryNameController = TextEditingController();
              
              final result = await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    backgroundColor: Colors.grey.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: const Text(
                      'Add New Category',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: categoryNameController,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Category Name',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (categoryNameController.text.trim().isNotEmpty) {
                            Navigator.pop(dialogContext, true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );

              if (result == true && categoryNameController.text.trim().isNotEmpty) {
                final categoryName = categoryNameController.text.trim();
                
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                try {
                  await viewModel.createStorageCategory(categoryName);
                  // Reload categories
                  await loadCategories();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                        content: Text('Category "$categoryName" created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  setState(() {
                    isLoading = false;
                    errorMessage = 'Failed to create category: $e';
                  });
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                        content: Text('Error creating category: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                } finally {
                  if (context.mounted) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              }
            }

            // Show dialog to delete a category
            Future<void> _showDeleteCategoryDialog({
              required BuildContext context,
              required StateSetter setState,
              required Future<void> Function() loadCategories,
              required List<String> categories,
            }) async {
              String? selectedCategoryToDelete;
              
              final result = await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) {
                  return StatefulBuilder(
                    builder: (context, setDialogState) {
                      return AlertDialog(
                        backgroundColor: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: const Text(
                          'Delete Category',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: SizedBox(
                          width: 300,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Select a category to delete:',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 12),
                              if (categories.isEmpty)
                                const Text(
                                  'No categories available',
                                  style: TextStyle(color: Colors.white70),
                                )
                              else
                                DropdownButtonFormField<String>(
                                  value: selectedCategoryToDelete,
                                  dropdownColor: Colors.grey.shade800,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Category',
                                    labelStyle: const TextStyle(color: Colors.white70),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.redAccent),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  items: categories.map((category) {
                                    return DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(category),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      selectedCategoryToDelete = value;
                                    });
                                  },
                                ),
                              if (selectedCategoryToDelete != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade900.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.redAccent),
                                  ),
                                  child: Text(
                                    '⚠️ Warning: This will delete all images in "$selectedCategoryToDelete" category. This action cannot be undone!',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: selectedCategoryToDelete == null
                                ? null
                                : () => Navigator.pop(dialogContext, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );

              if (result == true && selectedCategoryToDelete != null) {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                try {
                  await viewModel.deleteStorageCategory(selectedCategoryToDelete!);
                  // Reload categories
                  await loadCategories();
                  
                  // If we were viewing the deleted category, go back to category list
                  if (selectedCategory == selectedCategoryToDelete) {
                    setState(() {
                      selectedCategory = null;
                      storageImages = [];
                      currentPage = 0;
                      totalImages = 0;
                    });
                  }
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                        content: Text('Category "$selectedCategoryToDelete" deleted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  setState(() {
                    isLoading = false;
                    errorMessage = 'Failed to delete category: $e';
                  });
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting category: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                } finally {
                  if (context.mounted) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              }
            }

            Future<void> uploadImageToCategory(String category) async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.image,
              withData: true,
            );
            
            if (result == null || result.files.isEmpty) return;
            
            final file = result.files.first;
            if (file.bytes == null) {
              if (parentContext.mounted) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('Selected file could not be read.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
              return;
            }

            setState(() {
              isUploading = true;
            });
            
            try {
              final url = await viewModel.uploadImageToCategory(
                bytes: file.bytes!,
                originalFileName: file.name,
                category: category,
              );
              
              if (!parentContext.mounted || !dialogContext.mounted) return;
              
              // Optionally auto-select the uploaded image
              onSelected(url);
              Navigator.of(dialogContext).pop();
              
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(
                  content: Text('Image uploaded to $category successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              if (parentContext.mounted) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text('Upload failed: $e'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            } finally {
              if (context.mounted) {
                setState(() {
                  isUploading = false;
                });
              }
            }
          }

            // Show category selector for upload
            Future<void> showUploadCategorySelector() async {
              final selectedUploadCategory = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.grey.shade900,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    title: const Text('Select Category for Upload',
                        style: TextStyle(color: Colors.white)),
                    content: SizedBox(
                      width: 400,
                      height: 400,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return GestureDetector(
                            onTap: () => Navigator.pop(context, category),
                            child: Card(
                              color: Colors.grey.shade800,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.folder,
                                    color: Colors.blueAccent,
                                    size: 36,
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  );
                },
              );

              if (selectedUploadCategory != null) {
                // Open file picker and upload to selected category
                await uploadImageToCategory(selectedUploadCategory);
              }
            }

          // Initialize on first build
          if (!initialized) {
            initialized = true;
            Future.microtask(() => loadCategories());
          }

          return AlertDialog(
            backgroundColor: Colors.grey.shade900,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            title: Row(
              children: [
                if (selectedCategory != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        selectedCategory = null;
                        storageImages = [];
                        currentPage = 0;
                        totalImages = 0;
                      });
                    },
                  ),
                Expanded(
                  child: Text(
                    selectedCategory != null 
                        ? '$selectedCategory Images' 
                        : 'Select Category',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 700,
              height: 520,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upload button - show on both category and image views
                  ElevatedButton.icon(
                    onPressed: isUploading 
                        ? null 
                        : selectedCategory == null
                            ? showUploadCategorySelector  // On category view
                            : () => uploadImageToCategory(selectedCategory!), // On image view
                    icon: Icon(isUploading 
                        ? Icons.hourglass_empty 
                        : Icons.cloud_upload),
                    label: Text(
                      isUploading 
                          ? 'Uploading...' 
                          : selectedCategory == null
                              ? 'Upload New Image'
                              : 'Upload to $selectedCategory'
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Add and Delete Category buttons - only show on category view
                  if (selectedCategory == null)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddCategoryDialog(
                              context: context,
                              setState: setState,
                              loadCategories: loadCategories,
                            ),
                            icon: const Icon(Icons.create_new_folder),
                            label: const Text('Add Category'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: categories.isEmpty
                                ? null
                                : () => _showDeleteCategoryDialog(
                                      context: context,
                                      setState: setState,
                                      loadCategories: loadCategories,
                                      categories: categories,
                                    ),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete Category'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (selectedCategory == null) const SizedBox(height: 12),
                  
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  
                  // Main content area
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : selectedCategory == null
                            // Show categories grid
                            ? GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.5,
                                ),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  return GestureDetector(
                                    onTap: () => loadCategoryImages(category, 0),
                                    child: Card(
                                      color: Colors.grey.shade800,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.folder,
                                            color: Colors.blueAccent,
                                            size: 40,
                                          ),
                                          const SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Text(
                                              category,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            // Show images grid
                            : storageImages.isEmpty
                                ? const Center(
                                    child: Text('No images in this category',
                                        style: TextStyle(color: Colors.white70)))
                                : GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 1.0, // Square images
                                    ),
                                    itemCount: storageImages.length,
                                    itemBuilder: (context, index) {
                                      final image = storageImages[index];
                                      return GestureDetector(
                                        onTap: () {
                                          onSelected(image.publicUrl);
                                          Navigator.of(dialogContext).pop();
                                        },
                                        child: Card(
                                          color: Colors.grey.shade800,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Container(
                                                    color: Colors.grey.shade900,
                                                    child: Image.network(
                                                      image.publicUrl,
                                                      fit: BoxFit.contain, // Fit entire image without cropping
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          const Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          color: Colors.white54,
                                                          size: 32,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.6),
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    image.name,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                  ),
                  
                  // Pagination controls (only for images)
                  if (selectedCategory != null && storageImages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            totalImages > 0
                                ? 'Page ${currentPage + 1} - Showing ${storageImages.length} of $totalImages images'
                                : 'Page ${currentPage + 1} - ${storageImages.length} images',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: currentPage == 0 || isLoading
                                    ? null
                                    : () => loadCategoryImages(
                                        selectedCategory!, currentPage - 1),
                                icon: const Icon(Icons.chevron_left),
                                tooltip: 'Previous page',
                              ),
                              IconButton(
                                onPressed: (!hasMore || isLoading)
                                    ? null
                                    : () => loadCategoryImages(
                                        selectedCategory!, currentPage + 1),
                                icon: const Icon(Icons.chevron_right),
                                tooltip: 'Next page',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
  }


  void _showSelectAddonsDialog(
      BuildContext context, Function(Addon) onAdd) async {
    final menuState = ref.read(menuViewModelProvider);

    // Get addons from the current state
    final allAddons = menuState.value?.addons ?? [];

    // Set to track selected addons
    final selectedAddons = <Addon>{};

    showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                backgroundColor: Colors.grey.shade900,
                title: const Text('Select Addons',
                    style: TextStyle(color: Colors.white)),
                content: SizedBox(
                  width: 300,
                  height: 400,
                  child: allAddons.isEmpty
                      ? const Center(
                          child: Text('No addons available',
                              style: TextStyle(color: Colors.white70)))
                      : ListView.builder(
                          itemCount: allAddons.length,
                          itemBuilder: (context, index) {
                            final addon = allAddons[index];
                            final isSelected = selectedAddons.contains(addon);

                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    selectedAddons.add(addon);
                                  } else {
                                    selectedAddons.remove(addon);
                                  }
                                });
                              },
                              title: Text(addon.name,
                                  style: const TextStyle(color: Colors.white)),
                              subtitle: Text('\$${addon.price}',
                                  style:
                                      const TextStyle(color: Colors.white70)),
                            );
                          },
                        ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.redAccent)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Add all selected addons
                      for (final addon in selectedAddons) {
                        onAdd(addon);
                      }
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Add Selected'),
                  ),
                ],
              ),
            ));
  }

  void _showAddSizeDialog(BuildContext context, Function(ItemSize) onAdd) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: Colors.grey.shade900,
              title:
                  const Text('Add Size', style: TextStyle(color: Colors.white)),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        labelText: 'Size Name',
                        labelStyle: TextStyle(color: Colors.white70))),
                TextField(
                    controller: priceController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Additional Price',
                        labelStyle: TextStyle(color: Colors.white70))),
              ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.redAccent))),
                ElevatedButton(
                    onPressed: () {
                      final size = ItemSize(
                          id: 0,
                          sizeName: nameController.text.trim(),
                          additionalPrice:
                              double.tryParse(priceController.text) ?? 0,
                          itemId: 0,
                          createdAt: DateTime.now());
                      onAdd(size);
                      Navigator.pop(context);
                    },
                    child: const Text('Add'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    // Watch the main screen index to detect when this page becomes visible
    final currentIndex = ref.watch(mainScreenIndexProvider);
    const menuInventoryIndex = 3; // Index of Menu & Inventory page

    // Refresh when navigating to this page
    if (currentIndex == menuInventoryIndex && _lastSelectedIndex != menuInventoryIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPage();
      });
    }
    _lastSelectedIndex = currentIndex;

    final menuState = ref.watch(menuViewModelProvider);

    return menuState.when(
      data: (state) {
        final categories = state.categories;
        final items = state.menuItems;
        final totalCount = state.totalMenuItemsCount;

        // Calculate total pages based on server-side count
        final totalPages = (totalCount / itemsPerPage).ceil().clamp(1, 999999);

        return Scaffold(
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                backgroundColor: Colors.green,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                onPressed: () => _showAddEditMenuItemDialog(context),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                backgroundColor: Colors.blueAccent,
                icon: const Icon(Icons.category),
                label: const Text('Add Category'),
                onPressed: () => _showAddEditCategoryDialog(context),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                backgroundColor: Colors.orange,
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Manage Addons'),
                onPressed: () => _showAddAddonDialog(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Menu Management',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ArchivedItemsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.archive),
                      label: const Text('View Archived Items'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.grey.shade900,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Categories',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          if (categories.isEmpty)
                            const Text('No categories available.')
                          else
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                ChoiceChip(
                                  label: const Text('All'),
                                  selected: selectedCategory == null,
                                  onSelected: (_) =>
                                      _onCategoryChanged(null, null),
                                ),
                                ...categories.map((c) => GestureDetector(
                                      onLongPress: () =>
                                          _showAddEditCategoryDialog(context,
                                              category: c),
                                      child: ChoiceChip(
                                          label: Text(c.name),
                                          selected: selectedCategory == c.name,
                                          onSelected: (_) =>
                                              _onCategoryChanged(c.name, c.id)),
                                    )),
                              ],
                            )
                        ]),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.grey.shade900,
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      sortColumnIndex: sortColumnIndex,
                      sortAscending: isAscending,
                      columns: [
                        const DataColumn(label: Text('Image')),
                        const DataColumn(label: Text('ID')),
                        DataColumn(
                            label: const Text('Name'),
                            onSort: (i, a) =>
                                _sort((e) => e.name, i, a, items)),
                        DataColumn(
                            label: const Text('Price'),
                            onSort: (i, a) =>
                                _sort((e) => e.price, i, a, items)),
                        DataColumn(
                            label: const Text('Category'),
                            onSort: (i, a) => _sort(
                                (e) => categories
                                    .firstWhere((cat) => cat.id == e.categoryId,
                                        orElse: () => state.categories.first)
                                    .name,
                                i,
                                a,
                                items)),
                        const DataColumn(label: Text('Addons')),
                        const DataColumn(label: Text('Sizes')),
                      ],
                      rows: items.map((item) {
                        return DataRow(cells: [
                          DataCell(
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white24),
                                color: Colors.grey.shade800,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  color: Colors.grey.shade900,
                                  child: Image.network(
                                    item.image.isNotEmpty
                                        ? item.image
                                        : 'https://via.placeholder.com/60',
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.contain, // Fit entire image without cropping
                                    errorBuilder: (_, __, ___) => 
                                        const Icon(Icons.image_not_supported, size: 24),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(item.id.toString())),
                          DataCell(InkWell(
                              onTap: () => _showMenuItemDetails(context, item),
                              onLongPress: () => _showAddEditMenuItemDialog(
                                  context,
                                  item: item),
                              child: Text(item.name,
                                  style: const TextStyle(
                                      color: Colors.blueAccent,
                                      decoration: TextDecoration.underline)))),
                          DataCell(Text('\$${item.price.toStringAsFixed(2)}')),
                          DataCell(Text(categories
                              .firstWhere((cat) => cat.id == item.categoryId,
                                  orElse: () => state.categories.first)
                              .name)),
                          DataCell(Text(item.addons?.length.toString() ?? '0')),
                          DataCell(Text(item.sizes?.length.toString() ?? '0')),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (totalPages > 1)
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(
                        onPressed: currentPage > 0
                            ? () => _onPageChanged(currentPage - 1)
                            : null,
                        icon: const Icon(Icons.chevron_left)),
                    Text('Page ${currentPage + 1} of $totalPages'),
                    IconButton(
                        onPressed: currentPage < totalPages - 1
                            ? () => _onPageChanged(currentPage + 1)
                            : null,
                        icon: const Icon(Icons.chevron_right))
                  ])
              ],
            ),
          ),
        );
      },
      loading: () => const Center(
          child: Padding(
              padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
      error: (err, _) => Center(
          child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text('Failed to load menu',
                    style: TextStyle(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.bold)),
                Text(err.toString(),
                    style: const TextStyle(color: Colors.grey)),
                ElevatedButton.icon(
                    onPressed: () => ref.refresh(menuViewModelProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'))
              ]))),
    );
  }
}

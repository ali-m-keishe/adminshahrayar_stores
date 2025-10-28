import 'package:adminshahrayar/data/models/category.dart';
import 'package:adminshahrayar/data/models/menu_item.dart';
import 'package:adminshahrayar/data/models/addon.dart';
import 'package:adminshahrayar/data/models/item_size.dart';
import 'package:adminshahrayar/data/repositories/menu_repository.dart';
import 'package:adminshahrayar/ui/menu/viewmodels/menu_viemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    items.sort((a, b) {
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.image,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 48),
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
                    style:
                        TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                    style:
                        TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(isEditing ? 'Edit Category' : 'Add Category',
              style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Name', labelStyle: TextStyle(color: Colors.white70))),
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
                                  onPressed: () => Navigator.pop(context, false),
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
                    createdAt:
                        isEditing ? category.createdAt : DateTime.now());
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
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
                                      style: const TextStyle(color: Colors.white)),
                                  subtitle: Text('\$${addon.price.toStringAsFixed(2)}',
                                      style: const TextStyle(color: Colors.white70)),
                                  trailing: IconButton(
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                          context: dialogContext,
                                          builder: (_) => AlertDialog(
                                                backgroundColor: Colors.grey.shade900,
                                                title: const Text('Confirm Delete',
                                                    style: TextStyle(color: Colors.white)),
                                                content: Text(
                                                    'Are you sure you want to delete "${addon.name}"?',
                                                    style: const TextStyle(color: Colors.white70)),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () => Navigator.pop(context, false),
                                                      child: const Text('Cancel')),
                                                  ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.redAccent),
                                                      onPressed: () => Navigator.pop(context, true),
                                                      child: const Text('Delete'))
                                                ],
                                              ));
                                      if (confirm == true) {
                                        final viewModel = ref.read(menuViewModelProvider.notifier);
                                        await viewModel.deleteAddon(addon.id);
                                        Navigator.pop(dialogContext);
                                      }
                                    },
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
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
                child: const Text('Close', style: TextStyle(color: Colors.blue)),
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
                  id: 0,
                  name: name,
                  price: price,
                  createdAt: DateTime.now());
              
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

  // ✅ Add/Edit Menu Item dialog
  void _showAddEditMenuItemDialog(BuildContext context, {MenuItem? item}) {
    final isEditing = item != null;
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final priceController =
        TextEditingController(text: item?.price.toString() ?? '');
    final imageController = TextEditingController(text: item?.image ?? '');
    final categoryController =
        TextEditingController(text: item?.categoryId.toString() ?? '');

    final List<Addon> addons = List.from(item?.addons ?? []);
    final List<ItemSize> sizes = List.from(item?.sizes ?? []);

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
                TextField(
                    controller: imageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        labelText: 'Image URL',
                        labelStyle: TextStyle(color: Colors.white70))),
                TextField(
                    controller: categoryController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Category ID',
                        labelStyle: TextStyle(color: Colors.white70))),
                const SizedBox(height: 16),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Addons',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
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
                              color: Colors.white, fontWeight: FontWeight.bold)),
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
                              'Are you sure you want to delete this item?',
                              style: TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'))
                          ],
                        ));
                if (confirm == true) {
                  final viewModel = ref.read(menuViewModelProvider.notifier);
                  await viewModel.deleteMenuItem(item.id);
                  Navigator.pop(context);
                  _loadPage(); // Refresh current page
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
                final newItem = MenuItem(
                    id: isEditing ? item.id : 0,
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    price: double.tryParse(priceController.text) ?? 0,
                    image: imageController.text.trim(),
                    categoryId: int.tryParse(categoryController.text) ?? 0,
                    createdAt:
                        isEditing ? item.createdAt : DateTime.now(),
                    addons: addons,
                    sizes: sizes);
                final viewModel = ref.read(menuViewModelProvider.notifier);
                if (isEditing) {
                  await viewModel.editMenuItem(newItem);
                } else {
                  await viewModel.addMenuItem(newItem);
                }
                Navigator.pop(context);
                _loadPage(); // Refresh current page
              },
              child: Text(isEditing ? 'Save' : 'Add'))
        ],
      ),
    );
  }

  void _showSelectAddonsDialog(BuildContext context, Function(Addon) onAdd) async {
    final menuRepository = ref.read(menuRepositoryProvider);
    
    // Fetch all existing addons from the database
    final allAddons = await menuRepository.getAllAddons();
    
    // Set to track selected addons
    final selectedAddons = <Addon>{};
    
    showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: Colors.grey.shade900,
            title: const Text('Select Addons', style: TextStyle(color: Colors.white)),
            content: SizedBox(
              width: 300,
              height: 400,
              child: allAddons.isEmpty
                  ? const Center(child: Text('No addons available', style: TextStyle(color: Colors.white70)))
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
                          title: Text(addon.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text('\$${addon.price}', style: const TextStyle(color: Colors.white70)),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
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
              title: const Text('Add Size', style: TextStyle(color: Colors.white)),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Size Name')),
                TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Additional Price')),
              ]),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(onPressed: () {
                  final size = ItemSize(id: 0, sizeName: nameController.text.trim(), additionalPrice: double.tryParse(priceController.text) ?? 0, itemId: 0, createdAt: DateTime.now());
                  onAdd(size);
                  Navigator.pop(context);
                }, child: const Text('Add'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
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
                Text('Menu Management',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
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
                                  onSelected: (_) => _onCategoryChanged(null, null),
                                ),
                                ...categories.map((c) => GestureDetector(
                                      onLongPress: () =>
                                          _showAddEditCategoryDialog(context,
                                              category: c),
                                      child: ChoiceChip(
                                          label: Text(c.name),
                                          selected:
                                              selectedCategory == c.name,
                                          onSelected: (_) => _onCategoryChanged(c.name, c.id)),
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
                                    .firstWhere(
                                        (cat) => cat.id == e.categoryId,
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
                          DataCell(ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              item.image.isNotEmpty
                                  ? item.image
                                  : 'https://via.placeholder.com/50',
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          )),
                          DataCell(Text(item.id.toString())),
                          DataCell(InkWell(
                              onTap: () =>
                                  _showMenuItemDetails(context, item),
                              onLongPress: () =>
                                  _showAddEditMenuItemDialog(context,
                                      item: item),
                              child: Text(item.name,
                                  style: const TextStyle(
                                      color: Colors.blueAccent,
                                      decoration: TextDecoration.underline)))),
                          DataCell(Text('\$${item.price.toStringAsFixed(2)}')),
                          DataCell(Text(categories
                              .firstWhere(
                                  (cat) => cat.id == item.categoryId,
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
          child:
              Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
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
                Text(err.toString(), style: const TextStyle(color: Colors.grey)),
                ElevatedButton.icon(
                    onPressed: () => ref.refresh(menuViewModelProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'))
              ]))),
    );
  }
}

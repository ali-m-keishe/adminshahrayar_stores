import 'package:adminshahrayar/data/models/menu_item.dart';
import 'package:adminshahrayar/ui/menu/viewmodels/menu_notifier.dart';
import 'package:adminshahrayar/ui/menu/views/add_edit_category_dialog.dart';
import 'package:adminshahrayar/ui/menu/views/add_edit_menu_item_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  // Helper function for adding/editing a menu item
  void _showItemDialog(BuildContext context, WidgetRef ref,
      {MenuItem? menuItem}) async {
    final menuState = ref.read(menuProvider);
    final result = await showDialog<MenuItem>(
      context: context,
      builder: (context) => AddEditMenuItemDialog(
        menuItem: menuItem,
        categories: menuState.valueOrNull?.categories ?? [],
      ),
    );

    if (result != null) {
      if (menuItem == null) {
        ref.read(menuProvider.notifier).addMenuItem(result);
      } else {
        ref.read(menuProvider.notifier).updateMenuItem(result);
      }
    }
  }

  // Helper function for adding/editing a category
  void _showAddEditCategoryDialog(BuildContext context, WidgetRef ref,
      {String? existingCategoryName}) async {
    final newCategoryName = await showDialog<String>(
      context: context,
      builder: (context) =>
          AddEditCategoryDialog(existingCategoryName: existingCategoryName),
    );

    if (newCategoryName != null) {
      if (existingCategoryName == null) {
        ref.read(menuProvider.notifier).addCategory(newCategoryName);
      } else {
        ref
            .read(menuProvider.notifier)
            .updateCategory(existingCategoryName, newCategoryName);
      }
    }
  }

  // Helper function for confirming deletion of a menu item
  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, MenuItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
            'Are you sure you want to delete "${item.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(menuProvider.notifier).deleteMenuItem(item.name);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuState = ref.watch(menuProvider);
    final filteredItems = ref.watch(filteredMenuItemsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Menu & Inventory',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add New Item'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary),
                onPressed: () => _showItemDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Categories',
                            style: Theme.of(context).textTheme.titleLarge),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          tooltip: 'Add Category',
                          onPressed: () =>
                              _showAddEditCategoryDialog(context, ref),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: menuState.valueOrNull?.categories.length ?? 0,
                      itemBuilder: (context, index) {
                        final category =
                            menuState.valueOrNull?.categories[index] ?? '';

                        final chip = ChoiceChip(
                          label: Text(category),
                          avatar: category != 'All'
                              ? const Icon(Icons.edit, size: 14)
                              : null,
                          selected: menuState.valueOrNull?.selectedCategory ==
                              category,
                          onSelected: (isSelected) {
                            if (isSelected) {
                              ref
                                  .read(menuProvider.notifier)
                                  .selectCategory(category);
                            }
                          },
                          selectedColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(
                              color: menuState.valueOrNull?.selectedCategory ==
                                      category
                                  ? Colors.white
                                  : null),
                        );

                        if (category == 'All') {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: chip,
                          );
                        }

                        return GestureDetector(
                          onLongPress: () {
                            _showAddEditCategoryDialog(context, ref,
                                existingCategoryName: category);
                          },
                          child: Tooltip(
                            message: 'Long-press to edit',
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: chip,
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return MenuItemCard(
                      item: item,
                      onEdit: () =>
                          _showItemDialog(context, ref, menuItem: item),
                      onDelete: () =>
                          _showDeleteConfirmation(context, ref, item),
                    );
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MenuItemCard(
      {super.key,
      required this.item,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            item.image,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 120,
              color: Colors.grey.shade300,
              child: const Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      size: 40, color: Colors.grey)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis),
                Text('Category ${item.categoryId}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('\$${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.secondary)),
                ),
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: onEdit,
                        tooltip: 'Edit Item'),
                    IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: onDelete,
                        tooltip: 'Delete Item',
                        color: Colors.red.shade300),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:adminshahrayar/ui/menu/viewmodels/menu_viemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adminshahrayar/data/models/menu_item.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  String? selectedCategory;
  int currentPage = 0;
  final int itemsPerPage = 6;

  // ✅ For sorting
  int? sortColumnIndex;
  bool isAscending = true;

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

void _showMenuItemDetails(BuildContext context, MenuItem item) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        item.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
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

            // Description
            if (item.description.isNotEmpty)
              Text(
                'Description: ${item.description}',
                style: const TextStyle(color: Colors.white70),
              ),
            const SizedBox(height: 12),

            // Price and Category
            Text('Price: \$${item.price.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('Category ID: ${item.categoryId}',
                style: const TextStyle(color: Colors.white70)),

            // 🔹 Addons section
            if (item.addons != null && item.addons!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white24),
              const Text(
                'Addons:',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              ...item.addons!.map(
                (addon) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                  child: Text(
                    '- ${addon.name} (\$${addon.price.toStringAsFixed(2)})',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],

            // 🔹 Sizes section
            if (item.sizes != null && item.sizes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white24),
              const Text(
                'Sizes:',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              ...item.sizes!.map(
                (size) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                  child: Text(
                    '- ${size.sizeName} (+\$${size.additionalPrice.toStringAsFixed(2)})',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
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


  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuViewModelProvider);

    return menuState.when(
      data: (state) {
        final categories = state.categories;
        final items = state.menuItems;

        // ✅ Filtering logic
        final filteredItems = selectedCategory == null
            ? items
            : items
                .where((item) =>
                    categories
                        .firstWhere((cat) => cat.id == item.categoryId,
                            orElse: () => state.categories.first)
                        .name ==
                    selectedCategory)
                .toList();

        // ✅ Pagination logic
        final totalPages =
            (filteredItems.length / itemsPerPage).ceil().clamp(1, 999);
        final startIndex = currentPage * itemsPerPage;
        final endIndex =
            (startIndex + itemsPerPage).clamp(0, filteredItems.length);
        final paginatedItems = filteredItems.sublist(
            startIndex, endIndex); // slice for current page

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Title
              Text(
                'Menu Management',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // 🔹 Category Filter
              Card(
                color: Colors.grey.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
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
                              onSelected: (_) {
                                setState(() {
                                  selectedCategory = null;
                                  currentPage = 0;
                                });
                              },
                            ),
                            ...categories.map((c) => ChoiceChip(
                                  label: Text(c.name),
                                  selected: selectedCategory == c.name,
                                  onSelected: (_) {
                                    setState(() {
                                      selectedCategory = c.name;
                                      currentPage = 0;
                                    });
                                  },
                                )),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 Menu Items Table
              Card(
                color: Colors.grey.shade900,
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    sortColumnIndex: sortColumnIndex,
                    sortAscending: isAscending,
                    columns: [
                      const DataColumn(label: Text('Image')),
                      DataColumn(
                        label: const Text('ID'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: const Text('Name'),
                        onSort: (columnIndex, ascending) => _sort(
                            (item) => item.name,
                            columnIndex,
                            ascending,
                            filteredItems),
                      ),
                      DataColumn(
                        label: const Text('Price'),
                        numeric: true,
                        onSort: (columnIndex, ascending) => _sort(
                            (item) => item.price,
                            columnIndex,
                            ascending,
                            filteredItems),
                      ),
                      DataColumn(
                        label: const Text('Category'),
                        onSort: (columnIndex, ascending) => _sort(
                            (item) => categories
                                .firstWhere((cat) => cat.id == item.categoryId,
                                    orElse: () => state.categories.first)
                                .name,
                            columnIndex,
                            ascending,
                            filteredItems),
                      ),
                      const DataColumn(label: Text('Addons')),
                      const DataColumn(label: Text('Sizes')),
                    ],
                    rows: paginatedItems.map((item) {
                      return DataRow(
                        cells: [
                          // ✅ Image First
                          DataCell(
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                item.image.isNotEmpty
                                    ? item.image
                                    : 'https://via.placeholder.com/50',
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported,
                                        size: 24),
                              ),
                            ),
                          ),
                          DataCell(Text(item.id.toString())),
                          DataCell(
                            InkWell(
                              onTap: () => _showMenuItemDetails(context, item),
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text('\$${item.price.toStringAsFixed(2)}')),
                          DataCell(Text(
                            categories
                                .firstWhere(
                                  (cat) => cat.id == item.categoryId,
                                  orElse: () => state.categories.first,
                                )
                                .name,
                          )),
                          DataCell(Text(item.addons?.length.toString() ?? '0')),
                          DataCell(Text(item.sizes?.length.toString() ?? '0')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 Pagination Controls
              if (totalPages > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: currentPage > 0
                          ? () => setState(() => currentPage--)
                          : null,
                    ),
                    Text('Page ${currentPage + 1} of $totalPages'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: currentPage < totalPages - 1
                          ? () => setState(() => currentPage++)
                          : null,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                'Failed to load menu.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(menuViewModelProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

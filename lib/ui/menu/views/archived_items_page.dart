import 'package:adminshahrayar_stores/data/models/menu_item.dart';
import 'package:adminshahrayar_stores/main_screen.dart';
import 'package:adminshahrayar_stores/ui/menu/viewmodels/menu_viemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArchivedItemsPage extends ConsumerStatefulWidget {
  const ArchivedItemsPage({super.key});

  @override
  ConsumerState<ArchivedItemsPage> createState() => _ArchivedItemsPageState();
}

class _ArchivedItemsPageState extends ConsumerState<ArchivedItemsPage> {
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
    viewModel.loadPaginatedArchivedMenuItems(
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
                          fit: BoxFit.contain,
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
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Status: ',
                      style: TextStyle(color: Colors.white70)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.isActive ? 'Active' : 'Archived',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              if (item.attributes != null && item.attributes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(color: Colors.white24),
                const Text('Attributes:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                ...item.attributes!.map((attr) => Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Text(
                          '- ${attr.name} (${attr.type}) ${attr.isRequired ? "[Required]" : ""}',
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

  Future<void> _restoreItem(int itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Restore Item',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            'Are you sure you want to restore this item? It will become active again.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final viewModel = ref.read(menuViewModelProvider.notifier);
        await viewModel.toggleMenuItemActive(itemId, true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item restored successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadPage(); // Refresh current page
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error restoring item: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the main screen index to detect when this page becomes visible
    final currentIndex = ref.watch(mainScreenIndexProvider);
    const archivedItemsIndex = 10; // Index of archived items page

    // Refresh when navigating to this page
    if (currentIndex == archivedItemsIndex && _lastSelectedIndex != archivedItemsIndex) {
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text('Archived Items',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
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
                                ...categories.map((c) => ChoiceChip(
                                      label: Text(c.name),
                                      selected: selectedCategory == c.name,
                                      onSelected: (_) =>
                                          _onCategoryChanged(c.name, c.id),
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
                        const DataColumn(label: Text('Attributes')),
                        const DataColumn(label: Text('Actions')),
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
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image_not_supported,
                                            size: 24),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(item.id.toString())),
                          DataCell(InkWell(
                              onTap: () => _showMenuItemDetails(context, item),
                              child: Text(item.name,
                                  style: const TextStyle(
                                      color: Colors.blueAccent,
                                      decoration: TextDecoration.underline)))),
                          DataCell(Text('\$${item.price.toStringAsFixed(2)}')),
                          DataCell(Text(categories
                              .firstWhere((cat) => cat.id == item.categoryId,
                                  orElse: () => state.categories.first)
                              .name)),
                          DataCell(Text(item.attributes?.length.toString() ?? '0')),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.restore, color: Colors.green),
                              onPressed: () => _restoreItem(item.id),
                              tooltip: 'Restore item',
                            ),
                          ),
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
                Text('Failed to load archived items',
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


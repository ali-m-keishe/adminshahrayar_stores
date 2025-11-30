import 'package:adminshahrayar_stores/data/models/promotion.dart';
import 'package:adminshahrayar_stores/ui/promotions/viewmodels/promotions_notifier.dart';
import 'package:adminshahrayar_stores/ui/promotions/views/add_edit_promotion_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PromotionsPage extends ConsumerWidget {
  const PromotionsPage({super.key});

  void _showPromoDialog(BuildContext context, WidgetRef ref,
      {Promotion? promotion}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddEditPromotionDialog(promotion: promotion),
    );

    if (result != null) {
      final notifier = ref.read(promotionsProvider.notifier);
      await notifier.savePromotion(id: promotion?.id, data: result);
    }
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, Promotion promo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
            'Are you sure you want to delete the "${promo.name}" promotion? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(false), // User chose "Cancel"
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(true), // User chose "Delete"
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // Only proceed if the user confirmed
    if (confirm == true) {
      await ref.read(promotionsProvider.notifier).deletePromotion(promo.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We set up a listener that watches for changes in the main promotions list.
    ref.listen<AsyncValue<List<Promotion>>>(promotionsProvider,
        (previous, next) {
      // When the state changes from loading to data (i.e., a refresh was successful)...
      if (previous is AsyncLoading && next is AsyncData) {
        // ...we invalidate the links provider. This tells it to re-fetch next time it's needed.
        ref.invalidate(promotionLinksProvider);
      }
    });

    final promotionsAsync = ref.watch(promotionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotions'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Promotion',
            onPressed: () => _showPromoDialog(context, ref),
          ),
        ],
      ),
      body: promotionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
        data: (promotions) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Code')),
                  DataColumn(label: Text('Value')),
                  DataColumn(label: Text('Applicable Items')),
                  DataColumn(label: Text('End Date')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: promotions.map((promo) {
                  final itemNames = (promo.items?.isEmpty ?? true)
                      ? 'All Items'
                      : promo.items!.map((item) => item.name).join(', ');

                  return DataRow(cells: [
                    DataCell(Text(promo.name,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(promo.displayValue)),
                    DataCell(Text(itemNames)),
                    DataCell(Text(DateFormat.yMMMd().format(promo.endDate))),
                    DataCell(
                      Switch(
                        value: promo.isActive,
                        onChanged: (newStatus) {
                          ref
                              .read(promotionsProvider.notifier)
                              .togglePromotionStatus(promo.id, newStatus);
                        },
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_note),
                            tooltip: 'Edit Promotion',
                            onPressed: () => _showPromoDialog(context, ref,
                                promotion: promo),
                          ),
                          // vvv NEW DELETE BUTTON vvv
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            tooltip: 'Delete Promotion',
                            onPressed: () =>
                                _showDeleteConfirmation(context, ref, promo),
                          ),
                          // ^^^ NEW DELETE BUTTON ^^^
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

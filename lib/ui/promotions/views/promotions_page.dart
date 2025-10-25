import 'package:adminshahrayar/data/models/promotion.dart';
import 'package:adminshahrayar/ui/promotions/viewmodels/promotions_notifier.dart';
import 'package:adminshahrayar/ui/promotions/views/add_edit_promotion_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PromotionsPage extends ConsumerWidget {
  const PromotionsPage({super.key});

  // Helper function to show the dialog for adding or editing
  void _showPromoDialog(BuildContext context, WidgetRef ref,
      {Promotion? promotion}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddEditPromotionDialog(promotion: promotion),
    );

    if (result != null) {
      final notifier = ref.read(promotionsProvider.notifier);

      // vvv THIS IS THE FIX vvv
      // The dialog now returns real DateTime objects for the start and end dates.
      // We must format them into ISO 8601 strings, which Supabase understands for 'timestamptz' columns.
      result['start_date'] =
          (result['start_date'] as DateTime).toIso8601String();
      result['end_date'] = (result['end_date'] as DateTime).toIso8601String();
      // ^^^ THIS IS THE FIX ^^^

      if (promotion == null) {
        // We are adding a new promotion
        await notifier.addPromotion(result);
      } else {
        // We are updating an existing promotion
        await notifier.updatePromotion(promotion.id, result);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Value')),
                  DataColumn(label: Text('End Date')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: promotions.map((promo) {
                  return DataRow(cells: [
                    DataCell(Text(promo.name,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(promo.description ?? '')),
                    DataCell(Text(promo.displayValue)),
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
                      IconButton(
                        icon: const Icon(Icons.edit_note),
                        onPressed: () =>
                            _showPromoDialog(context, ref, promotion: promo),
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

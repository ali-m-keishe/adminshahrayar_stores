// import 'package:adminshahrayar/models/promotion.dart';
// import 'package:adminshahrayar/screens/promotions/promotions_notifier.dart';
// import 'package:adminshahrayar/screens/promotions/widgets/add_edit_promotion_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class PromotionsPage extends ConsumerWidget {
//   const PromotionsPage({super.key});

//   void _showPromoDialog(BuildContext context, WidgetRef ref,
//       {Promotion? promotion}) async {
//     final result = await showDialog<Map<String, dynamic>>(
//       context: context,
//       builder: (context) => AddEditPromotionDialog(promotion: promotion),
//     );

//     if (result != null) {
//       if (promotion == null) {
//         // Adding
//         final newPromo = Promotion(
//           id: ref.read(uuidProvider).v4(),
//           code: result['code'],
//           description: result['description'],
//           discountType: result['discountType'],
//           discountValue: result['discountValue'],
//           isActive: result['isActive'],
//         );
//         ref.read(promotionsProvider.notifier).addPromotion(newPromo);
//       } else {
//         // Editing
//         final updatedPromo = Promotion(
//           id: promotion.id,
//           code: result['code'],
//           description: result['description'],
//           discountType: result['discountType'],
//           discountValue: result['discountValue'],
//           isActive: result['isActive'],
//         );
//         ref.read(promotionsProvider.notifier).updatePromotion(updatedPromo);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final promotions = ref.watch(promotionsProvider);

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('Promotions',
//                   style: Theme.of(context)
//                       .textTheme
//                       .headlineMedium
//                       ?.copyWith(fontWeight: FontWeight.bold)),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.add),
//                 label: const Text('Add Promotion'),
//                 onPressed: () => _showPromoDialog(context, ref),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           Card(
//             child: SizedBox(
//               width: double.infinity,
//               child: DataTable(
//                 columns: const [
//                   DataColumn(label: Text('Code')),
//                   DataColumn(label: Text('Description')),
//                   DataColumn(label: Text('Value')),
//                   DataColumn(label: Text('Status')),
//                   DataColumn(label: Text('Actions')),
//                 ],
//                 rows: promotions.map((promo) {
//                   return DataRow(cells: [
//                     DataCell(Text(promo.code,
//                         style: const TextStyle(fontWeight: FontWeight.bold))),
//                     DataCell(Text(promo.description)),
//                     DataCell(Text(promo.displayValue)),
//                     DataCell(
//                       Switch(
//                         value: promo.isActive,
//                         onChanged: (value) => ref
//                             .read(promotionsProvider.notifier)
//                             .togglePromotionStatus(promo.id, value),
//                       ),
//                     ),
//                     DataCell(
//                       IconButton(
//                         icon: const Icon(Icons.edit),
//                         onPressed: () =>
//                             _showPromoDialog(context, ref, promotion: promo),
//                       ),
//                     ),
//                   ]);
//                 }).toList(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

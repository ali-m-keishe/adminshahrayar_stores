import 'package:adminshahrayar/ui/customer/viewmodels/customers_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CustomersPage extends ConsumerWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We now watch the provider that gives us the AsyncValue<List<Customer>> directly
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Customers'),
        centerTitle: false,
        actions: [
          // Refresh button to re-fetch the data
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(customersProvider),
          ),
        ],
      ),
      body: customersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) =>
            Center(child: Text('Failed to load customers: $e')),
        data: (customers) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Total Orders'), numeric: true),
                  DataColumn(label: Text('Total Spent'), numeric: true),
                  // Add a column for actions like Edit/Delete
                  DataColumn(label: Text('Phone Number')),
                ],
                rows: customers.map((customer) {
                  return DataRow(cells: [
                    DataCell(Text(customer.name,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(customer.orderCount.toString())),
                    DataCell(Text(NumberFormat.simpleCurrency()
                        .format(customer.totalSpent))),
                    DataCell(Text(customer.phone,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
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

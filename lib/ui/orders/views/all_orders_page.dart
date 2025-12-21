import 'package:adminshahrayar_stores/data/models/order.dart';
import 'package:adminshahrayar_stores/ui/dashboard/views/order_details_dialog.dart';
import 'package:adminshahrayar_stores/ui/orders/viewmodels/orders_notifier.dart';
import 'package:adminshahrayar_stores/ui/orders/views/order_search_delegate.dart';
import 'package:adminshahrayar_stores/ui/orders/views/address_details_dialog.dart';
import 'package:adminshahrayar_stores/ui/orders/views/order_status_badge.dart';
import 'package:adminshahrayar_stores/widget/user_info_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

class AllOrdersPage extends ConsumerStatefulWidget {
  const AllOrdersPage({super.key});

  @override
  ConsumerState<AllOrdersPage> createState() => _AllOrdersPageState();
}

class _AllOrdersPageState extends ConsumerState<AllOrdersPage> {
  final int itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPage();
    });
  }

  void _loadPage() {
    final notifier = ref.read(ordersProvider.notifier);
    final currentPage = ref.read(ordersPageIndexProvider);
    final offset = currentPage * itemsPerPage;
    final filter = ref.read(allOrdersFilterProvider);
    notifier.loadPaginatedAllOrders(limit: itemsPerPage, offset: offset, filter: filter);
  }

  void _onPageChanged(int newPage) {
    ref.read(ordersPageIndexProvider.notifier).state = newPage;
    _loadPage();
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersProvider).valueOrNull;
    final currentPage = ref.watch(ordersPageIndexProvider);
    final orders = ordersState?.orders ?? [];
    final totalCount = ordersState?.totalOrdersCount ?? 0;
    final allOrders = orders; // for search delegate

    final totalPages = (totalCount / itemsPerPage).ceil().clamp(1, 999999);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search Orders',
            onPressed: () async {
              final selectedOrder = await showSearch<Order?>(
                context: context,
                delegate: OrderSearchDelegate(allOrders: allOrders),
              );

              if (context.mounted && selectedOrder != null) {
                _showOrderDetails(context, selectedOrder);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // فلتر الأوامر
            const _FilterChips(),
            const SizedBox(height: 16),
            Card(
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                  columns: const [
                    DataColumn(label: Text('id')),
                    DataColumn(label: Text('created_at')),
                    DataColumn(label: Text('cart_id')),
                    DataColumn(label: Text('status')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('payment_token')),
                    DataColumn(label: Text('address_id')),
                  ],
                  // Server-side paginated orders
                  rows: orders.map((order) {
                    return DataRow(
                      // ✅ تم إزالة onSelectChanged لإزالة الـ checkboxes
                      cells: [
                        DataCell(
                          InkWell(
                            onTap: () => _showOrderDetails(context, order),
                            child: Text(
                              order.id.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          InkWell(
                            onTap: () => _showOrderDetails(context, order),
                            child: Text(timeago.format(order.createdAt)),
                          ),
                        ),
                        DataCell(
                          InkWell(
                            onTap: () => _showOrderDetails(context, order),
                            child: Text(order.cartId.toString()),
                          ),
                        ),
                        DataCell(
                          InkWell(
                            onTap: () => _showOrderDetails(context, order),
                            child: OrderStatusBadge.fromString(order.status),
                          ),
                        ),
                        DataCell(UserInfoCell(userId: order.userId, cartId: order.cartId, showEmail: true, showPhone: false)),
                        DataCell(UserInfoCell(userId: order.userId, cartId: order.cartId, showEmail: false, showPhone: true)),
                        DataCell(
                          InkWell(
                            onTap: () => _showOrderDetails(context, order),
                            child: Text(order.paymentToken),
                          ),
                        ),
                        DataCell(
                          InkWell(
                            onTap: order.addressId != null && order.addressId != 0
                                ? () => _showAddressDetails(context, order.addressId!)
                                : null,
                            child: Text(
                              order.addressId == null || order.addressId == 0
                                  ? 'Address is empty or deleted'
                                  : (order.addressFormatted ?? 'Address #${order.addressId}'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: (order.addressId == null || order.addressId == 0)
                                    ? Colors.grey
                                    : Theme.of(context).primaryColor,
                                decoration: (order.addressId == null || order.addressId == 0)
                                    ? TextDecoration.none
                                    : TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (totalPages > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: currentPage > 0 ? () => _onPageChanged(currentPage - 1) : null,
                      icon: const Icon(Icons.chevron_left)),
                  Text('Page ${currentPage + 1} of $totalPages'),
                  IconButton(
                      onPressed: currentPage < totalPages - 1 ? () => _onPageChanged(currentPage + 1) : null,
                      icon: const Icon(Icons.chevron_right)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailsDialog(order: order),
    );
  }

  void _showAddressDetails(BuildContext context, int? addressId) {
    showDialog(
      context: context,
      builder: (context) => AddressDetailsDialog(addressId: addressId),
    );
  }
}

// Widget خاص بالفلاتر (DateFilter)
class _FilterChips extends ConsumerWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(allOrdersFilterProvider);
    return Wrap(
      spacing: 8.0,
      children: DateFilter.values.map((filter) {
        return ChoiceChip(
          label: Text(filter.name),
          selected: selectedFilter == filter,
          onSelected: (isSelected) {
            if (isSelected) {
              ref.read(allOrdersFilterProvider.notifier).setFilter(filter);
              // Reset to page 0 and reload with date filter
              ref.read(ordersPageIndexProvider.notifier).state = 0;
              ref
                  .read(ordersProvider.notifier)
                  .loadPaginatedAllOrders(limit: 5, offset: 0, filter: filter);
            }
          },
        );
      }).toList(),
    );
  }
}

import 'package:adminshahrayar/ui/analytics/views/analytics_page.dart';
import 'package:adminshahrayar/ui/customer/views/customers_page.dart';
import 'package:adminshahrayar/ui/dashboard/views/dashboard_page.dart';
import 'package:adminshahrayar/ui/delivery_driver/views/delivery_page.dart';
import 'package:adminshahrayar/ui/menu/views/MenuInventoryPage.dart';
import 'package:adminshahrayar/ui/orders/views/all_orders_page.dart';
import 'package:adminshahrayar/ui/promotions/views/promotions_page.dart';
import 'package:adminshahrayar/ui/settings/views/settings.dart';
import 'package:adminshahrayar/ui/staff/views/staff_page.dart';
import 'package:adminshahrayar/widget/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Create a provider to hold the selected page index.
final mainScreenIndexProvider = StateProvider<int>((ref) => 0);

// 2. Convert MainScreen to a ConsumerWidget to use the provider.
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 3. Watch the provider to get the current index.
    final selectedIndex = ref.watch(mainScreenIndexProvider);

    final List<Widget> pages = [
      const DashboardPage(), // Index 0
      const DeliveryPage(), // Index 1
      const AnalyticsPage(), // Index 2
      const MenuPage(), // Index 3
      const CustomersPage(), // Index 4
      const PromotionsPage(), // Index 5
      const StaffPage(), // Index 6
      const SettingsPage(), // Index 7
      const AllOrdersPage(), // Index 8
      // const PendingOrdersPage(), // Index 9
    ].map((page) => page ?? Container()).toList();
    ;

    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            Sidebar(
              selectedIndex: selectedIndex,
              // 4. Update the index when a sidebar item is tapped.
              onItemTapped: (index) =>
                  ref.read(mainScreenIndexProvider.notifier).state = index,
            ),
          Expanded(
            child: IndexedStack(index: selectedIndex, children: pages),
          ),
        ],
      ),
      drawer: isDesktop
          ? null
          : Drawer(
              child: Sidebar(
                selectedIndex: selectedIndex,
                onItemTapped: (index) {
                  ref.read(mainScreenIndexProvider.notifier).state = index;
                  Navigator.pop(context);
                },
              ),
            ),
      appBar: isDesktop ? null : AppBar(title: const Text('SavorAdmin Pro')),
    );
  }
}

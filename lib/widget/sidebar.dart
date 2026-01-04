import 'package:adminshahrayar_stores/main.dart';
import 'package:adminshahrayar_stores/ui/auth/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Sidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 256,
      color: isDark ? const Color(0xFF111827) : theme.cardColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Text(
                  'SavorAdmin Pro',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              children: [
                _SidebarLink(
                  text: 'Dashboard',
                  icon: Icons.dashboard,
                  isSelected: selectedIndex == 0,
                  onTap: () => onItemTapped(0),
                ),
                _SidebarLink(
                  text: 'Delivery',
                  icon: Icons.local_shipping,
                  isSelected: selectedIndex == 1,
                  onTap: () => onItemTapped(1),
                ),
                _SidebarLink(
                  text: 'Analytics',
                  icon: Icons.analytics,
                  isSelected: selectedIndex == 2,
                  onTap: () => onItemTapped(2),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
                  child: Divider(height: 1),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'MANAGEMENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                _SidebarLink(
                  text: 'Menu & Inventory',
                  icon: Icons.menu_book,
                  isSelected: selectedIndex == 3,
                  onTap: () => onItemTapped(3),
                ),
                _SidebarLink(
                  text: 'Archived Items',
                  icon: Icons.archive,
                  isSelected: selectedIndex == 10,
                  onTap: () => onItemTapped(10),
                ),
                _SidebarLink(
                  text: 'Attributes',
                  icon: Icons.category,
                  isSelected: selectedIndex == 11,
                  onTap: () => onItemTapped(11),
                ),
                _SidebarLink(
                  text: 'Customers & Reviews',
                  icon: Icons.people,
                  isSelected: selectedIndex == 4,
                  onTap: () => onItemTapped(4),
                ),
                _SidebarLink(
                  text: 'Promotions',
                  icon: Icons.local_offer,
                  isSelected: selectedIndex == 5,
                  onTap: () => onItemTapped(5),
                ),
                _SidebarLink(
                  text: 'Staff',
                  icon: Icons.badge,
                  isSelected: selectedIndex == 6,
                  onTap: () => onItemTapped(6),
                ),
                _SidebarLink(
                  text: 'Settings',
                  icon: Icons.settings,
                  isSelected: selectedIndex == 7,
                  onTap: () => onItemTapped(7),
                ),
                _SidebarLink(
                  text: 'Send Notification',
                  icon: Icons.notifications_active_outlined,
                  isSelected: selectedIndex == 9,
                  onTap: () => onItemTapped(9),
                ),
              ],
            ),
          ),
          _buildUserProfile(context, ref),
          // Logout button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                final authViewModel = ref.read(authViewModelProvider.notifier);
                await authViewModel.signOut();
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authViewModelProvider);
    
    final userEmail = authState.userEmail ?? 'Admin';
    final displayName = userEmail.split('@').first; // Get name part before @

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    authState.isAdmin ? 'Admin' : 'User',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarLink extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarLink({
    required this.text,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color:
          isSelected ? theme.primaryColor.withOpacity(0.2) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isSelected ? theme.primaryColor : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? theme.primaryColor : Colors.grey),
              const SizedBox(width: 16),
              Text(
                text,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.textTheme.bodyLarge?.color
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

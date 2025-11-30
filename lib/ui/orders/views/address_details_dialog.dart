import 'package:adminshahrayar_stores/data/models/address.dart';
import 'package:adminshahrayar_stores/data/repositories/address_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddressDetailsDialog extends ConsumerWidget {
  final int? addressId;
  const AddressDetailsDialog({super.key, required this.addressId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Handle null or 0 addressId
    if (addressId == null || addressId == 0) {
      return AlertDialog(
        title: const Text('Address Details'),
        content: const Text('Address is empty or deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    }

    final repo = AddressRepository();
    return FutureBuilder<Address?>(
      future: repo.getAddressById(addressId!),
      builder: (context, snapshot) {
        final theme = Theme.of(context);

        if (snapshot.connectionState != ConnectionState.done) {
          return AlertDialog(
            title: const Text('Address Details'),
            content: const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final address = snapshot.data;
        if (address == null) {
          return AlertDialog(
            title: const Text('Address Details'),
            content: const Text('Address is empty or deleted.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        }

        return AlertDialog(
          title: Text('Address #${address.id} (${address.customLabel})'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Formatted', address.formattedAddress, theme),
                _row('Region', address.regionName, theme),
                const Divider(height: 16),
                _row('Latitude', address.latitude.toString(), theme),
                _row('Longitude', address.longitude.toString(), theme),
                const SizedBox(height: 8),
                _row('User ID', address.userId, theme),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _row(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

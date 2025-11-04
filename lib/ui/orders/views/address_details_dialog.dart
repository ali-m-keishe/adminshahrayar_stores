import 'package:adminshahrayar/data/models/address.dart';
import 'package:adminshahrayar/data/repositories/address_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddressDetailsDialog extends ConsumerWidget {
  final int addressId;
  const AddressDetailsDialog({super.key, required this.addressId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = AddressRepository();
    return FutureBuilder<Address?>
      (future: repo.getAddressById(addressId),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        if (snapshot.connectionState != ConnectionState.done) {
          return AlertDialog(
            title: const Text('Address Details'),
            content: const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
          );
        }
        final address = snapshot.data;
        if (address == null) {
          return AlertDialog(
            title: const Text('Address Details'),
            content: const Text('Address not found.'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
          );
        }
        return AlertDialog(
          title: Text('Address #${address.id} (${address.customLabel})'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row('Formatted', address.formattedAddress, theme),
              const SizedBox(height: 8),
              _row('Block', address.blockNumber, theme),
              _row('Entrance', address.entrance, theme),
              _row('Floor', address.floor.isEmpty ? '-' : address.floor, theme),
              _row('Apartment', address.apartment.isEmpty ? '-' : address.apartment, theme),
              const Divider(height: 16),
              _row('Latitude', address.latitude.toString(), theme),
              _row('Longitude', address.longitude.toString(), theme),
              const SizedBox(height: 8),
              _row('User ID', address.userId, theme),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        );
      },
    );
  }

  Widget _row(String label, String value, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 100, child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey))),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
      ],
    );
  }
}



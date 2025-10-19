import 'package:adminshahrayar/data/models/staff_member.dart';
import 'package:adminshahrayar/ui/staff/viewmodels/staff_notifier.dart';
import 'package:adminshahrayar/ui/staff/views/add_edit_staff_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StaffPage extends ConsumerWidget {
  const StaffPage({super.key});

  void _showStaffDialog(BuildContext context, WidgetRef ref,
      {StaffMember? staffMember}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddEditStaffDialog(staffMember: staffMember),
    );

    if (result != null) {
      if (staffMember == null) {
        // Adding new member
        final newMember = StaffMember(
          id: ref.read(uuidProvider).v4(),
          name: result['name'],
          role: result['role'],
          status: result['status'],
        );
        ref.read(staffProvider.notifier).addStaffMember(newMember);
      } else {
        // Editing existing member
        final updatedMember = StaffMember(
          id: staffMember.id,
          name: result['name'],
          role: result['role'],
          status: result['status'],
        );
        ref.read(staffProvider.notifier).updateStaffMember(updatedMember);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffList = ref.watch(staffProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Staff Management',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Staff Member'),
                onPressed: () => _showStaffDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: staffList.map((member) {
                  return DataRow(cells: [
                    DataCell(Text(member.name)),
                    DataCell(Text(member.role.name)),
                    DataCell(
                      Text(
                        member.status.name,
                        style: TextStyle(
                            color: member.status == StaffStatus.Active
                                ? Colors.green
                                : Colors.grey),
                      ),
                    ),
                    DataCell(Row(
                      children: [
                        IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showStaffDialog(context, ref,
                                staffMember: member)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => ref
                              .read(staffProvider.notifier)
                              .deleteStaffMember(member.id),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

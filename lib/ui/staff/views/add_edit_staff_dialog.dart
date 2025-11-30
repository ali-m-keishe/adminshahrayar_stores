import 'package:adminshahrayar_stores/data/models/staff_member.dart';
import 'package:flutter/material.dart';

class AddEditStaffDialog extends StatefulWidget {
  final StaffMember? staffMember;

  const AddEditStaffDialog({super.key, this.staffMember});

  @override
  State<AddEditStaffDialog> createState() => _AddEditStaffDialogState();
}

class _AddEditStaffDialogState extends State<AddEditStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late StaffRole _selectedRole;
  late StaffStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.staffMember?.name ?? '');
    _selectedRole = widget.staffMember?.role ?? StaffRole.Cashier;
    _selectedStatus = widget.staffMember?.status ?? StaffStatus.Active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // We are only returning the values, the notifier will create the full StaffMember object
      Navigator.of(context).pop({
        'name': _nameController.text,
        'role': _selectedRole,
        'status': _selectedStatus,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.staffMember == null
          ? 'Add Staff Member'
          : 'Edit Staff Member'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Full Name', border: OutlineInputBorder()),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<StaffRole>(
              value: _selectedRole,
              decoration: const InputDecoration(
                  labelText: 'Role', border: OutlineInputBorder()),
              items: StaffRole.values
                  .map((role) =>
                      DropdownMenuItem(value: role, child: Text(role.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedRole = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<StaffStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                  labelText: 'Status', border: OutlineInputBorder()),
              items: StaffStatus.values
                  .map((status) =>
                      DropdownMenuItem(value: status, child: Text(status.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedStatus = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        ElevatedButton(onPressed: _saveForm, child: const Text('Save')),
      ],
    );
  }
}

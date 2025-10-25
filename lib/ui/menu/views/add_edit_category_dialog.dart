// import 'package:flutter/material.dart';

// class AddEditCategoryDialog extends StatefulWidget {
//   final String? existingCategoryName;

//   const AddEditCategoryDialog({super.key, this.existingCategoryName});

//   @override
//   State<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
// }

// class _AddEditCategoryDialogState extends State<AddEditCategoryDialog> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _nameController;

//   @override
//   void initState() {
//     super.initState();
//     _nameController =
//         TextEditingController(text: widget.existingCategoryName ?? '');
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }

//   void _submit() {
//     if (_formKey.currentState!.validate()) {
//       Navigator.of(context).pop(_nameController.text);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.existingCategoryName != null;
//     return AlertDialog(
//       title: Text(isEditing ? 'Edit Category' : 'Add New Category'),
//       content: Form(
//         key: _formKey,
//         child: TextFormField(
//           controller: _nameController,
//           autofocus: true,
//           decoration: const InputDecoration(
//             labelText: 'Category Name',
//             border: OutlineInputBorder(),
//           ),
//           validator: (value) {
//             if (value == null || value.trim().isEmpty) {
//               return 'Please enter a category name.';
//             }
//             return null;
//           },
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: _submit,
//           child: Text(isEditing ? 'Save' : 'Add'),
//         ),
//       ],
//     );
//   }
// }




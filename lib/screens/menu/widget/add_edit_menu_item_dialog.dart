import 'package:adminshahrayar/models/menu_item.dart';
import 'package:flutter/material.dart';

// Note: This is a StatefulWidget because we need to manage the state of the form fields
// and their text controllers. This is a perfect use case for a StatefulWidget.
class AddEditMenuItemDialog extends StatefulWidget {
  // If menuItem is null, we are in 'Add' mode.
  // If it's provided, we are in 'Edit' mode.
  final MenuItem? menuItem;
  final List<String> categories;

  const AddEditMenuItemDialog(
      {super.key, this.menuItem, required this.categories});

  @override
  State<AddEditMenuItemDialog> createState() => _AddEditMenuItemDialogState();
}

class _AddEditMenuItemDialogState extends State<AddEditMenuItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Pre-fill the form fields if we are editing an existing item.
    _nameController = TextEditingController(text: widget.menuItem?.name ?? '');
    _priceController =
        TextEditingController(text: widget.menuItem?.price.toString() ?? '');
    _imageUrlController =
        TextEditingController(text: widget.menuItem?.imageUrl ?? '');

    // Set a default category if adding, or the item's category if editing.
    _selectedCategory = widget.menuItem?.category ??
        widget.categories.firstWhere((c) => c != 'All');
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is removed.
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _saveForm() {
    // Validate the form before proceeding.
    if (_formKey.currentState!.validate()) {
      final newMenuItem = MenuItem(
        name: _nameController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        category: _selectedCategory,
        imageUrl: _imageUrlController.text,
      );
      // Close the dialog and pass the created/updated item back.
      Navigator.of(context).pop(newMenuItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.menuItem == null ? 'Add New Item' : 'Edit Item'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Name', border: OutlineInputBorder()),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                      labelText: 'Price', border: OutlineInputBorder()),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                      labelText: 'Category', border: OutlineInputBorder()),
                  // We filter out 'All' since an item must belong to a specific category.
                  items: widget.categories
                      .where((c) => c != 'All')
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                      labelText: 'Image URL', border: OutlineInputBorder()),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an image URL' : null,
                ),
              ],
            ),
          ),
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

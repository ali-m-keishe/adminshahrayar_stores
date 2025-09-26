import 'package:adminshahrayar/models/promotion.dart';
import 'package:flutter/material.dart';

class AddEditPromotionDialog extends StatefulWidget {
  final Promotion? promotion;

  const AddEditPromotionDialog({super.key, this.promotion});

  @override
  State<AddEditPromotionDialog> createState() => _AddEditPromotionDialogState();
}

class _AddEditPromotionDialogState extends State<AddEditPromotionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  late TextEditingController _valueController;
  late DiscountType _selectedType;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.promotion?.code ?? '');
    _descriptionController =
        TextEditingController(text: widget.promotion?.description ?? '');
    _valueController = TextEditingController(
        text: widget.promotion?.discountValue.toString() ?? '');
    _selectedType = widget.promotion?.discountType ?? DiscountType.Percentage;
    _isActive = widget.promotion?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'code': _codeController.text,
        'description': _descriptionController.text,
        'discountType': _selectedType,
        'discountValue': double.tryParse(_valueController.text) ?? 0.0,
        'isActive': _isActive,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.promotion == null ? 'Add Promotion' : 'Edit Promotion'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                    labelText: 'Promo Code (e.g., SAVE20)',
                    border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a code' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Description', border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<DiscountType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                          labelText: 'Type', border: OutlineInputBorder()),
                      items: DiscountType.values
                          .map((type) => DropdownMenuItem(
                              value: type, child: Text(type.name)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedType = value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _valueController,
                      decoration: const InputDecoration(
                          labelText: 'Value', border: OutlineInputBorder()),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a value' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ],
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

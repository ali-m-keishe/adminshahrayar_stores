import 'package:adminshahrayar/data/models/promotion.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  late String _selectedType;
  late bool _isActive;
  late DateTime _startDate;
  late DateTime _endDate;

  final List<String> _typeOptions = ['Percentage', 'FixedAmount'];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.promotion?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.promotion?.description ?? '');
    _valueController = TextEditingController(
        text: widget.promotion?.discountValue.toString() ?? '');
    _isActive = widget.promotion?.isActive ?? true;

    String initialType = 'Percentage';
    if (widget.promotion != null) {
      initialType = _typeOptions.firstWhere(
        (opt) =>
            opt.toLowerCase() == widget.promotion!.discountType.toLowerCase(),
        orElse: () => 'Percentage',
      );
    }
    _selectedType = initialType;

    _startDate = widget.promotion?.startDate ?? DateTime.now();
    _endDate = widget.promotion?.endDate ??
        DateTime.now().add(const Duration(days: 30));
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
        'name': _codeController.text,
        'description': _descriptionController.text,
        'discount_type': _selectedType,
        'discount_value': double.tryParse(_valueController.text) ?? 0.0,
        'is_active': _isActive,
        'start_date': _startDate,
        'end_date': _endDate,
      });
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.promotion == null ? 'Add Promotion' : 'Edit Promotion'),
      content: SizedBox(
        width: 400, // Make the dialog wider to fit the date fields
        child: Form(
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
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                            labelText: 'Type', border: OutlineInputBorder()),
                        items: _typeOptions
                            .map((type) => DropdownMenuItem(
                                value: type, child: Text(type)))
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
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a value' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // vvv THIS IS THE NEW UI FOR DATE PICKERS vvv
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_month_outlined),
                          ),
                          child: Text(DateFormat.yMMMd().format(_startDate)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_month_outlined),
                          ),
                          child: Text(DateFormat.yMMMd().format(_endDate)),
                        ),
                      ),
                    ),
                  ],
                ),
                // ^^^ THIS IS THE NEW UI FOR DATE PICKERS ^^^

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

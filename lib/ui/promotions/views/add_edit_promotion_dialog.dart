import 'package:adminshahrayar_stores/data/models/menu_item.dart';
import 'package:adminshahrayar_stores/data/models/promotion.dart';
import 'package:adminshahrayar_stores/data/repositories/menu_repository.dart';
import 'package:adminshahrayar_stores/data/repositories/promotion_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final menuItemsProvider = FutureProvider<List<MenuItem>>((ref) {
  return ref.watch(menuRepositoryProvider).getAllMenuItems();
});

final promotionLinksProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(promotionRepositoryProvider).getAllPromotionItemLinks();
});

class AddEditPromotionDialog extends ConsumerStatefulWidget {
  final Promotion? promotion;
  const AddEditPromotionDialog({super.key, this.promotion});

  @override
  ConsumerState<AddEditPromotionDialog> createState() =>
      _AddEditPromotionDialogState();
}

class _AddEditPromotionDialogState
    extends ConsumerState<AddEditPromotionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  late TextEditingController _valueController;
  late String _selectedType;
  late bool _isActive;
  late DateTime _startDate;
  late DateTime _endDate;
  final Set<int> _selectedItemIds = {};
  final List<String> _typeOptions = ['percentage', 'fixedAmount'];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.promotion?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.promotion?.description ?? '');
    _valueController = TextEditingController(
        text: widget.promotion?.discountValue.toString() ?? '');
    _isActive = widget.promotion?.isActive ?? true;
    _selectedType =
        widget.promotion?.discountType.toLowerCase() ?? 'percentage';
    _startDate = widget.promotion?.startDate ?? DateTime.now();
    _endDate = widget.promotion?.endDate ??
        DateTime.now().add(const Duration(days: 30));

    if (widget.promotion?.items != null) {
      _selectedItemIds.addAll(widget.promotion!.items!.map((item) => item.id));
    }

    if (widget.promotion != null) {
      // For editing, find the matching option, ignoring case.
      _selectedType = _typeOptions.firstWhere(
        (opt) =>
            opt.toLowerCase() == widget.promotion!.discountType.toLowerCase(),
        orElse: () => _typeOptions.first, // Fallback to the first option
      );
    } else {
      // For adding, ALWAYS use the first item from our options list as the default.
      _selectedType = _typeOptions.first;
    }

    // Pre-select the items that are already linked
    if (widget.promotion?.items != null) {
      _selectedItemIds.addAll(widget.promotion!.items!.map((item) => item.id));
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedItemIds.isEmpty) {
        // If the checklist is empty, show a red error message.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one applicable menu item.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // IMPORTANT: This stops the function and keeps the dialog open.
      }

      Navigator.of(context).pop({
        'name': _codeController.text,
        'description': _descriptionController.text,
        'discount_type': _selectedType,
        'discount_value': double.tryParse(_valueController.text) ?? 0.0,
        'is_active': _isActive,
        'start_date': _startDate,
        'end_date': _endDate,
        'item_ids': _selectedItemIds.toList(),
      });
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100));
    if (pickedDate != null) {
      setState(() {
        if (isStartDate)
          _startDate = pickedDate;
        else
          _endDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItemsAsync = ref.watch(menuItemsProvider);
    final promotionLinksAsync = ref.watch(promotionLinksProvider);

    return AlertDialog(
      title:
          Text(widget.promotion == null ? 'Add Promotion' : 'Edit Promotion'),
      content: SizedBox(
        width: 450,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                        labelText: 'Promo Code', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                        labelText: 'Description', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                              labelText: 'Type', border: OutlineInputBorder()),
                          items: _typeOptions
                              .map((t) =>
                                  DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedType = v!))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: TextFormField(
                          controller: _valueController,
                          decoration: const InputDecoration(
                              labelText: 'Value', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Required' : null)),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: InkWell(
                          onTap: () => _pickDate(context, true),
                          child: InputDecorator(
                              decoration: const InputDecoration(
                                  labelText: 'Start Date',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_month)),
                              child: Text(
                                  DateFormat.yMMMd().format(_startDate))))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: InkWell(
                          onTap: () => _pickDate(context, false),
                          child: InputDecorator(
                              decoration: const InputDecoration(
                                  labelText: 'End Date',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_month)),
                              child:
                                  Text(DateFormat.yMMMd().format(_endDate))))),
                ]),
                const SizedBox(height: 16),
                SwitchListTile(
                    title: const Text('Active'),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    contentPadding: EdgeInsets.zero),
                const Divider(height: 32, thickness: 1),
                Text('Applicable Menu Items',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4)),
                  child: menuItemsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) =>
                        Center(child: Text('Could not load items: $e')),
                    data: (items) => promotionLinksAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) =>
                          Center(child: Text('Could not load links: $e')),
                      data: (links) => ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final link = links.firstWhere(
                              (link) => link['item_id'] == item.id,
                              orElse: () => {});
                          final isLinkedToAnotherPromo = link.isNotEmpty &&
                              link['promotion_id'] != widget.promotion?.id;
                          return CheckboxListTile(
                            title: Text(item.name),
                            subtitle: isLinkedToAnotherPromo
                                ? Text('(Already in another promotion)',
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12))
                                : null,
                            value: _selectedItemIds.contains(item.id),
                            onChanged: isLinkedToAnotherPromo
                                ? null
                                : (bool? selected) {
                                    setState(() {
                                      if (selected == true)
                                        _selectedItemIds.add(item.id);
                                      else
                                        _selectedItemIds.remove(item.id);
                                    });
                                  },
                          );
                        },
                      ),
                    ),
                  ),
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

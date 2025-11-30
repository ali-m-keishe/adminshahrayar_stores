import 'package:adminshahrayar_stores/data/models/currency.dart';
import 'package:adminshahrayar_stores/data/repositories/currency_repository.dart';
import 'package:flutter/material.dart';

class CurrencyManagementDialog extends StatefulWidget {
  const CurrencyManagementDialog({super.key});

  @override
  State<CurrencyManagementDialog> createState() =>
      _CurrencyManagementDialogState();
}

class _CurrencyManagementDialogState extends State<CurrencyManagementDialog> {
  final CurrencyRepository _repository = CurrencyRepository();
  List<Currency> _currencies = [];
  bool _isLoading = true;
  final Map<int, TextEditingController> _codeControllers = {};
  final Map<int, TextEditingController> _nameControllers = {};
  final Map<int, TextEditingController> _symbolControllers = {};
  final Map<int, bool> _isEditing = {};

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currencies = await _repository.getAllCurrencies();
      setState(() {
        _currencies = currencies;
        // Initialize controllers for each currency
        for (var currency in currencies) {
          _codeControllers[currency.id] =
              TextEditingController(text: currency.code);
          _nameControllers[currency.id] =
              TextEditingController(text: currency.name);
          _symbolControllers[currency.id] =
              TextEditingController(text: currency.symbol);
          _isEditing[currency.id] = false;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading currencies: $e')),
        );
      }
    }
  }

  void _toggleEdit(int currencyId) {
    setState(() {
      _isEditing[currencyId] = !_isEditing[currencyId]!;
      if (!_isEditing[currencyId]!) {
        // Cancel editing - reset to original values
        final currency = _currencies.firstWhere((c) => c.id == currencyId);
        _codeControllers[currencyId]!.text = currency.code;
        _nameControllers[currencyId]!.text = currency.name;
        _symbolControllers[currencyId]!.text = currency.symbol;
      }
    });
  }

  Future<void> _saveCurrency(int currencyId) async {
    final codeController = _codeControllers[currencyId];
    final nameController = _nameControllers[currencyId];
    final symbolController = _symbolControllers[currencyId];

    if (codeController == null || nameController == null || symbolController == null) return;

    final code = codeController.text.trim();
    final name = nameController.text.trim();
    final symbol = symbolController.text.trim();

    if (code.isEmpty || name.isEmpty || symbol.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code, name and symbol cannot be empty')),
      );
      return;
    }

    try {
      await _repository.updateCurrency(
        id: currencyId,
        code: code,
        name: name,
        symbol: symbol,
      );

      // Update the currency in the list
      setState(() {
        final index = _currencies.indexWhere((c) => c.id == currencyId);
        if (index != -1) {
          _currencies[index] = _currencies[index].copyWith(
            code: code,
            name: name,
            symbol: symbol,
          );
        }
        _isEditing[currencyId] = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Currency updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating currency: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _codeControllers.values) {
      controller.dispose();
    }
    for (var controller in _nameControllers.values) {
      controller.dispose();
    }
    for (var controller in _symbolControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Currency Management',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _currencies.isEmpty
                      ? const Center(child: Text('No currencies found'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _currencies.length,
                          itemBuilder: (context, index) {
                            final currency = _currencies[index];
                            final isEditing = _isEditing[currency.id] ?? false;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Default Badge
                                    if (currency.isDefault == true)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Chip(
                                          label: const Text('Default'),
                                          labelStyle: const TextStyle(
                                            fontSize: 10,
                                          ),
                                          padding: EdgeInsets.zero,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    // Code Field
                                    TextField(
                                      controller: _codeControllers[currency.id],
                                      enabled: isEditing,
                                      decoration: InputDecoration(
                                        labelText: 'Currency Code',
                                        hintText: 'ex: NIS',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Name Field
                                    TextField(
                                      controller: _nameControllers[currency.id],
                                      enabled: isEditing,
                                      decoration: InputDecoration(
                                        labelText: 'Currency Name',
                                        hintText: 'ex: Dollar',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Symbol Field
                                    TextField(
                                      controller:
                                          _symbolControllers[currency.id],
                                      enabled: isEditing,
                                      decoration: InputDecoration(
                                        labelText: 'Symbol',
                                        hintText: 'ex: \$',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Action Buttons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (isEditing) ...[
                                          TextButton(
                                            onPressed: () =>
                                                _toggleEdit(currency.id),
                                            child: const Text('Cancel'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () =>
                                                _saveCurrency(currency.id),
                                            child: const Text('Save'),
                                          ),
                                        ] else
                                          ElevatedButton.icon(
                                            onPressed: () =>
                                                _toggleEdit(currency.id),
                                            icon: const Icon(Icons.edit,
                                                size: 18),
                                            label: const Text('Edit'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}


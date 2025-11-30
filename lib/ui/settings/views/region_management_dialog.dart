import 'package:adminshahrayar_stores/data/models/region.dart';
import 'package:adminshahrayar_stores/data/repositories/region_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegionManagementDialog extends StatefulWidget {
  const RegionManagementDialog({super.key});

  @override
  State<RegionManagementDialog> createState() =>
      _RegionManagementDialogState();
}

class _RegionManagementDialogState extends State<RegionManagementDialog> {
  final RegionRepository _repository = RegionRepository();
  List<Region> _regions = [];
  bool _isLoading = true;
  final Map<int, TextEditingController> _nameControllers = {};
  final Map<int, TextEditingController> _deliveryFeeControllers = {};
  final Map<int, bool> _isEditing = {};

  // Controllers for adding new region
  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _newDeliveryFeeController = TextEditingController();
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final regions = await _repository.getAllRegions();
      setState(() {
        _regions = regions;
        // Initialize controllers for each region
        for (var region in regions) {
          _nameControllers[region.id] =
              TextEditingController(text: region.name);
          _deliveryFeeControllers[region.id] =
              TextEditingController(text: region.deliveryFee.toString());
          _isEditing[region.id] = false;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading regions: $e')),
        );
      }
    }
  }

  void _toggleEdit(int regionId) {
    setState(() {
      _isEditing[regionId] = !_isEditing[regionId]!;
      if (!_isEditing[regionId]!) {
        // Cancel editing - reset to original values
        final region = _regions.firstWhere((r) => r.id == regionId);
        _nameControllers[regionId]!.text = region.name;
        _deliveryFeeControllers[regionId]!.text = region.deliveryFee.toString();
      }
    });
  }

  void _toggleAdd() {
    setState(() {
      _isAdding = !_isAdding;
      if (!_isAdding) {
        // Clear form when canceling
        _newNameController.clear();
        _newDeliveryFeeController.clear();
      }
    });
  }

  Future<void> _saveRegion(int regionId) async {
    final nameController = _nameControllers[regionId];
    final deliveryFeeController = _deliveryFeeControllers[regionId];

    if (nameController == null || deliveryFeeController == null) return;

    final name = nameController.text.trim();
    final deliveryFeeText = deliveryFeeController.text.trim();

    if (name.isEmpty || deliveryFeeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and delivery fee cannot be empty')),
      );
      return;
    }

    final deliveryFee = int.tryParse(deliveryFeeText);
    if (deliveryFee == null || deliveryFee < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid delivery fee')),
      );
      return;
    }

    try {
      await _repository.updateRegion(
        id: regionId,
        name: name,
        deliveryFee: deliveryFee,
      );

      // Update the region in the list
      setState(() {
        final index = _regions.indexWhere((r) => r.id == regionId);
        if (index != -1) {
          _regions[index] = _regions[index].copyWith(
            name: name,
            deliveryFee: deliveryFee,
          );
        }
        _isEditing[regionId] = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Region updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating region: $e')),
        );
      }
    }
  }

  Future<void> _addNewRegion() async {
    final name = _newNameController.text.trim();
    final deliveryFeeText = _newDeliveryFeeController.text.trim();

    if (name.isEmpty || deliveryFeeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and delivery fee cannot be empty')),
      );
      return;
    }

    final deliveryFee = int.tryParse(deliveryFeeText);
    if (deliveryFee == null || deliveryFee < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid delivery fee')),
      );
      return;
    }

    try {
      final newRegion = await _repository.addRegion(
        name: name,
        deliveryFee: deliveryFee,
      );

      // Add to the list and initialize controllers
      setState(() {
        _regions.insert(0, newRegion);
        _nameControllers[newRegion.id] =
            TextEditingController(text: newRegion.name);
        _deliveryFeeControllers[newRegion.id] =
            TextEditingController(text: newRegion.deliveryFee.toString());
        _isEditing[newRegion.id] = false;
        _isAdding = false;
        _newNameController.clear();
        _newDeliveryFeeController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Region added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding region: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _nameControllers.values) {
      controller.dispose();
    }
    for (var controller in _deliveryFeeControllers.values) {
      controller.dispose();
    }
    _newNameController.dispose();
    _newDeliveryFeeController.dispose();
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
                    'Region Management',
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
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Add New Region Section
                          Card(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Add New Region',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isAdding
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                        ),
                                        onPressed: _toggleAdd,
                                      ),
                                    ],
                                  ),
                                  if (_isAdding) ...[
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _newNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Region Name',
                                        hintText: 'ex: West Bank',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _newDeliveryFeeController,
                                      decoration: InputDecoration(
                                        labelText: 'Delivery Fee',
                                        hintText: 'ex: 20',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                        border: const OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: _toggleAdd,
                                          child: const Text('Cancel'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: _addNewRegion,
                                          child: const Text('Add Region'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Existing Regions List
                          if (_regions.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text('No regions found'),
                              ),
                            )
                          else
                            ..._regions.map((region) {
                              final isEditing =
                                  _isEditing[region.id] ?? false;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Name Field
                                      TextField(
                                        controller:
                                            _nameControllers[region.id],
                                        enabled: isEditing,
                                        decoration: InputDecoration(
                                          labelText: 'Region Name',
                                          hintText: 'ex: West Bank',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                          border: const OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Delivery Fee Field
                                      TextField(
                                        controller: _deliveryFeeControllers[
                                            region.id],
                                        enabled: isEditing,
                                        decoration: InputDecoration(
                                          labelText: 'Delivery Fee',
                                          hintText: 'ex: 20',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                          border: const OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Action Buttons
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (isEditing) ...[
                                            TextButton(
                                              onPressed: () =>
                                                  _toggleEdit(region.id),
                                              child: const Text('Cancel'),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _saveRegion(region.id),
                                              child: const Text('Save'),
                                            ),
                                          ] else
                                            ElevatedButton.icon(
                                              onPressed: () =>
                                                  _toggleEdit(region.id),
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
                            }).toList(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


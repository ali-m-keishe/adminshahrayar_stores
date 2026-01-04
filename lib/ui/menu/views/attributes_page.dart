// lib/ui/menu/views/attributes_page.dart

import 'package:adminshahrayar_stores/data/models/attribute.dart';
import 'package:adminshahrayar_stores/data/models/attribute_value.dart';
import 'package:adminshahrayar_stores/main_screen.dart';
import 'package:adminshahrayar_stores/ui/menu/viewmodels/menu_viemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttributesPage extends ConsumerStatefulWidget {
  const AttributesPage({super.key});

  @override
  ConsumerState<AttributesPage> createState() => _AttributesPageState();
}

class _AttributesPageState extends ConsumerState<AttributesPage> {
  int? _lastSelectedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAttributes();
    });
  }

  void _loadAttributes() async {
    final viewModel = ref.read(menuViewModelProvider.notifier);
    await viewModel.refreshCategoriesAndAttributes();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the main screen index to detect when this page becomes visible
    final currentIndex = ref.watch(mainScreenIndexProvider);
    const attributesPageIndex = 11; // Index of attributes page

    // Refresh when navigating to this page
    if (currentIndex == attributesPageIndex && _lastSelectedIndex != attributesPageIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAttributes();
      });
    }
    _lastSelectedIndex = currentIndex;

    final menuState = ref.watch(menuViewModelProvider);

    return menuState.when(
      data: (state) {
        final attributes = state.attributes;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Attributes Management'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddEditAttributeDialog(context),
                tooltip: 'Add Attribute',
              ),
            ],
          ),
          body: attributes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No attributes yet',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditAttributeDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Attribute'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: attributes.length,
                  itemBuilder: (context, index) {
                    final attribute = attributes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: Icon(
                          attribute.type == 'single' ? Icons.radio_button_checked : Icons.check_box,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          attribute.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Type: ${attribute.type}'),
                            Text('Required: ${attribute.isRequired ? "Yes" : "No"}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddEditAttributeDialog(context, attribute: attribute),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteAttributeDialog(context, attribute),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Attribute Values',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _showAddEditAttributeValueDialog(context, attribute),
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Add Value'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                FutureBuilder<List<AttributeValue>>(
                                  future: ref.read(menuViewModelProvider.notifier).getAttributeValues(attribute.id),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }
                                    final values = snapshot.data ?? [];
                                    if (values.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text('No values added yet'),
                                      );
                                    }
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: values.length,
                                      itemBuilder: (context, idx) {
                                        final value = values[idx];
                                        return ListTile(
                                          leading: const Icon(Icons.circle, size: 8),
                                          title: Text(value.name),
                                          subtitle: Text('Price: \$${value.price.toStringAsFixed(2)}'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                                onPressed: () => _showAddEditAttributeValueDialog(context, attribute, value: value),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                                onPressed: () => _showDeleteAttributeValueDialog(context, value),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
          ],
        ),
      ),
    );
  }

  void _showAddEditAttributeDialog(BuildContext context, {Attribute? attribute}) async {
    final isEditing = attribute != null;
    final nameController = TextEditingController(text: attribute?.name ?? '');
    String selectedType = attribute?.type ?? 'single';
    bool isRequired = attribute?.isRequired ?? false;
    
    // Load existing attribute values if editing
    List<AttributeValue> attributeValues = [];
    if (isEditing) {
      final viewModel = ref.read(menuViewModelProvider.notifier);
      attributeValues = await viewModel.getAttributeValues(attribute.id);
    }
    
    // Temporary list for new/edited values (for new attributes or when adding new values)
    final tempValues = <Map<String, dynamic>>[];
    // Convert existing values to temp format
    for (var value in attributeValues) {
      tempValues.add({
        'id': value.id,
        'name': value.name,
        'price': value.price,
        'isNew': false,
      });
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey.shade900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            isEditing ? 'Edit Attribute' : 'Add Attribute',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Attribute Name',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  dropdownColor: Colors.grey.shade800,
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'single', child: Text('Single')),
                    DropdownMenuItem(value: 'multiple', child: Text('Multiple')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Required', style: TextStyle(color: Colors.white)),
                  value: isRequired,
                  onChanged: (value) {
                    setState(() {
                      isRequired = value ?? false;
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Attribute Values',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () {
                        _showAddValueDialogInAttribute(context, setState, tempValues);
                      },
                      tooltip: 'Add Value',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (tempValues.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No values added. Click + to add values.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  )
                else
                  ...tempValues.asMap().entries.map((entry) {
                    final index = entry.key;
                    final value = entry.value;
                    return Card(
                      color: Colors.grey.shade800,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          value['name'] ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Price: \$${(value['price'] ?? 0.0).toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                          onPressed: () {
                            setState(() {
                              tempValues.removeAt(index);
                            });
                          },
                        ),
                        onTap: () {
                          _showEditValueDialogInAttribute(context, setState, tempValues, index);
                        },
                      ),
                    );
                  }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter an attribute name'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final viewModel = ref.read(menuViewModelProvider.notifier);
                final newAttribute = Attribute(
                  id: isEditing ? attribute.id : 0,
                  name: name,
                  type: selectedType,
                  isRequired: isRequired,
                  createdAt: isEditing ? attribute.createdAt : DateTime.now(),
                );

                try {
                  if (isEditing) {
                    await viewModel.updateAttribute(newAttribute);
                    
                    // Find values that were deleted (exist in attributeValues but not in tempValues)
                    final existingValueIds = tempValues
                        .where((v) => v['isNew'] != true)
                        .map((v) => v['id'] as int)
                        .toSet();
                    final valuesToDelete = attributeValues
                        .where((v) => !existingValueIds.contains(v.id))
                        .toList();
                    
                    // Delete removed values
                    for (var valueToDelete in valuesToDelete) {
                      await viewModel.deleteAttributeValue(valueToDelete.id);
                    }
                    
                    // Update existing values and add new ones
                    for (var valueData in tempValues) {
                      if (valueData['isNew'] == true) {
                        // Add new value
                        await viewModel.addAttributeValue(AttributeValue(
                          id: 0,
                          attributeId: attribute.id,
                          name: valueData['name'] ?? '',
                          price: (valueData['price'] ?? 0.0).toDouble(),
                          createdAt: DateTime.now(),
                        ));
                      } else {
                        // Update existing value
                        await viewModel.updateAttributeValue(AttributeValue(
                          id: valueData['id'] as int,
                          attributeId: attribute.id,
                          name: valueData['name'] ?? '',
                          price: (valueData['price'] ?? 0.0).toDouble(),
                          createdAt: DateTime.now(),
                        ));
                      }
                    }
                  } else {
                    // Add new attribute first and get the created attribute with ID
                    final createdAttribute = await viewModel.addAttribute(newAttribute);
                    
                    // Add all values
                    for (var valueData in tempValues) {
                      await viewModel.addAttributeValue(AttributeValue(
                        id: 0,
                        attributeId: createdAttribute.id,
                        name: valueData['name'] ?? '',
                        price: (valueData['price'] ?? 0.0).toDouble(),
                        createdAt: DateTime.now(),
                      ));
                    }
                  }
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadAttributes();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddValueDialogInAttribute(
    BuildContext context,
    StateSetter setState,
    List<Map<String, dynamic>> tempValues,
  ) {
    final nameController = TextEditingController();
    final priceController = TextEditingController(text: '0.0');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Add Value', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Value Name',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0.0;
              
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a value name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              setState(() {
                tempValues.add({
                  'id': 0,
                  'name': name,
                  'price': price,
                  'isNew': true,
                });
              });
              
              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditValueDialogInAttribute(
    BuildContext context,
    StateSetter setState,
    List<Map<String, dynamic>> tempValues,
    int index,
  ) {
    final value = tempValues[index];
    final nameController = TextEditingController(text: value['name'] ?? '');
    final priceController = TextEditingController(text: (value['price'] ?? 0.0).toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Edit Value', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Value Name',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0.0;
              
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a value name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              setState(() {
                tempValues[index] = {
                  'id': value['id'],
                  'name': name,
                  'price': price,
                  'isNew': value['isNew'] ?? false,
                };
              });
              
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAttributeDialog(BuildContext context, Attribute attribute) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Delete Attribute', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${attribute.name}"? This will also delete all its values.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final viewModel = ref.read(menuViewModelProvider.notifier);
              try {
                await viewModel.deleteAttribute(attribute.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadAttributes();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddEditAttributeValueDialog(
    BuildContext context,
    Attribute attribute, {
    AttributeValue? value,
  }) {
    final isEditing = value != null;
    final nameController = TextEditingController(text: value?.name ?? '');
    final priceController = TextEditingController(
      text: value?.price.toString() ?? '0.0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          isEditing ? 'Edit Attribute Value' : 'Add Attribute Value',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'For: ${attribute.name}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Value Name',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0.0;

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a value name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final viewModel = ref.read(menuViewModelProvider.notifier);
              final newValue = AttributeValue(
                id: isEditing ? value.id : 0,
                attributeId: attribute.id,
                name: name,
                price: price,
                createdAt: isEditing ? value.createdAt : DateTime.now(),
              );

              try {
                if (isEditing) {
                  await viewModel.updateAttributeValue(newValue);
                } else {
                  await viewModel.addAttributeValue(newValue);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadAttributes();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAttributeValueDialog(BuildContext context, AttributeValue value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Delete Attribute Value', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${value.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final viewModel = ref.read(menuViewModelProvider.notifier);
              try {
                await viewModel.deleteAttributeValue(value.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadAttributes();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}


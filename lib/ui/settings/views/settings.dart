import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'currency_management_dialog.dart';
import 'region_management_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
              maxWidth: 900), // Keeps content from getting too wide
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Branch Management Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Branch Management',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Main Street Cafe'),
                        subtitle:
                            Text('123 Main St, Anytown | Open: 9am - 10pm'),
                      ),
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Downtown Grill'),
                        subtitle: Text(
                            '456 Downtown Ave, Anytown | Open: 11am - 11pm'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Add/Edit Branches'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Currency Management Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Currency Management',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      const Text(
                        'Manage your currencies. Edit the name and symbol for each currency.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                const CurrencyManagementDialog(),
                          );
                        },
                        icon: const Icon(Icons.currency_exchange),
                        label: const Text('Set Currency'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Region Management Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Region Management',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      const Text(
                        'Manage your delivery regions. View, edit, and add new regions.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                const RegionManagementDialog(),
                          );
                        },
                        icon: const Icon(Icons.location_on),
                        label: const Text('Add Regions'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Pickup & Delivery Rules Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pickup & Delivery Rules',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 24),
                        // Using a GridView for a responsive form layout
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 4,
                          ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            final fields = [
                              const _SettingsTextField(
                                  label: 'Min. Order for Delivery (\$)',
                                  initialValue: '15'),
                              const _SettingsTextField(
                                  label: 'Delivery Fee (\$)',
                                  initialValue: '5'),
                              const _SettingsTextField(
                                  label: 'Free Delivery Above (\$)',
                                  initialValue: '50'),
                              const _SettingsTextField(
                                  label: 'Avg. Prep Time (min)',
                                  initialValue: '20'),
                            ];
                            return fields[index];
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Save logic will go here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Settings saved!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary),
                    child: const Text('Save Changes'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// A reusable text field widget for our settings form to reduce duplicate code
class _SettingsTextField extends StatelessWidget {
  final String label;
  final String initialValue;

  const _SettingsTextField({required this.label, required this.initialValue});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
    );
  }
}

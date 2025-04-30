import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_bloc.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_event.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';
import 'package:uuid/uuid.dart';

class AddMaterialPage extends StatefulWidget {
  const AddMaterialPage({super.key});

  @override
  State<AddMaterialPage> createState() => _AddMaterialPageState();
}

class _AddMaterialPageState extends State<AddMaterialPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _minimumStockController = TextEditingController();
  String _selectedUnitType = 'kg';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _unitCostController.dispose();
    _currentStockController.dispose();
    _minimumStockController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final material = MaterialModel(
        id: const Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text,
        unitCost: double.parse(_unitCostController.text),
        unitType: _selectedUnitType,
        currentStock: double.parse(_currentStockController.text),
        minimumStock: double.parse(_minimumStockController.text),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<MaterialsBloc>().add(AddMaterialEvent(material));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Material')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitCostController,
                decoration: const InputDecoration(
                  labelText: 'Unit Cost',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter unit cost';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedUnitType,
                decoration: const InputDecoration(
                  labelText: 'Unit Type',
                  prefixIcon: Icon(Icons.straighten),
                ),
                items: const [
                  DropdownMenuItem(value: 'kg', child: Text('Kilogram (kg)')),
                  DropdownMenuItem(value: 'g', child: Text('Gram (g)')),
                  DropdownMenuItem(value: 'l', child: Text('Liter (l)')),
                  DropdownMenuItem(value: 'ml', child: Text('Milliliter (ml)')),
                  DropdownMenuItem(value: 'pcs', child: Text('Pieces (pcs)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedUnitType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentStockController,
                decoration: const InputDecoration(
                  labelText: 'Current Stock',
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current stock';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minimumStockController,
                decoration: const InputDecoration(
                  labelText: 'Minimum Stock',
                  prefixIcon: Icon(Icons.warning),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter minimum stock';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Material'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

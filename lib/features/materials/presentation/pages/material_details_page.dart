import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_bloc.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_event.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';
import 'package:intl/intl.dart';

class MaterialDetailsPage extends StatefulWidget {
  final MaterialModel material;

  const MaterialDetailsPage({super.key, required this.material});

  @override
  State<MaterialDetailsPage> createState() => _MaterialDetailsPageState();
}

class _MaterialDetailsPageState extends State<MaterialDetailsPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _unitCostController;
  late final TextEditingController _currentStockController;
  late final TextEditingController _minimumStockController;
  late String _selectedUnitType;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.material.name);
    _descriptionController = TextEditingController(
      text: widget.material.description,
    );
    _unitCostController = TextEditingController(
      text: widget.material.unitCost.toString(),
    );
    _currentStockController = TextEditingController(
      text: widget.material.currentStock.toString(),
    );
    _minimumStockController = TextEditingController(
      text: widget.material.minimumStock.toString(),
    );
    _selectedUnitType = widget.material.unitType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _unitCostController.dispose();
    _currentStockController.dispose();
    _minimumStockController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    final updatedMaterial = widget.material.copyWith(
      name: _nameController.text,
      description: _descriptionController.text,
      unitCost: double.parse(_unitCostController.text),
      unitType: _selectedUnitType,
      currentStock: double.parse(_currentStockController.text),
      minimumStock: double.parse(_minimumStockController.text),
      updatedAt: DateTime.now(),
    );

    context.read<MaterialsBloc>().add(UpdateMaterialEvent(updatedMaterial));
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.material.name),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveChanges : _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.inventory),
              ),
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _unitCostController,
              decoration: const InputDecoration(
                labelText: 'Unit Cost',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              enabled: _isEditing,
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
              onChanged: _isEditing
                  ? (value) {
                      if (value != null) {
                        setState(() {
                          _selectedUnitType = value;
                        });
                      }
                    }
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentStockController,
              decoration: const InputDecoration(
                labelText: 'Current Stock',
                prefixIcon: Icon(Icons.inventory_2),
              ),
              keyboardType: TextInputType.number,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minimumStockController,
              decoration: const InputDecoration(
                labelText: 'Minimum Stock',
                prefixIcon: Icon(Icons.warning),
              ),
              keyboardType: TextInputType.number,
              enabled: _isEditing,
            ),
            const SizedBox(height: 24),
            if (!_isEditing) ...[
              const Text(
                'Material Statistics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Created At'),
                        subtitle: Text(widget.material.createdAt.toString()),
                      ),
                      ListTile(
                        leading: const Icon(Icons.update),
                        title: const Text('Last Updated'),
                        subtitle: Text(widget.material.updatedAt.toString()),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.warning,
                          color: widget.material.currentStock <=
                                  widget.material.minimumStock
                              ? Colors.orange
                              : Colors.green,
                        ),
                        title: const Text('Stock Status'),
                        subtitle: Text(
                          widget.material.currentStock <=
                                  widget.material.minimumStock
                              ? 'Low Stock Alert'
                              : 'Stock Level Normal',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

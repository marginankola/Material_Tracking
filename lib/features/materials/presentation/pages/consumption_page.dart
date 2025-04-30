import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_tracking/features/materials/domain/models/consumption_model.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_bloc.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_event.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_state.dart';
import 'package:uuid/uuid.dart';

class ConsumptionPage extends StatefulWidget {
  const ConsumptionPage({super.key});

  @override
  State<ConsumptionPage> createState() => _ConsumptionPageState();
}

class _ConsumptionPageState extends State<ConsumptionPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMaterialId;
  final _quantityController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _batchNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final consumption = ConsumptionModel(
        id: const Uuid().v4(),
        materialId: _selectedMaterialId!,
        quantity: double.parse(_quantityController.text),
        batchNumber: _batchNumberController.text,
        notes: _notesController.text,
        operatorId: 'current_user_id', // TODO: Get from auth bloc
        createdAt: DateTime.now(),
        consumedAt: DateTime.now(),
      );

      context.read<MaterialsBloc>().add(AddConsumptionEvent(consumption));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Consumption'),
      ),
      body: BlocBuilder<MaterialsBloc, MaterialsState>(
        builder: (context, state) {
          if (state is MaterialsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MaterialsError) {
            return Center(child: Text(state.message));
          }

          if (state is! MaterialsLoaded) {
            return const Center(child: Text('Unexpected state'));
          }

          final materials = state.materials;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedMaterialId,
                    decoration: const InputDecoration(
                      labelText: 'Material',
                      border: OutlineInputBorder(),
                    ),
                    items: materials.map((material) {
                      return DropdownMenuItem<String>(
                        value: material.id,
                        child: Text(material.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMaterialId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a material';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _batchNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Batch Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter batch number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Record Consumption'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

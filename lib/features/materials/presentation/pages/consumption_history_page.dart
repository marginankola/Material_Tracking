import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_bloc.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_state.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';
import 'package:material_tracking/features/materials/domain/models/consumption_model.dart';
import 'package:intl/intl.dart';

class ConsumptionHistoryPage extends StatefulWidget {
  const ConsumptionHistoryPage({super.key});

  @override
  State<ConsumptionHistoryPage> createState() => _ConsumptionHistoryPageState();
}

class _ConsumptionHistoryPageState extends State<ConsumptionHistoryPage> {
  DateTimeRange? _selectedDateRange;
  String? _selectedMaterialId;
  String? _selectedOperatorId;

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consumption History')),
      body: BlocBuilder<MaterialsBloc, MaterialsState>(
        builder: (context, state) {
          if (state is! MaterialsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          List<ConsumptionModel> filteredConsumptions = state.consumptions;

          // Apply filters
          if (_selectedDateRange != null) {
            filteredConsumptions = filteredConsumptions.where((c) {
              return c.consumedAt.isAfter(_selectedDateRange!.start) &&
                  c.consumedAt.isBefore(_selectedDateRange!.end);
            }).toList();
          }

          if (_selectedMaterialId != null) {
            filteredConsumptions = filteredConsumptions
                .where((c) => c.materialId == _selectedMaterialId)
                .toList();
          }

          if (_selectedOperatorId != null) {
            filteredConsumptions = filteredConsumptions
                .where((c) => c.operatorId == _selectedOperatorId)
                .toList();
          }

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.date_range),
                        title: const Text('Date Range'),
                        subtitle: Text(
                          _selectedDateRange != null
                              ? '${DateFormat('MMM d, y').format(_selectedDateRange!.start)} - ${DateFormat('MMM d, y').format(_selectedDateRange!.end)}'
                              : 'Select Date Range',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDateRange(context),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedMaterialId,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Material',
                          prefixIcon: Icon(Icons.inventory),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Materials'),
                          ),
                          ...state.materials.map((material) {
                            return DropdownMenuItem(
                              value: material.id,
                              child: Text(material.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedMaterialId = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredConsumptions.length,
                  itemBuilder: (context, index) {
                    final consumption = filteredConsumptions[index];
                    final material = state.materials.firstWhere(
                      (m) => m.id == consumption.materialId,
                      orElse: () => MaterialModel(
                        id: 'unknown',
                        name: 'Unknown Material',
                        description: '',
                        unitCost: 0,
                        unitType: '',
                        currentStock: 0,
                        minimumStock: 0,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.history)),
                        title: Text(material.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quantity: ${consumption.quantity} ${material.unitType}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Batch: ${consumption.batchNumber}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (consumption.notes?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 4),
                              Text(
                                consumption.notes ?? '',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat(
                                'MMM d, y',
                              ).format(consumption.consumedAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              DateFormat(
                                'h:mm a',
                              ).format(consumption.consumedAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/consumption-details',
                            arguments: consumption,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

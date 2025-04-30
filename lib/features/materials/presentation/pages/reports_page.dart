import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_tracking/core/services/export_service.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';
import 'package:material_tracking/features/materials/domain/models/consumption_model.dart';
import 'package:material_tracking/features/materials/domain/models/product_model.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_bloc.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_state.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ExportService _exportService = ExportService();
  DateTimeRange? _selectedDateRange;

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

  Future<void> _exportMaterialsToExcel(List<MaterialModel> materials) async {
    try {
      final file = await _exportService.exportMaterialsToExcel(materials);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Materials exported to ${file.path}'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () {
                // TODO: Implement file opening
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting materials: $e')),
        );
      }
    }
  }

  Future<void> _exportConsumptionsToExcel(
    List<ConsumptionModel> consumptions,
  ) async {
    try {
      final file = await _exportService.exportConsumptionsToExcel(consumptions);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Consumptions exported to ${file.path}'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () {
                // TODO: Implement file opening
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting consumptions: $e')),
        );
      }
    }
  }

  Future<void> _exportProductCostingReport(
    ProductModel product,
    List<MaterialModel> materials,
    List<ConsumptionModel> consumptions,
  ) async {
    try {
      final file = await _exportService.exportProductCostingReport(
        product,
        materials,
        consumptions,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product costing report exported to ${file.path}'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () {
                // TODO: Implement file opening
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting product costing report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: BlocBuilder<MaterialsBloc, MaterialsState>(
        builder: (context, state) {
          if (state is! MaterialsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date Range',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.date_range),
                          title: const Text('Select Date Range'),
                          subtitle: Text(
                            _selectedDateRange != null
                                ? '${DateFormat('MMM d, y').format(_selectedDateRange!.start)} - ${DateFormat('MMM d, y').format(_selectedDateRange!.end)}'
                                : 'No date range selected',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDateRange(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Export Reports',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.inventory),
                          title: const Text('Export Materials'),
                          subtitle: const Text('Export all materials to Excel'),
                          trailing: IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () =>
                                _exportMaterialsToExcel(state.materials),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.history),
                          title: const Text('Export Consumptions'),
                          subtitle: const Text(
                            'Export consumption history to Excel',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () => _exportConsumptionsToExcel(
                              state.consumptions,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Product Costing Reports',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...state.products.map((product) {
                          return ListTile(
                            leading: const Icon(Icons.analytics),
                            title: Text(product.name),
                            subtitle: Text(
                              'Manufacturing Cost: \$${product.manufacturingCost.toStringAsFixed(2)}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () => _exportProductCostingReport(
                                product,
                                state.materials,
                                state.consumptions,
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
          );
        },
      ),
    );
  }
}

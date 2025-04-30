import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_bloc.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_state.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';
import 'package:material_tracking/features/materials/domain/models/consumption_model.dart';
import 'package:intl/intl.dart';

class ConsumptionDetailsPage extends StatelessWidget {
  final ConsumptionModel consumption;

  const ConsumptionDetailsPage({super.key, required this.consumption});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consumption Details')),
      body: BlocBuilder<MaterialsBloc, MaterialsState>(
        builder: (context, state) {
          if (state is! MaterialsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

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
                          'Material Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.inventory),
                          title: const Text('Material Name'),
                          subtitle: Text(material.name),
                        ),
                        ListTile(
                          leading: const Icon(Icons.description),
                          title: const Text('Description'),
                          subtitle: Text(material.description),
                        ),
                        ListTile(
                          leading: const Icon(Icons.attach_money),
                          title: const Text('Unit Cost'),
                          subtitle: Text(
                            '\$${material.unitCost.toStringAsFixed(2)} per ${material.unitType}',
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
                          'Consumption Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.scale),
                          title: const Text('Quantity Consumed'),
                          subtitle: Text(
                            '${consumption.quantity} ${material.unitType}',
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.money),
                          title: const Text('Total Cost'),
                          subtitle: Text(
                            '\$${(material.unitCost * consumption.quantity).toStringAsFixed(2)}',
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.batch_prediction),
                          title: const Text('Batch Number'),
                          subtitle: Text(consumption.batchNumber),
                        ),
                        if (consumption.notes?.isNotEmpty ?? false)
                          ListTile(
                            leading: const Icon(Icons.note),
                            title: const Text('Notes'),
                            subtitle: Text(consumption.notes ?? ''),
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
                          'Timestamps',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Consumed At'),
                          subtitle: Text(
                            DateFormat(
                              'MMM d, y h:mm a',
                            ).format(consumption.consumedAt),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.create),
                          title: const Text('Record Created At'),
                          subtitle: Text(
                            DateFormat(
                              'MMM d, y h:mm a',
                            ).format(consumption.createdAt),
                          ),
                        ),
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

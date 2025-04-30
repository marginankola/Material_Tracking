import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/models/consumption_model.dart';
import '../../domain/models/material_model.dart';
import '../bloc/materials_bloc.dart';
import '../bloc/materials_state.dart';

class ConsumptionDetailsPage extends StatelessWidget {
  final ConsumptionModel consumption;

  const ConsumptionDetailsPage({super.key, required this.consumption});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consumption Details'),
      ),
      body: BlocBuilder<MaterialsBloc, MaterialsState>(
        builder: (context, state) {
          if (state is MaterialsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final material = state is MaterialsLoaded
              ? state.materials
                  .firstWhere((m) => m.id == consumption.materialId)
              : null;

          if (material == null) {
            return const Center(child: Text('Material not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Material Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('Name'),
                          subtitle: Text(material.name),
                        ),
                        ListTile(
                          title: const Text('Description'),
                          subtitle: Text(material.description),
                        ),
                        ListTile(
                          title: const Text('Unit Cost'),
                          subtitle: Text(
                            NumberFormat.currency(
                              symbol: '₹',
                              decimalDigits: 2,
                            ).format(material.unitCost),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consumption Details',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('Quantity Consumed'),
                          subtitle: Text(
                            '${consumption.quantity} ${material.unitType}',
                          ),
                        ),
                        ListTile(
                          title: const Text('Total Cost'),
                          subtitle: Text(
                            NumberFormat.currency(
                              symbol: '₹',
                              decimalDigits: 2,
                            ).format(consumption.quantity * material.unitCost),
                          ),
                        ),
                        if (consumption.batchNumber != null)
                          ListTile(
                            title: const Text('Batch Number'),
                            subtitle: Text(consumption.batchNumber!),
                          ),
                        if (consumption.notes != null)
                          ListTile(
                            title: const Text('Notes'),
                            subtitle: Text(consumption.notes!),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Timestamps',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('Consumed At'),
                          subtitle: Text(
                            DateFormat('dd MMM yyyy, hh:mm a')
                                .format(consumption.consumedAt),
                          ),
                        ),
                        ListTile(
                          title: const Text('Record Created At'),
                          subtitle: Text(
                            DateFormat('dd MMM yyyy, hh:mm a')
                                .format(consumption.createdAt),
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

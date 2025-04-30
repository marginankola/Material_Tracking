import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';
import 'package:material_tracking/features/materials/domain/models/consumption_model.dart';

class RecentConsumptions extends StatelessWidget {
  final List<ConsumptionModel> consumptions;
  final List<MaterialModel> materials;

  const RecentConsumptions({
    super.key,
    required this.consumptions,
    required this.materials,
  });

  @override
  Widget build(BuildContext context) {
    if (consumptions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No recent consumptions'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: consumptions.length,
      itemBuilder: (context, index) {
        final consumption = consumptions[index];
        final material = materials.firstWhere(
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
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.history)),
            title: Text(material.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quantity: ${consumption.quantity} ${material.unitType}'),
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
                  DateFormat('MMM d, y').format(consumption.consumedAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  DateFormat('h:mm a').format(consumption.consumedAt),
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
    );
  }
}

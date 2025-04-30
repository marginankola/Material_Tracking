import 'package:flutter/material.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';

class LowStockAlert extends StatelessWidget {
  final List<MaterialModel> materials;

  const LowStockAlert({super.key, required this.materials});

  @override
  Widget build(BuildContext context) {
    final lowStockMaterials =
        materials.where((m) => m.currentStock <= m.minimumStock).toList();

    if (lowStockMaterials.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No materials with low stock'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lowStockMaterials.length,
      itemBuilder: (context, index) {
        final material = lowStockMaterials[index];
        final stockPercentage = material.currentStock / material.minimumStock;

        return Card(
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.orange),
            title: Text(material.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Stock: ${material.currentStock} ${material.unitType}',
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: stockPercentage.clamp(0, 1),
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.orange,
                  ),
                ),
              ],
            ),
            trailing: Text(
              '${(stockPercentage * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/material-details',
                arguments: material,
              );
            },
          ),
        );
      },
    );
  }
}

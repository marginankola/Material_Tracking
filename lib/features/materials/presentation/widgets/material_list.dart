import 'package:flutter/material.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';

class MaterialList extends StatelessWidget {
  final List<MaterialModel> materials;
  final void Function(MaterialModel)? onTap;

  const MaterialList({super.key, required this.materials, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (materials.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No materials available'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final material = materials[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.inventory),
            title: Text(material.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material.description),
                const SizedBox(height: 4),
                Text(
                  'Stock: ${material.currentStock} ${material.unitType}',
                  style: TextStyle(
                    color:
                        material.currentStock <= material.minimumStock
                            ? Colors.orange
                            : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${material.unitCost.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'per ${material.unitType}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            onTap: onTap != null ? () => onTap!(material) : null,
          ),
        );
      },
    );
  }
}

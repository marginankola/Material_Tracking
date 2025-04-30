import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/models/product_model.dart';
import '../bloc/products_bloc.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _basePriceController;
  final Map<String, TextEditingController> _materialQuantityControllers = {};
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _basePriceController = TextEditingController(
      text: widget.product.basePrice.toStringAsFixed(2),
    );
    for (var entry in widget.product.materialQuantities.entries) {
      _materialQuantityControllers[entry.key] =
          TextEditingController(text: entry.value.toString());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    for (var controller in _materialQuantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset controllers if canceling edit
        _nameController.text = widget.product.name;
        _descriptionController.text = widget.product.description;
        _basePriceController.text = widget.product.basePrice.toStringAsFixed(2);
        _materialQuantityControllers.clear();
        for (var entry in widget.product.materialQuantities.entries) {
          _materialQuantityControllers[entry.key] =
              TextEditingController(text: entry.value.toString());
        }
      }
    });
  }

  void _saveChanges() {
    final updatedProduct = widget.product.copyWith(
      name: _nameController.text,
      description: _descriptionController.text,
      basePrice: double.parse(_basePriceController.text),
      materialQuantities: _materialQuantityControllers.map(
        (key, controller) => MapEntry(key, double.parse(controller.text)),
      ),
      updatedAt: DateTime.now(),
    );

    context.read<ProductsBloc>().add(UpdateProductEvent(updatedProduct));
    _toggleEdit();
  }

  void _addMaterialQuantityField(String materialId) {
    setState(() {
      _materialQuantityControllers[materialId] = TextEditingController();
    });
  }

  void _removeMaterialQuantityField(String materialId) {
    setState(() {
      _materialQuantityControllers[materialId]?.dispose();
      _materialQuantityControllers.remove(materialId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Product Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveChanges : _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isEditing) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _basePriceController,
                        decoration: const InputDecoration(
                          labelText: 'Base Price',
                          border: OutlineInputBorder(),
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ] else ...[
                      Text(
                        widget.product.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        widget.product.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Base Price: \$${widget.product.basePrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Material Quantities',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16.0),
                    if (_isEditing) ...[
                      ..._materialQuantityControllers.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: entry.value,
                                  decoration: InputDecoration(
                                    labelText: 'Quantity for ${entry.key}',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () =>
                                    _removeMaterialQuantityField(entry.key),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Show material selection dialog
                          _addMaterialQuantityField('material_id');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Material'),
                      ),
                    ] else ...[
                      ...widget.product.materialQuantities.entries.map(
                        (entry) => ListTile(
                          title: Text('Material ID: ${entry.key}'),
                          subtitle: Text('Quantity: ${entry.value}'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16.0),
                    ListTile(
                      title: const Text('Created'),
                      subtitle: Text(
                        DateFormat.yMMMd()
                            .add_jm()
                            .format(widget.product.createdAt),
                      ),
                    ),
                    ListTile(
                      title: const Text('Last Updated'),
                      subtitle: Text(
                        DateFormat.yMMMd()
                            .add_jm()
                            .format(widget.product.updatedAt),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

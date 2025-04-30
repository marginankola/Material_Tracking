import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';
import 'package:material_tracking/features/materials/domain/models/consumption_model.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_bloc.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_event.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_state.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final _quantityController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _notesController = TextEditingController();
  MaterialModel? _scannedMaterial;
  final _scannerKey = GlobalKey<MobileScannerState>();

  @override
  void dispose() {
    _quantityController.dispose();
    _batchNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onScanResult(BarcodeCapture barcode) {
    final code = barcode.barcodes.first;
    if (code.rawValue == null) return;

    final materialId = code.rawValue!;
    final materialsBloc = context.read<MaterialsBloc>();
    final materials = materialsBloc.state.materials;

    final material = materials.firstWhere(
      (m) => m.id == materialId,
      orElse: () => null,
    );

    if (material != null) {
      setState(() {
        _scannedMaterial = material;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Material not found'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _consumeMaterial() {
    if (_scannedMaterial == null) return;

    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final consumption = ConsumptionModel(
      id: const Uuid().v4(),
      materialId: _scannedMaterial!.id,
      quantity: quantity,
      batchNumber: _batchNumberController.text,
      notes: _notesController.text,
      createdAt: DateTime.now(),
    );

    context.read<MaterialsBloc>().add(
          AddConsumptionEvent(consumption),
        );

    setState(() {
      _scannedMaterial = null;
      _quantityController.clear();
      _batchNumberController.clear();
      _notesController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Material consumed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Material'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              key: _scannerKey,
              onDetect: _onScanResult,
            ),
          ),
          if (_scannedMaterial != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Scanned Material: ${_scannedMaterial!.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _batchNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Batch Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _consumeMaterial,
                    child: const Text('Consume Material'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

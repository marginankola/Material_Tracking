import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../domain/models/material_model.dart';
import '../../domain/models/consumption_model.dart';
import '../bloc/materials_bloc.dart';
import '../bloc/materials_event.dart';
import '../bloc/materials_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'package:uuid/uuid.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final GlobalKey<State<StatefulWidget>> _scannerKey =
      GlobalKey<State<StatefulWidget>>();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  MaterialModel? _scannedMaterial;

  @override
  void dispose() {
    _quantityController.dispose();
    _batchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleBarcodeDetected(Barcode barcode) {
    if (barcode.rawValue == null) return;

    final materialId = barcode.rawValue!;
    final materialsBloc = context.read<MaterialsBloc>();
    final state = materialsBloc.state;
    if (state is! MaterialsLoaded) return;

    final material = state.materials.firstWhere(
      (m) => m.id == materialId,
      orElse: () => MaterialModel(
        id: '',
        name: '',
        description: '',
        unitCost: 0,
        unitType: '',
        currentStock: 0,
        minimumStock: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (material.id.isNotEmpty) {
      setState(() {
        _scannedMaterial = material;
      });
    }
  }

  void _handleConsume() {
    if (_scannedMaterial == null) return;

    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final consumption = ConsumptionModel(
      id: const Uuid().v4(),
      materialId: _scannedMaterial!.id,
      quantity: quantity,
      batchNumber: _batchController.text,
      notes: _notesController.text,
      operatorId: authState.user.id,
      createdAt: DateTime.now(),
      consumedAt: DateTime.now(),
    );

    context.read<MaterialsBloc>().add(
          AddConsumptionEvent(consumption),
        );

    setState(() {
      _scannedMaterial = null;
      _quantityController.clear();
      _batchController.clear();
      _notesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: Text('Please login to scan materials'));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Scan Material'),
          ),
          body: Column(
            children: [
              Expanded(
                child: MobileScanner(
                  key: _scannerKey,
                  onDetect: (capture) {
                    final barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      _handleBarcodeDetected(barcodes.first);
                    }
                  },
                ),
              ),
              if (_scannedMaterial != null) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Scanned: ${_scannedMaterial!.name}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _batchController,
                        decoration: const InputDecoration(
                          labelText: 'Batch Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _handleConsume,
                        child: const Text('Consume Material'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

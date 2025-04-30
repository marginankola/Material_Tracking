import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';
import 'package:material_tracking/features/materials/domain/models/consumption_model.dart';
import 'package:material_tracking/features/materials/domain/models/product_model.dart';

class ExportService {
  Future<File> exportMaterialsToExcel(List<MaterialModel> materials) async {
    final excel = Excel.createExcel();
    final sheet = excel['Materials'];

    // Add headers
    sheet.appendRow([
      'ID',
      'Name',
      'Description',
      'Unit Cost',
      'Unit Type',
      'Current Stock',
      'Minimum Stock',
      'Created At',
      'Updated At'
    ]);

    // Add data
    for (final material in materials) {
      sheet.appendRow([
        material.id,
        material.name,
        material.description,
        material.unitCost.toString(),
        material.unitType,
        material.currentStock.toString(),
        material.minimumStock.toString(),
        material.createdAt.toIso8601String(),
        material.updatedAt.toIso8601String(),
      ]);
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/materials_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  Future<File> exportConsumptionsToExcel(List<ConsumptionModel> consumptions) async {
    final excel = Excel.createExcel();
    final sheet = excel['Consumptions'];

    // Add headers
    sheet.appendRow([
      'ID',
      'Material ID',
      'Operator ID',
      'Quantity',
      'Product ID',
      'Batch Number',
      'Notes',
      'Consumed At',
      'Created At'
    ]);

    // Add data
    for (final consumption in consumptions) {
      sheet.appendRow([
        consumption.id,
        consumption.materialId,
        consumption.operatorId,
        consumption.quantity.toString(),
        consumption.productId,
        consumption.batchNumber,
        consumption.notes,
        consumption.consumedAt.toIso8601String(),
        consumption.createdAt.toIso8601String(),
      ]);
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/consumptions_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  Future<File> exportProductCostingReport(
    ProductModel product,
    List<MaterialModel> materials,
    List<ConsumptionModel> consumptions,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Product Costing Report',
                style: pw.TextStyle(fontSize: 24)),
          ),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, child: pw.Text('Product Details')),
          pw.Table.fromTextArray(
            context: context,
            data: [
              ['Name', product.name],
              ['Description', product.description],
              ['Manufacturing Cost', '\$${product.manufacturingCost.toStringAsFixed(2)}'],
              ['Selling Price', '\$${product.sellingPrice.toStringAsFixed(2)}'],
              ['Profit Margin', '${(product.profitMargin * 100).toStringAsFixed(1)}%'],
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, child: pw.Text('Material Costs')),
          pw.Table.fromTextArray(
            context: context,
            headers: ['Material', 'Quantity', 'Unit Cost', 'Total Cost'],
            data: product.materialQuantities.entries.map((entry) {
              final material = materials.firstWhere((m) => m.id == entry.key);
              final quantity = entry.value;
              final totalCost = material.unitCost * quantity;
              return [
                material.name,
                '$quantity ${material.unitType}',
                '\$${material.unitCost.toStringAsFixed(2)}',
                '\$${totalCost.toStringAsFixed(2)}',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, child: pw.Text('Processing Costs')),
          pw.Table.fromTextArray(
            context: context,
            headers: ['Process', 'Cost'],
            data: product.processingCosts.entries
                .map((e) => [e.key, '\$${e.value.toStringAsFixed(2)}'])
                .toList(),
          ),
        ],
      ),
    );

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/product_costing_${product.id}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
} 
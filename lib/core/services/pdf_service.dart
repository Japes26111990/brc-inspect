import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../modules/inspection/providers/inspection_provider.dart';
import '../../modules/inspection/models/inspection_models.dart';

class PDFService {
  static Future<void> generateAndPrintReport(ActiveInspectionProvider provider) async {
    // 1. PRE-LOAD IMAGES ASYNCHRONOUSLY (Critical for Web/Chrome support)
    List<pw.Widget> photoGridWidgets = [];
    
    for (var photoData in provider.vehicle360Photos) {
      if (photoData['path'] != null) {
        try {
          final XFile file = XFile(photoData['path']);
          final Uint8List bytes = await file.readAsBytes();
          final image = pw.MemoryImage(bytes);
          
          photoGridWidgets.add(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  height: 150,
                  width: 200,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover),
                  )
                ),
                pw.SizedBox(height: 8),
                pw.Text(photoData['label'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                if (photoData['hasDamage'] == true)
                  pw.Text('DAMAGE: ${photoData['notes']}', style: const pw.TextStyle(color: PdfColors.red700, fontSize: 10)),
              ]
            )
          );
        } catch (e) {
          print("Failed to load image: $e");
        }
      }
    }

    // 2. BUILD THE PDF DOCUMENT
    final pdf = pw.Document();
    
    final bool passesOverall = provider.passesRoadworthy;
    final String verdict = passesOverall ? 'PASSED - ROADWORTHY' : 'FAILED - NOT ROADWORTHY';
    final PdfColor primaryColor = PdfColor.fromHex('#D4AF37'); // BRC Gold
    final PdfColor passColor = PdfColors.green700;
    final PdfColor failColor = PdfColors.red700;

    // PAGE 1: OVERVIEW & DETAILS
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('BRC INSPECT', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                pw.Text('CONDITION REPORT', style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
              ]
            ),
            pw.Divider(color: primaryColor, thickness: 2),
            pw.SizedBox(height: 10),

            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(color: passesOverall ? PdfColors.green100 : PdfColors.red100),
              child: pw.Center(
                child: pw.Text(
                  verdict, 
                  style: pw.TextStyle(color: passesOverall ? passColor : failColor, fontSize: 18, fontWeight: pw.FontWeight.bold)
                ),
              ),
            ),
            pw.SizedBox(height: 30),

            pw.Text('Vehicle Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: primaryColor)),
            pw.SizedBox(height: 10),
            _buildDetailsTable(provider),
            pw.SizedBox(height: 30),

            pw.Text('Roadworthy Compliance Items', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: failColor)),
            pw.SizedBox(height: 10),
            pw.Text('The following critical safety items require immediate attention:', style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 10),
            _buildRoadworthyTable(provider),
          ];
        },
      ),
    );

    // PAGE 2+: DETAILED SECTION BREAKDOWNS
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          List<pw.Widget> sectionWidgets = [];

          provider.sections.forEach((sectionName, items) {
            sectionWidgets.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(sectionName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                  pw.SizedBox(height: 10),
                  _buildSectionTable(items),
                  pw.SizedBox(height: 30),
                ]
              )
            );
          });

          sectionWidgets.add(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Wheels & Tyres', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                pw.SizedBox(height: 10),
                _buildTyreTable(provider.tyres),
              ]
            )
          );

          return sectionWidgets;
        }
      )
    );

    // PAGE 3: PHOTOGRAPHIC EVIDENCE
    if (photoGridWidgets.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              pw.Text('Photographic Evidence', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: primaryColor)),
              pw.Divider(color: primaryColor),
              pw.SizedBox(height: 20),
              pw.Wrap(
                spacing: 20,
                runSpacing: 20,
                children: photoGridWidgets,
              )
            ];
          }
        )
      );
    }

    // 3. GENERATE OUTPUT
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'BRC_Report_${provider.vehicleDetails['Registration Number']}.pdf',
    );
  }

  // --- HELPER METHODS FOR BUILDING TABLES ---

  static pw.Widget _buildDetailsTable(ActiveInspectionProvider provider) {
    return pw.TableHelper.fromTextArray(
      cellAlignment: pw.Alignment.centerLeft,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
      cellStyle: const pw.TextStyle(fontSize: 11),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      data: <List<String>>[
        ['Registration', provider.vehicleDetails['Registration Number'] ?? 'N/A', 'VIN', provider.vehicleDetails['VIN Number'] ?? 'N/A'],
        ['Make', provider.vehicleDetails['Make'] ?? 'N/A', 'Model', provider.vehicleDetails['Model'] ?? 'N/A'],
        ['Year', provider.vehicleDetails['Year Model'] ?? 'N/A', 'Mileage', provider.vehicleDetails['Mileage'] ?? 'N/A'],
        ['Transmission', provider.vehicleDetails['Transmission'] ?? 'N/A', 'Fuel Type', provider.vehicleDetails['Fuel Type'] ?? 'N/A'],
      ],
    );
  }

  static pw.Widget _buildRoadworthyTable(ActiveInspectionProvider provider) {
    List<List<String>> rowData = [
      ['Component', 'Explanation', 'Status'] 
    ];

    provider.sections.forEach((_, items) {
      for (var item in items) {
        if (item.isRoadworthyRelevant && (item.status == ItemStatus.fail || item.status == ItemStatus.attention)) {
          rowData.add([item.title, item.notes.isEmpty ? 'Requires attention' : item.notes, item.status.name.toUpperCase()]);
        }
      }
    });

    for (var tyre in provider.tyres) {
      if (tyre.status == ItemStatus.fail) {
        rowData.add(['Tyre: ${tyre.position}', '${tyre.treadDepthMm}mm - Illegal tread depth', 'FAIL']);
      }
    }

    if (rowData.length == 1) {
      return pw.Text('No roadworthy issues detected.', style: const pw.TextStyle(color: PdfColors.green700));
    }

    return pw.TableHelper.fromTextArray(
      headers: rowData.first,
      data: rowData.sublist(1),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.red700),
      cellStyle: const pw.TextStyle(fontSize: 10),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FlexColumnWidth(1),
      },
    );
  }

  static pw.Widget _buildSectionTable(List<ComponentResult> items) {
    List<List<String>> rowData = [
      ['Component', 'Condition', 'Explanation'] 
    ];

    for (var item in items) {
      String condition = item.status.name.toUpperCase();
      if (item.rating > 0) condition = '${item.rating}/5 Stars'; 

      String explanation = item.notes;
      if (item.notes.isEmpty && item.status == ItemStatus.pass) explanation = 'Condition is as expected for vehicle age and mileage.';

      rowData.add([item.title, condition, explanation]);
    }

    return pw.TableHelper.fromTextArray(
      headers: rowData.first,
      data: rowData.sublist(1),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      cellStyle: const pw.TextStyle(fontSize: 10),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(3),
      },
    );
  }

  static pw.Widget _buildTyreTable(List<TyreResult> tyres) {
    List<List<String>> rowData = [
      ['Position', 'Make/Model', 'Size', 'Tread', 'Condition']
    ];

    for (var tyre in tyres) {
      rowData.add([
        tyre.position, 
        '${tyre.make} ${tyre.tyreModel}', 
        '${tyre.size} ${tyre.loadSpeedIndex}', 
        '${tyre.treadDepthMm}mm', 
        tyre.status.name.toUpperCase()
      ]);
    }

    return pw.TableHelper.fromTextArray(
      headers: rowData.first,
      data: rowData.sublist(1),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
      cellStyle: const pw.TextStyle(fontSize: 10),
    );
  }
}
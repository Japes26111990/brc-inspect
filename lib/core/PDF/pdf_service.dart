import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../modules/inspection/providers/inspection_provider.dart';
import '../../modules/inspection/models/inspection_models.dart';

class PDFService {
  static Future<void> generateAndPrintReport(ActiveInspectionProvider provider) async {
    final pdf = pw.Document();
    final bool passesOverall = provider.passesRoadworthy;
    final d = provider.vehicleDetails;
    
    pw.MemoryImage? logoBRC;
    pw.MemoryImage? logoSABS;
    pw.MemoryImage? logoRMI;

    try {
      final ByteData b1 = await rootBundle.load('assets/logos/brc_logo.png');
      logoBRC = pw.MemoryImage(b1.buffer.asUint8List());
      final ByteData b2 = await rootBundle.load('assets/logos/sabs_logo.png');
      logoSABS = pw.MemoryImage(b2.buffer.asUint8List());
      final ByteData b3 = await rootBundle.load('assets/logos/rmi_logo.png');
      logoRMI = pw.MemoryImage(b3.buffer.asUint8List());
    } catch (_) {}

    // Grouping items into three landscape data columns to match the physical BRC form layout precisely
    final List<ComponentResult> col1Items = [
      ...provider.sections['Identification & Docs'] ?? [],
      ...provider.sections['Electrical System'] ?? [],
      ...provider.sections['Fittings & Equipment'] ?? [],
    ];

    final List<ComponentResult> col2Items = [
      ...provider.sections['Braking System'] ?? [],
      ...provider.sections['Wheels'] ?? [],
      ...provider.sections['Suspension & Undercarriage'] ?? [],
    ];

    final List<ComponentResult> col3Items = [
      ...provider.sections['Steering'] ?? [],
      ...provider.sections['Engine'] ?? [],
      ...provider.sections['Exhaust System'] ?? [],
      ...provider.sections['Transmission & Drive'] ?? [],
      ...provider.sections['Instruments'] ?? [],
      ...provider.sections['Dimensions'] ?? [],
      ...provider.sections['Structural Damage'] ?? [],
    ];

    // ======================== PAGE 1: PHYSICAL BLANKET COPY MANIFEST ========================
    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(297 * PdfPageFormat.mm, 210 * PdfPageFormat.mm, marginAll: 8),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Top Bar Carbon-Form Header Elements
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 70, height: 35,
                    // 🛠️ FIX: Wrapped the logo border safely inside a BoxDecoration
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 0.8),
                    ),
                    alignment: pw.Alignment.center,
                    child: logoBRC != null ? pw.Image(logoBRC) : pw.Text('BRC LOGO', style: const pw.TextStyle(fontSize: 7)),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (logoRMI != null) pw.Image(logoRMI, height: 10),
                      pw.Text('BOLAND ROADWORTHY CENTRE', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text('ROADWORTHY 40pt', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
                      // 🛠️ FIX: Used double quotes on the outside to prevent interpolation syntax warnings
                      pw.Text("Ref. No. ${d['Form Ref No'] ?? '0458'}", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Container(
                    width: 55, height: 32,
                    alignment: pw.Alignment.center,
                    child: logoSABS != null ? pw.Image(logoSABS) : pw.Text('SABS', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Spacer(),
                  pw.Container(
                    width: 230,
                    child: pw.TableHelper.fromTextArray(
                      cellAlignment: pw.Alignment.centerLeft,
                      cellStyle: const pw.TextStyle(fontSize: 5.5, color: PdfColors.black),
                      border: pw.TableBorder.all(color: PdfColors.black, width: 0.4),
                      data: <List<String>>[
                        ['OWNER SURNAME & INITIALS', (d['Owner Surname & Initials'] ?? '').toUpperCase()],
                        ['VEHICLE MODEL', (d['Vehicle Model'] ?? '').toUpperCase()],
                        ['VEHICLE MAKE', (d['Vehicle Make'] ?? '').toUpperCase()],
                        ['VEHICLE REGISTRATION NO.', (d['Vehicle Registration No'] ?? '').toUpperCase()],
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Text('VEHICLE ENGINE NUMBER: ${(d['Vehicle Engine Number'] ?? '').toUpperCase()}', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(width: 30),
                  pw.Text('VEHICLE VIN CHASSIS NUMBER: ${(d['Vehicle VIN Chassis Number'] ?? '').toUpperCase()}', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 5),

              // 4-Column Exact Form Copy Flow Layout
              pw.Expanded(
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(flex: 3, child: _buildPhysicalFormColumn(col1Items)),
                    pw.SizedBox(width: 6),
                    pw.Expanded(flex: 3, child: _buildPhysicalFormColumn(col2Items, stateMap: d, showGrids: true)),
                    pw.SizedBox(width: 6),
                    pw.Expanded(flex: 3, child: _buildPhysicalFormColumn(col3Items)),
                    pw.SizedBox(width: 6),
                    
                    // Column 4: Official Sign-Off Control Block
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.5)),
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            _buildExaminerFormBlock(d, 'INITIAL EXAMINATION', passesOverall),
                            pw.Container(height: 0.4, color: PdfColors.black),
                            _buildExaminerFormBlock(d, 'RE-TEST LOG PROFILE', false),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // ======================== PAGE 2: FAULT LOG OVERFLOW ========================
    List<ComponentResult> failedComponents = [];
    provider.sections.values.forEach((list) {
      for (var c in list) {
        if (!c.isNotApplicable && c.photoTargets.first.status == ItemStatus.fail) {
          failedComponents.add(c);
        }
      }
    });

    if (failedComponents.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('DETAILED WORKSHOP RECTIFICATION REASONING LOG', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                pw.SizedBox(height: 3),
                pw.Text('The items below were checked "FAIL" on the landscape manifest and require repairs before a roadworthy token is issued.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 0.5, color: PdfColors.black),
                pw.SizedBox(height: 10),

                pw.ListView.builder(
                  itemCount: failedComponents.length,
                  itemBuilder: (context, index) {
                    final comp = failedComponents[index];
                    final target = comp.photoTargets.first;

                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 12),
                      padding: const pw.EdgeInsets.all(6),
                      decoration: const pw.BoxDecoration(color: PdfColors.grey50),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('❌ ${comp.title}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                          pw.SizedBox(height: 2),
                          pw.Text('DEFECT SPECIFICS: ${target.notes}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.red800)),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'BRC_Official_Carbon_Report_${d['Vehicle Registration No'] ?? 'SYS'}.pdf',
    );
  }

  static pw.Widget _buildPhysicalFormColumn(List<ComponentResult> items, {Map<String, String>? stateMap, bool showGrids = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: items.map((comp) {
        bool isBlueBlock = !comp.isCompulsory;
        bool isUnassessed = comp.photoTargets.first.status == ItemStatus.na && !comp.isNotApplicable;
        
        String checkMarkLeft = '';
        String checkMarkRight = '';
        
        if (!isUnassessed) {
          if (comp.isNotApplicable) {
            checkMarkRight = 'N/A';
          } else if (comp.photoTargets.first.status == ItemStatus.pass) {
            checkMarkLeft = 'X';
          } else if (comp.photoTargets.first.status == ItemStatus.fail) {
            checkMarkRight = 'X';
          }
        }

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              height: 11,
              decoration: pw.BoxDecoration(
                color: isBlueBlock ? PdfColor.fromHex('#93C5FD') : PdfColors.white,
                border: const pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 0.3)),
              ),
              child: pw.Row(
                children: [
                  if (comp.isCompulsory) ...[
                    pw.Text('* ', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                  ],
                  pw.Expanded(
                    child: pw.Text(
                      comp.title,
                      style: pw.TextStyle(fontSize: 5.3, fontWeight: comp.isCompulsory ? pw.FontWeight.bold : pw.FontWeight.normal, color: PdfColors.black),
                      maxLines: 1,
                      overflow: pw.TextOverflow.clip,
                    ),
                  ),
                  pw.Container(
                    width: 14, height: 11, 
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(left: pw.BorderSide(color: PdfColors.black, width: 0.3)),
                    ),
                    alignment: pw.Alignment.center, 
                    child: pw.Text(checkMarkLeft, style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Container(
                    width: 14, height: 11, 
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(left: pw.BorderSide(color: PdfColors.black, width: 0.3)),
                    ),
                    alignment: pw.Alignment.center, 
                    child: pw.Text(checkMarkRight, style: pw.TextStyle(fontSize: 5, fontWeight: pw.FontWeight.bold, color: checkMarkRight == 'X' ? PdfColors.red800 : PdfColors.black)),
                  ),
                ],
              ),
            ),
            
            if (showGrids && comp.id == 'service_brakes_row' && stateMap != null) ...[
              _buildEmbeddedMetricRow("L/F: ${stateMap['Brake_LF'] ?? ''}  |  R/F: ${stateMap['Brake_RF'] ?? ''}"),
              _buildEmbeddedMetricRow("L/R: ${stateMap['Brake_LR'] ?? ''}  |  R/R: ${stateMap['Brake_RR'] ?? ''}"),
            ],
            if (showGrids && comp.id == 'test_parking_brake' && stateMap != null) ...[
              _buildEmbeddedMetricRow("L/F1: ${stateMap['Park_LF1'] ?? ''}  |  R/F1: ${stateMap['Park_RF1'] ?? ''}"),
              _buildEmbeddedMetricRow("L/R2: ${stateMap['Park_LR2'] ?? ''}  |  R/R2: ${stateMap['Park_RR2'] ?? ''}"),
            ],
            if (showGrids && comp.id == 'check_tread_depth_row' && stateMap != null) ...[
              _buildEmbeddedMetricRow("LF: ${stateMap['Odo_LF'] ?? ''}mm  |  RF: ${stateMap['Odo_RF'] ?? ''}mm"),
              _buildEmbeddedMetricRow("LR: ${stateMap['Odo_LR'] ?? ''}mm  |  RR: ${stateMap['Odo_RR'] ?? ''}mm"),
            ],
          ],
        );
      }).toList(),
    );
  }

  static pw.Widget _buildEmbeddedMetricRow(String valueText) {
    return pw.Container(
      height: 9,
      padding: const pw.EdgeInsets.only(left: 12),
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.3))),
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(valueText, style: const pw.TextStyle(fontSize: 4.8, color: PdfColors.grey800)),
    );
  }

  static pw.Widget _buildExaminerFormBlock(Map<String, String> d, String blockTitle, bool isPassed) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(blockTitle, style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
        pw.SizedBox(height: 2),
        pw.Text("TEST DATE: ${d['Test Date'] ?? ''}   TIME: ${d['Time'] ?? ''}", style: const pw.TextStyle(fontSize: 5.5)),
        pw.Text("ODOMETER READING: ${d['Odometer Reading'] ?? ''}", style: const pw.TextStyle(fontSize: 5.5)),
        pw.SizedBox(height: 2),
        
        pw.Row(
          children: [
            pw.Text('RESULT: ', style: const pw.TextStyle(fontSize: 5.5)),
            pw.Container(
              width: 25, height: 10, 
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.3),
              ),
              alignment: pw.Alignment.center, 
              child: pw.Text(isPassed ? 'X' : '', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(width: 4),
            pw.Text('PASS', style: const pw.TextStyle(fontSize: 5)),
            pw.SizedBox(width: 8),
            pw.Container(
              width: 25, height: 10, 
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.3),
              ),
              alignment: pw.Alignment.center, 
              child: pw.Text(!isPassed ? 'X' : '', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
            ),
            pw.SizedBox(width: 4),
            pw.Text('FAIL', style: const pw.TextStyle(fontSize: 5)),
          ],
        ),
        pw.SizedBox(height: 3),
        pw.Text("EXAMINER NAME: ${(d['Examiner Name'] ?? '').toUpperCase()}", style: const pw.TextStyle(fontSize: 5.5)),
        pw.Text("EXAMINER NUMBER: ${d['Examiner Number'] ?? ''}", style: const pw.TextStyle(fontSize: 5.5)),
        pw.SizedBox(height: 4),
        pw.Container(
          width: 55, height: 10, 
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400, width: 0.3),
          ),
          alignment: pw.Alignment.center, 
          child: pw.Text('SIGNATURE', style: const pw.TextStyle(fontSize: 4, color: PdfColors.grey400)),
        ),
        pw.SizedBox(height: 2),
        pw.Text("REMARKS: ${d['Remarks'] ?? ''}", style: const pw.TextStyle(fontSize: 5.5)),
      ],
    );
  }
}
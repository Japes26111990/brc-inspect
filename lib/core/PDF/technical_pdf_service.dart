import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../modules/inspection/providers/inspection_provider.dart';
import '../../modules/inspection/models/inspection_models.dart';

class TechnicalPDFService {
  static Future<Uint8List> generatePdfBytes(
    ActiveInspectionProvider provider,
  ) async {
    final pdf = pw.Document();
    final d = provider.vehicleDetails;

    final now = DateTime.now();
    d['Test Date'] =
        "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    pw.MemoryImage? logoBRC;
    pw.MemoryImage? logoSABS;
    pw.MemoryImage? logoRMI;
    pw.MemoryImage? logoAA;

    try {
      final ByteData b1 = await rootBundle.load('assets/logos/brc_logo.png');
      logoBRC = pw.MemoryImage(b1.buffer.asUint8List());
      final ByteData b2 = await rootBundle.load('assets/logos/sabs_logo.png');
      logoSABS = pw.MemoryImage(b2.buffer.asUint8List());
      final ByteData b3 = await rootBundle.load('assets/logos/rmi_logo.png');
      logoRMI = pw.MemoryImage(b3.buffer.asUint8List());
      final ByteData b4 = await rootBundle.load('assets/logos/aa_logo.png');
      logoAA = pw.MemoryImage(b4.buffer.asUint8List());
    } catch (_) {}

    // ========================================================================
    // PAGE 1: HEADER, MASTER DETAILS & CONDITIONS OF EXAMINATION (FINE PRINT)
    // ========================================================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeaderTop(logoRMI, logoSABS, logoBRC, logoAA),
              pw.SizedBox(height: 12),
              pw.Container(
                color: PdfColors.black,
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                width: double.infinity,
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'TECHNICAL REPORT',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.black, width: 1),
                      ),
                      child: pw.Column(
                        children: [
                          _buildDetailRow(
                            'OWNER',
                            d['Owner Surname & Initials'] ?? '',
                          ),
                          _buildDetailRow(
                            'CONTACT NO.',
                            d['Client Cell'] ?? '',
                          ),
                          _buildDetailRow(
                            'VEHICLE MAKE',
                            d['Vehicle Make'] ?? '',
                          ),
                          _buildDetailRow(
                            'REG NO.',
                            d['Vehicle Registration No'] ?? '',
                          ),
                          _buildDetailRow(
                            'CERTIFICATE NO.',
                            d['Certificate No'] ?? '353/1',
                            isRed: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.black, width: 1),
                      ),
                      child: pw.Column(
                        children: [
                          _buildDetailRow(
                            'Print name:',
                            d['Client Name'] ?? '',
                          ),
                          _buildDetailRow(
                            'Technician:',
                            d['Examiner Name'] ?? '',
                          ),
                          _buildDetailRow(
                            'Examined at:',
                            'BRC Branch Facility',
                          ),
                          _buildDetailRow('Date:', d['Test Date'] ?? ''),
                          _buildDetailRow(
                            'Comments:',
                            d['Remarks'] ?? '',
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildDetailRow(
                        'Odometer reading:',
                        d['Odometer Reading'] ?? '',
                      ),
                    ),
                    pw.Expanded(
                      child: _buildDetailRow(
                        'Engine No:',
                        d['Vehicle Engine Number'] ?? '',
                      ),
                    ),
                    pw.Expanded(
                      child: _buildDetailRow(
                        'Chassis No:',
                        d['Vehicle VIN Chassis Number'] ?? '',
                      ),
                    ),
                    pw.Expanded(
                      child: _buildDetailRow(
                        'Vin No:',
                        d['Vehicle VIN Chassis Number'] ?? '',
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Text(
                'Conditions of Examination',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'As to enable our clients to make informed decisions on the condition and state of inspected vehicles, BRC follows a strictly enforced set of endorsed automotive testing procedures.\n'
                'BRC can however not accept any responsibility for:\n'
                'Mechanical, electrical and/or other defects not detected from a visual examination and short road test;\n'
                '1. Latent defects which occur at a later stage and\n'
                '2. Any advice given or opinions expressed.\n'
                'Only if standard equipment and dismantling procedures are required for the removing of wheels and break drums of vehicles to be inspected, this procedure will be executed.\n'
                'In the case on any dispute on the report, no additional work, replacement of components and/or self repairs should be carried out on the vehicle, to enable BRC to make their assessment.\n'
                'This document is an independent assessment of the vehicle, as requested by the client, and nothing more. It is not a guarantee, and does not alter the standard contractual relationship between the buyer and seller of a vehicle, nor detract from any rights as protected in South African law.\n'
                'Examination fees are payable on examination of the vehicle.\n'
                'Re-evaluations can be done for an additional fee, within a 3 month period of the original test.\n'
                'Vehicles are left in our care at the owners own risk, and BRC is thus indemnified against any loss, damage or theft.',
                style: const pw.TextStyle(fontSize: 7.2, lineSpacing: 1.8),
              ),
              pw.Spacer(),
              _buildMioFooter('00352/2'),
            ],
          );
        },
      ),
    );

    // ========================================================================
    // PAGE 2: 2. ENGINE DIAGNOSTICS & 3. COOLING SYSTEM MASTER TABLE
    // ========================================================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          final columnWidthConfig = {
            0: const pw.FlexColumnWidth(5),
            1: const pw.FlexColumnWidth(1.2),
            2: const pw.FlexColumnWidth(1.2),
            3: const pw.FlexColumnWidth(1.2),
            4: const pw.FlexColumnWidth(3.5),
          };

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('2. ENGINE'),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                columnWidths: columnWidthConfig,
                children: [
                  _buildSeverityTableHeader(),
                  ..._buildSeverityRows(
                    provider.sections['2. ENGINE DIAGNOSTICS'] ?? [],
                    d,
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              _buildSectionHeader('3. COOLING SYSTEM'),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                columnWidths: columnWidthConfig,
                children: [
                  _buildSeverityTableHeader(),
                  ..._buildSeverityRows(
                    provider.sections['3. COOLING SYSTEM'] ?? [],
                    d,
                  ),
                ],
              ),
              pw.Spacer(),
              _buildMioFooter('00352/3'),
            ],
          );
        },
      ),
    );

    // ========================================================================
    // PAGE 3: ROAD TEST METRIC ANALYSES (SECTIONS 1 TO 6)
    // ========================================================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          final roadTestData =
              provider.sections['4. ROAD TEST PERFORMANCE'] ?? [];
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('ROAD TEST'),
              pw.SizedBox(height: 6),
              pw.Expanded(
                child: pw.GridView(
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildSubGridBlock(
                      '1. Engine Performance',
                      roadTestData
                          .where(
                            (e) => e.title.startsWith('Engine Performance:'),
                          )
                          .toList(),
                    ),
                    _buildSubGridBlock(
                      '2. Transmission',
                      roadTestData
                          .where((e) => e.title.startsWith('Transmission:'))
                          .toList(),
                    ),
                    _buildSubGridBlock(
                      '3. Brake Test',
                      roadTestData
                          .where((e) => e.title.startsWith('Brake Test:'))
                          .toList(),
                    ),
                    _buildSubGridBlock(
                      '4. Clutch',
                      roadTestData
                          .where((e) => e.title.startsWith('Clutch:'))
                          .toList(),
                    ),
                    _buildSubGridBlock(
                      '5. Driveline',
                      roadTestData
                          .where((e) => e.title.startsWith('Driveline:'))
                          .toList(),
                    ),
                    _buildSubGridBlock(
                      '6. Differential',
                      roadTestData
                          .where((e) => e.title.startsWith('Differential:'))
                          .toList(),
                    ),
                  ],
                ),
              ),
              pw.Spacer(),
              _buildMioFooter('00352/4'),
            ],
          );
        },
      ),
    );

    // ========================================================================
    // PAGE 4: ROAD TEST CONTINUED & INSTRUMENTATION MATRIX
    // ========================================================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          final roadTestData =
              provider.sections['4. ROAD TEST PERFORMANCE'] ?? [];
          final instrumentData =
              provider.sections['5. INSTRUMENTATION & ACCESSORIES'] ?? [];
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('ROAD TEST (CONTINUED)'),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildSubGridBlock(
                      '7. Steering',
                      roadTestData
                          .where((e) => e.title.startsWith('Steering:'))
                          .toList(),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: _buildSubGridBlock(
                      '8. Brakes',
                      roadTestData
                          .where((e) => e.title.startsWith('Brakes:'))
                          .toList(),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              _buildSubGridBlock(
                '9. Shock Absorbers',
                roadTestData
                    .where((e) => e.title.startsWith('Shock Absorbers:'))
                    .toList(),
              ),
              pw.SizedBox(height: 12),
              _buildSectionHeader('10. Instrumentation'),
              pw.SizedBox(height: 6),
              _buildInstrumentationGrid(instrumentData),
              pw.Spacer(),
              _buildMioFooter('00352/5'),
            ],
          );
        },
      ),
    );

    // ========================================================================
    // PAGE 5: 3. ELECTRICAL CHECKLIST SYSTEM
    // ========================================================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          final elecData = provider.sections['6. ELECTRICAL ANALYSIS'] ?? [];
          final lightData = provider.sections['7. LIGHTING SYSTEMS'] ?? [];
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('3. ELECTRICAL'),
              pw.SizedBox(height: 6),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        _buildSubGridBlock(
                          'Battery',
                          elecData
                              .where((e) => e.title.startsWith('Battery:'))
                              .toList(),
                        ),
                        pw.SizedBox(height: 8),
                        _buildSubGridBlock(
                          'Charging System',
                          elecData
                              .where(
                                (e) => e.title.startsWith('Charging System:'),
                              )
                              .toList(),
                        ),
                        pw.SizedBox(height: 8),
                        _buildSubGridBlock(
                          'Starter',
                          elecData
                              .where((e) => e.title.startsWith('Starter:'))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        _buildSubGridBlock(
                          'Wiring',
                          elecData
                              .where((e) => !e.title.contains(':'))
                              .toList(),
                        ),
                        pw.SizedBox(height: 8),
                        _buildSubGridBlock('Lights', lightData),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),
              _buildMioFooter('00352/6'),
            ],
          );
        },
      ),
    );

    // ========================================================================
    // PAGE 6: 4. BODY TEST MATRIX SHEETS
    // ========================================================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          final bodyData =
              provider.sections['8. INTERIOR & EXTERIOR TRIM'] ?? [];
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('4. BODY TEST'),
              pw.SizedBox(height: 8),
              pw.Container(
                height: 120,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Text(
                  '[ Vehicle Diagnostic Mapping Grid View Active ]',
                  style: pw.TextStyle(
                    color: PdfColors.grey600,
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _buildSubGridBlock(
                      'Trim / Interior',
                      bodyData.take(11).toList(),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: _buildSubGridBlock(
                      'Exterior',
                      bodyData.skip(11).toList(),
                    ),
                  ),
                ],
              ),
              pw.Spacer(),
              _buildMioFooter('00352/7'),
            ],
          );
        },
      ),
    );

    // ========================================================================
    // PAGE 7: 5. STEERING, WHEELS & BRAKES COMPLEX ARRAYS
    // ========================================================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          final mixData = provider.sections['9. STEERING & UNDER-BRAKES'] ?? [];
          final tyreData =
              provider.sections['10. WHEELS & TYRES DIAGNOSTICS'] ?? [];
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('5. STEERING, WHEELS & BRAKES'),
              pw.SizedBox(height: 8),
              _buildAxleGridTable(
                'Brakes Matrix',
                mixData.where((e) => e.title.startsWith('Brakes:')).toList(),
                d,
              ),
              pw.SizedBox(height: 10),
              _buildSubGridBlock(
                'Steering Checklist',
                mixData.where((e) => e.title.startsWith('Steering:')).toList(),
              ),
              pw.SizedBox(height: 10),
              _buildAxleGridTable('Wheels & Tyres Matrix', tyreData, d),
              pw.Spacer(),
              _buildMioFooter('00352/8'),
            ],
          );
        },
      ),
    );

    // ========================================================================
    // PAGE 8: 6. UNDERCARRIAGE SYSTEM MATRICES
    // ========================================================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          final underData = provider.sections['11. UNDERCARRIAGE SYSTEM'] ?? [];
          final auxiliaryData =
              provider.sections['12. FUEL & EXHAUST CRADLE'] ?? [];
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('6. UNDERCARRIAGE'),
              pw.SizedBox(height: 8),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _buildSubGridBlock(
                      'Chassis',
                      underData
                          .where((e) => e.title.startsWith('Chassis:'))
                          .toList(),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: _buildSubGridBlock(
                      'Suspension',
                      underData
                          .where((e) => e.title.startsWith('Suspension:'))
                          .toList(),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              _buildSubGridBlock(
                'Fuel System',
                auxiliaryData
                    .where((e) => e.title.startsWith('Fuel System:'))
                    .toList(),
              ),
              pw.SizedBox(height: 8),
              _buildSubGridBlock(
                'Drive Shaft & Joints',
                auxiliaryData
                    .where((e) => e.title.startsWith('Drive Shaft:'))
                    .toList(),
              ),
              pw.SizedBox(height: 8),
              _buildSubGridBlock(
                'Exhaust & Ride Matrix',
                auxiliaryData
                    .where(
                      (e) =>
                          e.title.startsWith('Exhaust:') ||
                          e.title.startsWith('Ride Height:'),
                    )
                    .toList(),
              ),
              pw.Spacer(),
              _buildMioFooter('00352/9'),
            ],
          );
        },
      ),
    );

    // ========================================================================
    // PAGE 9: RECHECK WORKTRACK MATRIX SIGN-OFF SYSTEM
    // ========================================================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('RECHECK WORKTRACK MATRIX'),
              pw.SizedBox(height: 12),
              pw.Row(
                children: [
                  pw.Expanded(child: _buildRecheckBlock('Recheck 1')),
                  pw.SizedBox(width: 12),
                  pw.Expanded(child: _buildRecheckBlock('Recheck 2')),
                ],
              ),
              pw.Spacer(),
              _buildMioFooter('00352/9'),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  // ========================================================================
  // CORE LAYOUT COMPONENT STRUCTURAL ENGINE GENERATORS
  // ========================================================================
  static pw.Widget _buildHeaderTop(
    pw.MemoryImage? rmi,
    pw.MemoryImage? sabs,
    pw.MemoryImage? brc,
    pw.MemoryImage? aa,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (rmi != null) pw.Image(rmi, height: 26),
            pw.SizedBox(height: 4),
            if (sabs != null) pw.Image(sabs, height: 26),
          ],
        ),
        pw.Column(
          children: [
            if (brc != null) pw.Image(brc, height: 50),
            pw.SizedBox(height: 2),
            pw.Text(
              'Roadworthy & Vehicle Inspection Centre',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'For your nearest branch, call +27-11-475-8050',
              style: const pw.TextStyle(fontSize: 7),
            ),
          ],
        ),
        pw.Container(
          width: 85,
          height: 55,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: PdfColor.fromHex('#FFD700'),
              width: 1.5,
            ),
          ),
          alignment: pw.Alignment.center,
          child:
              aa != null
                  ? pw.Image(aa, fit: pw.BoxFit.contain)
                  : pw.Text(
                    'AA APPROVED',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
        ),
      ],
    );
  }

  static pw.Widget _buildDetailRow(
    String label,
    String value, {
    bool isRed = false,
    int maxLines = 1,
  }) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
        ),
      ),
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 7.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
          ),
          pw.Expanded(
            flex: 4,
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: isRed ? PdfColors.red800 : PdfColors.black,
              ),
              maxLines: maxLines,
              overflow: pw.TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      color: PdfColors.black,
      padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      width: double.infinity,
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(
          color: PdfColor.fromHex('#FFD700'),
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.TableRow _buildSeverityTableHeader() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(
            'DIAGNOSTIC CRITERIA / TEST TARGET',
            style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(
            'NIL',
            style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(
            'SLIGHT',
            style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(
            'APPRECIABLE',
            style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(
            'EVALUATION EVALUATION / COMMENTS',
            style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  static List<pw.TableRow> _buildSeverityRows(
    List<ComponentResult> items,
    Map<String, String> details,
  ) {
    return items.map((item) {
      String statusStr = '/';

      // Update this logic to correctly map the new ItemStatus back to the string layout
      if (!item.isNotApplicable && item.photoTargets.isNotEmpty) {
        if (item.photoTargets.first.status == ItemStatus.pass) {
          statusStr = 'NIL';
        } else if (item.photoTargets.first.status == ItemStatus.attention) {
          statusStr = 'SLIGHT';
        } else if (item.photoTargets.first.status == ItemStatus.fail) {
          statusStr = 'APPRECIABLE';
        }
      }

      String evaluationInput = details[item.title] ?? '';
      String itemFaultNotes =
          (item.photoTargets.isNotEmpty &&
                  item.photoTargets.first.notes != null)
              ? item.photoTargets.first.notes
              : '';
      String commentStr = "$evaluationInput $itemFaultNotes".trim();

      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(item.title, style: const pw.TextStyle(fontSize: 7)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              statusStr == 'NIL' ? 'X' : '',
              style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              statusStr == 'SLIGHT' ? 'X' : '',
              style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              statusStr == 'APPRECIABLE' ? 'X' : '',
              style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(commentStr, style: const pw.TextStyle(fontSize: 7)),
          ),
        ],
      );
    }).toList();
  }

  static pw.Widget _buildSubGridBlock(
    String blockTitle,
    List<ComponentResult> subItems,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            color: PdfColors.grey800,
            padding: const pw.EdgeInsets.all(3),
            width: double.infinity,
            child: pw.Text(
              blockTitle,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 7.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          ...subItems.map((item) {
            String checkMark = '';
            if (!item.isNotApplicable && item.photoTargets.isNotEmpty) {
              checkMark =
                  item.photoTargets.first.status == ItemStatus.pass ? 'V' : 'X';
            }
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      item.title.replaceAll(RegExp(r'.*:\s*'), ''),
                      style: const pw.TextStyle(fontSize: 7),
                      maxLines: 1,
                    ),
                  ),
                  pw.Container(
                    width: 10,
                    height: 10,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 0.4),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      checkMark,
                      style: pw.TextStyle(
                        fontSize: 6.5,
                        fontWeight: pw.FontWeight.bold,
                        color:
                            checkMark == 'X'
                                ? PdfColors.red800
                                : PdfColors.black,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  static pw.Widget _buildInstrumentationGrid(List<ComponentResult> items) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      children: List.generate((items.length / 3).ceil(), (rowIndex) {
        return pw.TableRow(
          children: List.generate(3, (colIndex) {
            int targetIdx = rowIndex * 3 + colIndex;
            if (targetIdx >= items.length)
              return pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.SizedBox(),
              );
            final item = items[targetIdx];
            String mark = '';
            if (!item.isNotApplicable && item.photoTargets.isNotEmpty) {
              mark =
                  item.photoTargets.first.status == ItemStatus.pass ? 'V' : 'X';
            }
            return pw.Padding(
              padding: const pw.EdgeInsets.all(3),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      item.title,
                      style: const pw.TextStyle(fontSize: 7),
                      maxLines: 1,
                    ),
                  ),
                  pw.Text(
                    '[ $mark ]',
                    style: pw.TextStyle(
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold,
                      color: mark == 'X' ? PdfColors.red800 : PdfColors.black,
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      }),
    );
  }

  static pw.Widget _buildAxleGridTable(
    String tableLabel,
    List<ComponentResult> rows,
    Map<String, String> details,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.8),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            color: PdfColors.grey700,
            width: double.infinity,
            padding: const pw.EdgeInsets.all(3),
            child: pw.Text(
              tableLabel,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(1.2),
              3: const pw.FlexColumnWidth(1.2),
              4: const pw.FlexColumnWidth(1.2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Text(
                      'Component Target',
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Text(
                      'LF',
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Text(
                      'RF',
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Text(
                      'LR',
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Text(
                      'RR',
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              ),
              ...rows.map((r) {
                String labelText = r.title.replaceAll(RegExp(r'.*:\s*'), '');
                String inputMetric = details[r.title] ?? '';
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(
                        labelText,
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(
                        inputMetric.isNotEmpty ? inputMetric : 'V',
                        style: const pw.TextStyle(fontSize: 7),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(
                        inputMetric.isNotEmpty ? inputMetric : 'V',
                        style: const pw.TextStyle(fontSize: 7),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(
                        inputMetric.isNotEmpty ? inputMetric : 'V',
                        style: const pw.TextStyle(fontSize: 7),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(
                        inputMetric.isNotEmpty ? inputMetric : 'V',
                        style: const pw.TextStyle(fontSize: 7),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildRecheckBlock(String title) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.8),
      ),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'To be examined again: YES [  ]  NO [  ]',
            style: const pw.TextStyle(fontSize: 8),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Technician: ____________________',
            style: const pw.TextStyle(fontSize: 8),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Branch: ____________________',
            style: const pw.TextStyle(fontSize: 8),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Date: ____________________',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMioFooter(String pageCode) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'MIO Approved by the Motor Industry Ombudsman of South Africa',
          style: pw.TextStyle(
            fontSize: 7,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          pageCode,
          style: pw.TextStyle(
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
      ],
    );
  }
}

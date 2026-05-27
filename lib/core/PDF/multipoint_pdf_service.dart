import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../modules/inspection/providers/inspection_provider.dart';
import '../../modules/inspection/models/inspection_models.dart';

class MultipointPDFService {
  static Future<Uint8List> generatePdfBytes(
    ActiveInspectionProvider provider,
  ) async {
    final pdf = pw.Document();
    final d = provider.vehicleDetails;

    final now = DateTime.now();
    d['Test Date'] =
        "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    List<String> fails = [];
    provider.sections.values.forEach((list) {
      for (var c in list) {
        if (!c.isNotApplicable &&
            c.photoTargets.isNotEmpty &&
            c.photoTargets.first.status == ItemStatus.fail) {
          fails.add("${c.title}: ${c.photoTargets.first.notes ?? 'No reason'}");
        }
      }
    });

    String finalRemarks = d['Remarks'] ?? '';
    if (fails.isNotEmpty) {
      finalRemarks += "\n\nFAILED ITEMS:\n- " + fails.join("\n- ");
    }

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

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          297 * PdfPageFormat.mm,
          210 * PdfPageFormat.mm,
          marginAll: 5,
        ),
        build: (pw.Context context) {
          return pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  children: [
                    pw.Expanded(
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              children: [
                                _buildSection(
                                  '01 IDENTIFICATION & DOCUMENTATION',
                                  provider.sections['01 IDENTIFICATION & DOCUMENTATION'] ??
                                      [],
                                  details: d,
                                ),
                                pw.SizedBox(height: 3),
                                _buildSection(
                                  '03 INTERIOR & EQUIPMENT',
                                  provider.sections['03 INTERIOR & EQUIPMENT'] ??
                                      [],
                                  details: d,
                                ),
                                pw.SizedBox(height: 3),
                                _buildSection(
                                  '08 ENGINE',
                                  provider.sections['08 ENGINE'] ?? [],
                                  details: d,
                                ),
                                pw.SizedBox(height: 3),
                                _buildSection(
                                  '12 DIMENSIONS',
                                  provider.sections['12 DIMENSIONS'] ?? [],
                                  isDimensions: true,
                                  details: d,
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 4),
                          pw.Expanded(
                            child: pw.Column(
                              children: [
                                _buildSection(
                                  '02 EXTERIOR & BODY',
                                  provider.sections['02 EXTERIOR & BODY'] ?? [],
                                  details: d,
                                ),
                                pw.SizedBox(height: 3),
                                _buildSection(
                                  '04 BRAKING SYSTEM',
                                  provider.sections['04 BRAKING SYSTEM'] ?? [],
                                  details: d,
                                ),
                                pw.SizedBox(height: 3),
                                _buildSection(
                                  '09 TRANSMISSION & DRIVE',
                                  provider.sections['09 TRANSMISSION & DRIVE'] ??
                                      [],
                                  details: d,
                                ),
                                pw.SizedBox(height: 3),
                                _buildSection(
                                  '13 STRUCTURAL DAMAGE',
                                  provider.sections['13 STRUCTURAL DAMAGE'] ??
                                      [],
                                  details: d,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Container(
                      height: 70,
                      child: pw.Row(
                        children: [
                          pw.Expanded(child: _buildExaminerBlock(d)),
                          pw.SizedBox(width: 4),
                          pw.Expanded(child: pw.SizedBox()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 4),
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey100,
                              border: pw.Border.all(
                                color: PdfColors.black,
                                width: 1.5,
                              ),
                            ),
                            child: pw.Column(
                              children: [
                                pw.SizedBox(height: 4),
                                pw.Row(
                                  children: [
                                    pw.SizedBox(width: 10),
                                    pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        if (logoRMI != null)
                                          pw.Image(logoRMI, height: 30),
                                        pw.SizedBox(height: 4),
                                        if (logoSABS != null)
                                          pw.Image(logoSABS, height: 30),
                                      ],
                                    ),
                                    pw.Expanded(
                                      child: pw.Center(
                                        child:
                                            logoBRC != null
                                                ? pw.Image(logoBRC, height: 85)
                                                : pw.SizedBox(),
                                      ),
                                    ),
                                  ],
                                ),
                                pw.SizedBox(height: 8),
                                pw.Container(
                                  color: PdfColors.grey800,
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Column(
                                    children: [
                                      _buildTopDetailRow(
                                        'CERTIFICATE NUMBER',
                                        d['Form Ref No'] ?? '0803',
                                        isRed: true,
                                      ),
                                      _buildTopDetailRow(
                                        'VEHICLE REGISTRATION NUMBER',
                                        d['Vehicle Registration No'],
                                      ),
                                      _buildTopDetailRow(
                                        'VEHICLE ENGINE NUMBER',
                                        d['Vehicle Engine Number'],
                                      ),
                                      _buildTopDetailRow(
                                        'VEHICLE VIN / CHASSIS NUMBER',
                                        d['Vehicle VIN Chassis Number'],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 4),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            height: 130,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              border: pw.Border.all(
                                color: PdfColor.fromHex('#FFD700'),
                                width: 2,
                              ),
                            ),
                            alignment: pw.Alignment.center,
                            child:
                                logoAA != null
                                    ? pw.Image(logoAA, fit: pw.BoxFit.contain)
                                    : pw.Text(
                                      'AA APPROVED',
                                      style: pw.TextStyle(
                                        color: PdfColors.black,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 3),
                    pw.Expanded(
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              children: [
                                _buildSection(
                                  '05 SUSPENSION & UNDERCARRIAGE',
                                  provider.sections['05 SUSPENSION & UNDERCARRIAGE'] ??
                                      [],
                                  details: d,
                                ),
                                pw.SizedBox(height: 3),
                                _buildSection(
                                  '10 ELECTRICAL SYSTEM',
                                  provider.sections['10 ELECTRICAL SYSTEM'] ??
                                      [],
                                  details: d,
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 4),
                          pw.Expanded(
                            child: pw.Column(
                              children: [
                                _buildSection(
                                  '06 WHEELS & TYRES',
                                  provider.sections['06 WHEELS & TYRES'] ?? [],
                                  details: d,
                                ),
                                pw.SizedBox(height: 3),
                                _buildSection(
                                  '11 BODY & STRUCTURAL',
                                  provider.sections['11 BODY & STRUCTURAL'] ??
                                      [],
                                  details: d,
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 4),
                          pw.Expanded(
                            child: pw.Column(
                              children: [
                                _buildSection(
                                  '07 STEERING',
                                  provider.sections['07 STEERING'] ?? [],
                                  details: d,
                                ),
                                pw.SizedBox(height: 3),
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(6),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.black,
                                    border: pw.Border.all(
                                      color: PdfColors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      _buildDarkSideLabel(
                                        'OWNER / SURNAME & INITIALS',
                                        d['Owner Surname & Initials'],
                                      ),
                                      _buildDarkSideLabel(
                                        'VEHICLE MODEL',
                                        d['Vehicle Model'],
                                      ),
                                      _buildDarkSideLabel(
                                        'VEHICLE MAKE',
                                        d['Vehicle Make'],
                                      ),
                                      _buildDarkSideLabel(
                                        'VEHICLE REGISTRATION NO.',
                                        d['Vehicle Registration No'],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Container(
                      height: 70,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColors.black,
                          width: 1.5,
                        ),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'REMARKS / ADDITIONAL COMMENTS',
                                    style: pw.TextStyle(
                                      fontSize: 6,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.SizedBox(height: 2),
                                  pw.Text(
                                    finalRemarks,
                                    style: pw.TextStyle(
                                      fontSize: 5,
                                      color:
                                          fails.isNotEmpty
                                              ? PdfColors.red800
                                              : PdfColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          pw.Container(width: 1, color: PdfColors.black),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    'TEST DATE: ${d['Test Date'] ?? ''}',
                                    style: const pw.TextStyle(fontSize: 5),
                                  ),
                                ),
                                pw.Divider(thickness: 0.5),
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    'TESTED BY / INSPECTOR: ${d['Examiner Name'] ?? ''}',
                                    style: const pw.TextStyle(fontSize: 5),
                                  ),
                                ),
                                pw.Divider(thickness: 0.5),
                                pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  child: pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        'PASS [  ]',
                                        style: const pw.TextStyle(fontSize: 5),
                                      ),
                                      pw.Text(
                                        'RE-TEST [  ]',
                                        style: const pw.TextStyle(fontSize: 5),
                                      ),
                                      pw.Text(
                                        'FAIL [  ]',
                                        style: const pw.TextStyle(fontSize: 5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

    return await pdf.save();
  }

  static pw.Widget _buildExaminerBlock(Map<String, String> d) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.0),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Text(
            'EXAMINER NAME: ${d['Examiner Name'] ?? ''}',
            style: pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold),
          ),
          pw.Container(height: 0.5, color: PdfColors.black),
          pw.Text(
            'EXAMINER NUMBER: ${d['Examiner Number'] ?? ''}',
            style: pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold),
          ),
          pw.Container(height: 0.5, color: PdfColors.black),
          pw.Text(
            'SIGNATURE:',
            style: pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold),
          ),
          pw.Container(height: 0.5, color: PdfColors.black),
          pw.Text(
            'REMARKS:',
            style: pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold),
          ),
          pw.Container(height: 0.5, color: PdfColors.black),
        ],
      ),
    );
  }

  static pw.Widget _buildSection(
    String title,
    List<ComponentResult> items, {
    bool hasCheckboxes = true,
    bool isDimensions = false,
    Map<String, String>? details,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.0),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            color: PdfColors.black,
            padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            width: double.infinity,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                color: PdfColor.fromHex('#FFD700'),
                fontSize: 6,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            int index = entry.key;
            ComponentResult comp = entry.value;

            String indicator = '';
            if (isDimensions && details != null) {
              String val = details[comp.title] ?? '';
              if (comp.photoTargets.isNotEmpty &&
                  comp.photoTargets.first.status == ItemStatus.pass)
                val += " (V)";
              if (comp.photoTargets.isNotEmpty &&
                  comp.photoTargets.first.status == ItemStatus.fail)
                val += " (X)";
              indicator = val;
            } else if (comp.photoTargets.isNotEmpty) {
              if (comp.isNotApplicable ||
                  comp.photoTargets.first.status == ItemStatus.na)
                indicator = '/';
              else if (comp.photoTargets.first.status == ItemStatus.pass)
                indicator = 'V';
              else if (comp.photoTargets.first.status == ItemStatus.fail)
                indicator = 'X';
            }

            return pw.Container(
              height: 12,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
                ),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 4),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      comp.title,
                      style: const pw.TextStyle(
                        fontSize: 5.5,
                        color: PdfColors.black,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  if (hasCheckboxes || isDimensions)
                    pw.Container(
                      width: isDimensions ? 30 : 9,
                      height: 9,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColors.black,
                          width: 0.5,
                        ),
                        color: PdfColors.white,
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        indicator,
                        style: pw.TextStyle(
                          fontSize: isDimensions ? 4.5 : 6,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                        maxLines: 1,
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

  static pw.Widget _buildTopDetailRow(
    String label,
    String? value, {
    bool isRed = false,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Container(
              padding: const pw.EdgeInsets.only(left: 2),
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 5,
                  fontWeight: isRed ? pw.FontWeight.bold : pw.FontWeight.normal,
                ),
              ),
            ),
          ),
          pw.Expanded(
            flex: 4,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                border: pw.Border.all(color: PdfColors.black, width: 0.5),
              ),
              height: 11,
              padding: const pw.EdgeInsets.symmetric(horizontal: 4),
              alignment: pw.Alignment.center,
              child: pw.Text(
                value ?? '',
                style: pw.TextStyle(
                  color: isRed ? PdfColors.red800 : PdfColors.black,
                  fontSize: isRed ? 8 : 6.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDarkSideLabel(String label, String? value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 6,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: PdfColors.black, width: 0.5),
            ),
            height: 14,
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 4),
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              value ?? '',
              style: pw.TextStyle(
                color: PdfColors.black,
                fontSize: 7.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

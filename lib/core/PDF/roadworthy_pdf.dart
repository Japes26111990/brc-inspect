import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../modules/inspection/models/inspection_models.dart';
import '../../modules/inspection/providers/inspection_provider.dart';

import 'roadworthy_sections.dart';

enum RoadworthyOutcome {
  pass,
  retest,
  fail,
}

class RoadworthyPDF {
  static Future<pw.Document> generate(
    ActiveInspectionProvider provider,
  ) async {
    final pdf = pw.Document();

    final PdfColor blue =
        PdfColor.fromHex('#1E3A5F');

    final PdfColor border =
        PdfColor.fromHex('#B8C2CC');

    final PdfColor light =
        PdfColor.fromHex('#F4F7FA');

    final outcome =
        _calculateOutcome(provider);

    pw.MemoryImage? logo;

    try {
      final ByteData data = await rootBundle.load(
        'assets/logos/brc_logo.png',
      );

      logo = pw.MemoryImage(
        data.buffer.asUint8List(),
      );
    } catch (_) {}

    /// PAGE 1
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,

        margin: const pw.EdgeInsets.all(10),

        build: (context) {
          return [
            pw.Row(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,

              children: [
                /// LEFT PANEL
                pw.Container(
                  width: 110,

                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: blue,
                      width: 1,
                    ),
                  ),

                  child: pw.Column(
                    children: [
                      pw.Container(
                        width: double.infinity,
                        color: blue,
                        padding:
                            const pw.EdgeInsets.all(
                          6,
                        ),

                        child: pw.Center(
                          child: pw.Text(
                            'ROADWORTHY',

                            style: pw.TextStyle(
                              color:
                                  PdfColors.white,
                              fontSize: 12,
                              fontWeight: pw
                                  .FontWeight
                                  .bold,
                            ),
                          ),
                        ),
                      ),

                      if (logo != null)
                        pw.Padding(
                          padding:
                              const pw.EdgeInsets
                                  .all(8),

                          child: pw.Image(
                            logo,
                            height: 40,
                          ),
                        ),

                      _leftField(
                        'MAKE',
                        provider.vehicleDetails[
                                'Manufacturer'] ??
                            '',
                      ),

                      _leftField(
                        'MODEL',
                        provider.vehicleDetails[
                                'Model'] ??
                            '',
                      ),

                      _leftField(
                        'YEAR',
                        provider.vehicleDetails[
                                'Year Model'] ??
                            '',
                      ),

                      _leftField(
                        'REG',
                        provider.vehicleDetails[
                                'Registration Number'] ??
                            '',
                      ),

                      _leftField(
                        'ODO',
                        provider.vehicleDetails[
                                'Odometer Reading'] ??
                            '',
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(width: 8),

                /// MATRIX
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      _buildTopResultBar(
                        provider,
                        outcome,
                        blue,
                        border,
                      ),

                      pw.SizedBox(height: 6),

                      ...roadworthySections.map(
                        (section) {
                          return _buildSection(
                            provider,
                            section,
                            blue,
                            border,
                            light,
                          );
                        },
                      ),

                      pw.SizedBox(height: 8),

                      _buildBottomSignatures(
                        border,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    /// PAGE 2+
    final evidenceWidgets =
        await _buildEvidencePages(
      provider,
      blue,
      border,
      light,
    );

    if (evidenceWidgets.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,

          margin:
              const pw.EdgeInsets.all(20),

          build: (context) {
            return evidenceWidgets;
          },
        ),
      );
    }

    return pdf;
  }

  static RoadworthyOutcome
      _calculateOutcome(
    ActiveInspectionProvider provider,
  ) {
    bool hasRetest = false;

    for (final section
        in provider.sections.values) {
      for (final item in section) {
        if (!item.isRoadworthyRelevant) {
          continue;
        }

        if (item.finalStatus ==
            ItemStatus.fail) {
          return RoadworthyOutcome.fail;
        }

        if (item.finalStatus ==
            ItemStatus.attention) {
          hasRetest = true;
        }
      }
    }

    if (hasRetest) {
      return RoadworthyOutcome.retest;
    }

    return RoadworthyOutcome.pass;
  }

  static Future<List<pw.Widget>>
      _buildEvidencePages(
    ActiveInspectionProvider provider,
    PdfColor blue,
    PdfColor border,
    PdfColor light,
  ) async {
    final List<pw.Widget> widgets = [];

    widgets.add(
      pw.Text(
        'INSPECTION COMMENTS & EVIDENCE',

        style: pw.TextStyle(
          fontSize: 16,
          fontWeight:
              pw.FontWeight.bold,
          color: blue,
        ),
      ),
    );

    widgets.add(
      pw.SizedBox(height: 14),
    );

    for (final section
        in provider.sections.entries) {
      final components =
          section.value.where((c) {
        return c.finalStatus !=
            ItemStatus.pass;
      }).toList();

      if (components.isEmpty) {
        continue;
      }

      widgets.add(
        pw.Container(
          width: double.infinity,

          padding:
              const pw.EdgeInsets.all(8),

          color: blue,

          child: pw.Text(
            section.key.toUpperCase(),

            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight:
                  pw.FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      );

      widgets.add(
        pw.SizedBox(height: 10),
      );

      for (final component
          in components) {
        widgets.add(
          _buildEvidenceCard(
            component,
            border,
            light,
          ),
        );

        widgets.add(
          pw.SizedBox(height: 14),
        );
      }
    }

    return widgets;
  }

  static pw.Widget _buildEvidenceCard(
    ComponentResult component,
    PdfColor border,
    PdfColor light,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),

      decoration: pw.BoxDecoration(
        color: light,

        border: pw.Border.all(
          color: border,
          width: 0.8,
        ),
      ),

      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,

        children: [
          pw.Row(
            mainAxisAlignment:
                pw.MainAxisAlignment
                    .spaceBetween,

            children: [
              pw.Text(
                component.title
                    .toUpperCase(),

                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),

              pw.Text(
                component.finalStatus.name
                    .toUpperCase(),

                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 8),

          if (component
              .aggregatedNotes
              .isNotEmpty)
            pw.Text(
              component
                  .aggregatedNotes,

              style:
                  const pw.TextStyle(
                fontSize: 8,
              ),
            ),

          pw.SizedBox(height: 10),

          pw.Wrap(
            spacing: 10,
            runSpacing: 10,

            children: component
                .photoTargets
                .where(
                  (p) =>
                      p.photoPath !=
                      null,
                )
                .map((photo) {
              try {
                if (kIsWeb) {
                  return pw.SizedBox();
                }

                return pw.Container(
                  width: 180,

                  child: pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment
                            .start,

                    children: [
                      pw.Container(
                        height: 120,

                        child: pw.Image(
                          pw.MemoryImage(
                            File(photo
                                    .photoPath!)
                                .readAsBytesSync(),
                          ),
                          fit:
                              pw.BoxFit.cover,
                        ),
                      ),

                      pw.SizedBox(height: 4),

                      pw.Text(
                        photo.label,

                        style:
                            const pw.TextStyle(
                          fontSize: 7,
                        ),
                      ),

                      if (photo.notes
                          .isNotEmpty)
                        pw.Text(
                          photo.notes,

                          style:
                              const pw.TextStyle(
                            fontSize: 7,
                          ),
                        ),
                    ],
                  ),
                );
              } catch (_) {
                return pw.SizedBox();
              }
            }).toList(),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTopResultBar(
    ActiveInspectionProvider provider,
    RoadworthyOutcome outcome,
    PdfColor blue,
    PdfColor border,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: border,
        width: 0.7,
      ),

      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(2),
      },

      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: blue,
          ),

          children: [
            _header('TEST DATE'),
            _header('PASS'),
            _header('RETEST'),
            _header('FAIL'),
            _header('EXAMINER'),
            _header('REMARKS'),
          ],
        ),

        pw.TableRow(
          children: [
            _cell(''),

            _centerCell(
              outcome ==
                      RoadworthyOutcome
                          .pass
                  ? '✔'
                  : '',
            ),

            _centerCell(
              outcome ==
                      RoadworthyOutcome
                          .retest
                  ? '✔'
                  : '',
            ),

            _centerCell(
              outcome ==
                      RoadworthyOutcome
                          .fail
                  ? '✔'
                  : '',
            ),

            _cell(
              provider.vehicleDetails[
                      'Inspector Name'] ??
                  '',
            ),

            _cell(''),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSection(
    ActiveInspectionProvider provider,
    RoadworthySection section,
    PdfColor blue,
    PdfColor border,
    PdfColor light,
  ) {
    return pw.Container(
      margin:
          const pw.EdgeInsets.only(
        bottom: 5,
      ),

      child: pw.Table(
        border: pw.TableBorder.all(
          color: border,
          width: 0.5,
        ),

        columnWidths: {
          0: const pw.FlexColumnWidth(5),
          1: const pw.FlexColumnWidth(1),
          2: const pw.FlexColumnWidth(1),
          3: const pw.FlexColumnWidth(1),
        },

        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: blue,
            ),

            children: [
              pw.Padding(
                padding:
                    const pw.EdgeInsets.all(
                  4,
                ),

                child: pw.Text(
                  section.title,

                  style: pw.TextStyle(
                    color:
                        PdfColors.white,
                    fontSize: 7,
                    fontWeight: pw
                        .FontWeight
                        .bold,
                  ),
                ),
              ),

              _header('PASS'),
              _header('RETEST'),
              _header('FAIL'),
            ],
          ),

          ...section.items.map(
            (title) {
              final item =
                  _findComponent(
                provider,
                title,
              );

              final status =
                  item?.finalStatus ??
                      ItemStatus.na;

              final bool pass =
                  status ==
                      ItemStatus.pass;

              final bool retest =
                  status ==
                      ItemStatus.attention;

              final bool fail =
                  status ==
                      ItemStatus.fail;

              return pw.TableRow(
                decoration:
                    pw.BoxDecoration(
                  color: light,
                ),

                children: [
                  _cell(title),

                  _centerCell(
                    pass ? '✔' : '',
                  ),

                  _centerCell(
                    retest ? '✔' : '',
                  ),

                  _centerCell(
                    fail ? '✔' : '',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static ComponentResult?
      _findComponent(
    ActiveInspectionProvider provider,
    String title,
  ) {
    for (final section
        in provider.sections.values) {
      for (final item in section) {
        if (item.title == title) {
          return item;
        }
      }
    }

    return null;
  }

  static pw.Widget _buildBottomSignatures(
    PdfColor border,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: border,
        width: 0.7,
      ),

      children: [
        pw.TableRow(
          children: [
            _signatureBox(
              'EXAMINER NAME',
            ),
            _signatureBox(
              'SIGNATURE',
            ),
            _signatureBox(
              'DATE',
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _signatureBox(
    String title,
  ) {
    return pw.Container(
      height: 40,

      padding: const pw.EdgeInsets.all(
        4,
      ),

      child: pw.Align(
        alignment:
            pw.Alignment.topLeft,

        child: pw.Text(
          title,

          style: pw.TextStyle(
            fontSize: 7,
            fontWeight:
                pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static pw.Widget _leftField(
    String label, [
    String value = '',
  ]) {
    return pw.Container(
      width: double.infinity,

      padding: const pw.EdgeInsets.all(
        4,
      ),

      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey400,
            width: 0.5,
          ),
        ),
      ),

      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,

        children: [
          pw.Text(
            label,

            style: pw.TextStyle(
              fontSize: 6,
              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 2),

          pw.Text(
            value,

            style: const pw.TextStyle(
              fontSize: 7,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _header(
    String text,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(
        4,
      ),

      child: pw.Center(
        child: pw.Text(
          text,

          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 6,
            fontWeight:
                pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static pw.Widget _cell(
    String text,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(
        3,
      ),

      child: pw.Text(
        text,

        style: const pw.TextStyle(
          fontSize: 6.5,
        ),
      ),
    );
  }

  static pw.Widget _centerCell(
    String text,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(
        3,
      ),

      child: pw.Center(
        child: pw.Text(
          text,

          style: pw.TextStyle(
            fontSize: 8,
            fontWeight:
                pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
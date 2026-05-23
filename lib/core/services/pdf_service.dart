import 'dart:io';
import 'package:flutter/foundation.dart';
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
    
    // 🚀 1. TRACK CONTEXT LABELS AND COLORS SEPARATELY FOR ALL 3 MODES
    String documentHeaderTitle = 'VEHICLE DISCLOSURE MANIFEST';
    String verdict = '';
    late PdfColor statusColor;
    late PdfColor statusBg;

    if (provider.activeType == InspectionType.roadworthy) {
      documentHeaderTitle = 'ROADWORTHY COMPLIANCE REPORT';
      verdict = passesOverall ? 'PASSED - ROADWORTHY COMPLIANT' : 'FAILED - NOT ROADWORTHY';
      statusColor = passesOverall ? PdfColor.fromHex('#10B981') : PdfColor.fromHex('#EF4444'); 
      statusBg = passesOverall ? PdfColor.fromHex('#F0FDF4') : PdfColor.fromHex('#FEF2F2');
    } 
    else if (provider.activeType == InspectionType.fleet) {
      documentHeaderTitle = 'FLEET OPERATIONAL RISK AUDIT';
      verdict = passesOverall ? 'PASSED - FLEET SAFETY APPROVAL' : 'FAILED - FLEET SERVICE REJECT';
      statusColor = passesOverall ? PdfColor.fromHex('#0EA5E9') : PdfColor.fromHex('#EF4444'); 
      statusBg = passesOverall ? PdfColor.fromHex('#F0F9FF') : PdfColor.fromHex('#FEF2F2');
    } 
    else {
      // Default Fallback: Vehicle Condition Report
      documentHeaderTitle = 'VEHICLE CONDITION DISCLOSURE MANIFEST';
      verdict = 'COMPLETED VEHICLE DISCLOSURE AUDIT';
      statusColor = PdfColor.fromHex('#D4AF37'); 
      statusBg = PdfColor.fromHex('#FDFBF7');
    }
    
    final PdfColor brandGold = PdfColor.fromHex('#D4AF37');     
    final PdfColor spaceCarbon = PdfColor.fromHex('#0F172A');   
    final PdfColor structuralGrey = PdfColor.fromHex('#64748B'); 
    final PdfColor surfaceCard = PdfColor.fromHex('#F8FAFC');    

    pw.MemoryImage? brandingLogo;
    try {
      final ByteData assetData = await rootBundle.load('assets/logos/brc_logo.png');
      brandingLogo = pw.MemoryImage(assetData.buffer.asUint8List());
    } catch (_) {}

    pw.MemoryImage? webFallback;
    if (kIsWeb) {
      try {
        final ByteData fallbackData = await rootBundle.load('assets/logos/brc_logo.png');
        webFallback = pw.MemoryImage(fallbackData.buffer.asUint8List());
      } catch (_) {}
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (brandingLogo != null) 
                    pw.Image(brandingLogo, height: 38) 
                  else 
                    pw.Text('BRC INSPECT', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: brandGold, letterSpacing: 0.5)),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(documentHeaderTitle, style: pw.TextStyle(fontSize: 11, color: spaceCarbon, fontWeight: pw.FontWeight.bold, letterSpacing: 0.5)),
                      pw.Text('REF TRACKER: ${provider.vehicleDetails['Odometer Reading'] ?? 'N/A'}', style: pw.TextStyle(fontSize: 8.5, color: structuralGrey, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(color: brandGold, thickness: 1),
              pw.SizedBox(height: 12),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 14),
            child: pw.Text('SYSTEM SECURITY VERIFICATION MANIFEST • Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(color: structuralGrey, fontSize: 8)),
          );
        },
        build: (pw.Context context) {
          return [
            // 🚀 2. DYNAMICALLY RENDERED STATUS BANNER
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: pw.BoxDecoration(
                color: statusBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                border: pw.Border.all(color: statusColor, width: 0.5),
              ),
              child: pw.Center(
                child: pw.Text(verdict, style: pw.TextStyle(color: statusColor, fontSize: 13, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
              ),
            ),
            pw.SizedBox(height: 20),

            // CORE PARAMETERS LIST
            pw.Text('CORE PARAMETER TELEMETRY DATA MAP', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: spaceCarbon, letterSpacing: 0.5)),
            pw.SizedBox(height: 6),
            _buildManifestDetailsTable(provider, surfaceCard, spaceCarbon),
            pw.SizedBox(height: 24),

            // FLOWING CATEGORIES
            ...provider.sections.entries.map((entry) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 12, bottom: 6),
                    child: pw.Text(entry.key.toUpperCase(), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: brandGold, letterSpacing: 0.5)),
                  ),
                  ...entry.value.map((component) {
                    if (component.isNotApplicable) {
                      return pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        margin: const pw.EdgeInsets.only(bottom: 4),
                        color: PdfColors.grey100,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(component.title, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                            pw.Text('NOT APPLICABLE (N/A)', style: pw.TextStyle(fontSize: 7.5, color: PdfColors.grey500, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      );
                    }

                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.all(4),
                            color: spaceCarbon,
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(component.title.toUpperCase(), style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                                pw.Text('VERDICT: ${component.finalStatus.name.toUpperCase()}', style: pw.TextStyle(color: component.finalStatus == ItemStatus.fail ? PdfColors.red300 : PdfColors.white, fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                              ],
                            ),
                          ),
                          ...component.photoTargets.map((target) {
                            return pw.Container(
                              padding: const pw.EdgeInsets.all(6),
                              color: surfaceCard,
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text('• ${target.label}', style: pw.TextStyle(fontSize: 8, color: spaceCarbon, fontWeight: pw.FontWeight.bold)),
                                        pw.SizedBox(height: 2),
                                        pw.Text(target.notes.isEmpty ? 'Component verified within nominal tolerances.' : target.notes, style: pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                                      ],
                                    ),
                                  ),
                                  pw.SizedBox(width: 12),
                                  if (target.photoPath != null && !kIsWeb)
                                    pw.Container(
                                      width: 85, height: 60,
                                      child: pw.ClipRRect(
                                        horizontalRadius: 4, verticalRadius: 4,
                                        child: pw.Image(pw.MemoryImage(File(target.photoPath!).readAsBytesSync()), fit: pw.BoxFit.cover),
                                      ),
                                    )
                                  else if (target.photoPath != null && kIsWeb && webFallback != null)
                                    pw.Container(
                                      width: 85, height: 60,
                                      child: pw.ClipRRect(
                                        horizontalRadius: 4, verticalRadius: 4,
                                        child: pw.Image(webFallback, fit: pw.BoxFit.cover),
                                      ),
                                    )
                                  else
                                    pw.SizedBox.shrink(),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
            
            pw.SizedBox(height: 16),
            pw.Text('TYRE SPECIFICATION DATA INDEX', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: brandGold, letterSpacing: 0.5)),
            pw.SizedBox(height: 6),
            _buildAdvancedTyreTable(provider.tyres, spaceCarbon, surfaceCard),

            // TYRES VISUAL PROOF GALLERY
            pw.SizedBox(height: 14),
            pw.Text('TYRES VISUAL PROOF GALLERY', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: spaceCarbon, letterSpacing: 0.5)),
            pw.SizedBox(height: 6),
            pw.Wrap(
              spacing: 10,
              runSpacing: 10,
              children: provider.tyres.where((t) => t.photoPath != null).map((t) {
                return pw.Container(
                  width: 110,
                  padding: const pw.EdgeInsets.all(4),
                  color: surfaceCard,
                  child: pw.Column(
                    children: [
                      if (!kIsWeb)
                        pw.Image(pw.MemoryImage(File(t.photoPath!).readAsBytesSync()), width: 100, height: 75, fit: pw.BoxFit.cover)
                      else if (kIsWeb && webFallback != null)
                        pw.Image(webFallback, width: 100, height: 75, fit: pw.BoxFit.cover),
                      pw.SizedBox(height: 3),
                      pw.Text(t.position.toUpperCase(), style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: spaceCarbon)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'BRC_Telemetry_Manifest_${provider.vehicleDetails['Registration Number'] ?? 'SYS'}.pdf',
    );
  }

  static pw.Widget _buildManifestDetailsTable(ActiveInspectionProvider provider, PdfColor bg, PdfColor text) {
    final Map<String, dynamic> d = provider.vehicleDetails;
    return pw.TableHelper.fromTextArray(
      cellAlignment: pw.Alignment.centerLeft,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8),
      headerDecoration: pw.BoxDecoration(color: text),
      cellStyle: pw.TextStyle(fontSize: 8, color: text),
      oddRowDecoration: pw.BoxDecoration(color: bg),
      border: const pw.TableBorder(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
      data: <List<String>>[
        ['VEHICLE TYPE', (d['Vehicle Type'] ?? 'N/A').toUpperCase(), 'STOCK NUMBER', (d['Stock Number'] ?? 'N/A').toUpperCase()],
        ['MANUFACTURER', (d['Manufacturer'] ?? 'N/A').toUpperCase(), 'MODEL VARIANT', (d['Model'] ?? 'N/A').toUpperCase()],
        ['YEAR SPEC FRAME', (d['Year Model'] ?? 'N/A').toUpperCase(), 'RUN-TIME ODOMETER', '${d['Odometer Reading'] ?? 'N/A'} KM'],
        ['TRANSMISSION DRIVE', (d['Transmission'] ?? 'N/A').toUpperCase(), 'FUEL SELECTION CORE', (d['Fuel Type'] ?? 'N/A').toUpperCase()],
      ],
    );
  }

  static pw.Widget _buildAdvancedTyreTable(List<TyreResult> tyres, PdfColor mainText, PdfColor cardBg) {
    List<List<String>> rows = [
      ['WHEEL HUB LOCATION', 'DIMENSIONS SIZE', 'LOAD/SPEED INDEX', 'MANUFACTURER BRAND', 'TREAD VALUE MM', 'EVAL VERDICT']
    ];

    for (var t in tyres) {
      String displayedDepth = t.treadDepthMm == -1 ? 'UNCHECKED' : '${t.treadDepthMm} MM';
      rows.add([
        t.position.toUpperCase(),
        t.size.isEmpty || t.size.contains('Select') ? 'UNTRACKED' : t.size.toUpperCase(),
        t.loadSpeedIndex.isEmpty || t.loadSpeedIndex.contains('Select') ? 'UNTRACKED' : t.loadSpeedIndex.toUpperCase(),
        t.make.isEmpty || t.make.contains('Select') ? 'UNTRACKED' : t.make.toUpperCase(),
        displayedDepth,
        t.status == ItemStatus.na ? 'PENDING' : t.status.name.toUpperCase()
      ]);
    }

    return pw.TableHelper.fromTextArray(
      headers: rows.first,
      data: rows.sublist(1),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8),
      headerDecoration: pw.BoxDecoration(color: mainText),
      oddRowDecoration: pw.BoxDecoration(color: cardBg),
      cellStyle: pw.TextStyle(fontSize: 8, color: mainText),
      border: const pw.TableBorder(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
    );
  }
}
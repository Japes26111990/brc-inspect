import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../theme/app_colors.dart';

class LicenseScannerScreen extends StatefulWidget {
  const LicenseScannerScreen({super.key});

  @override
  State<LicenseScannerScreen> createState() => _LicenseScannerScreenState();
}

class _LicenseScannerScreenState extends State<LicenseScannerScreen> {
  bool _isProcessing = false;

  final MobileScannerController cameraController = MobileScannerController(
    formats: const [BarcodeFormat.pdf417, BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
  );

  void _processBarcode(BarcodeCapture capture) {
    if (_isProcessing) return; 
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() => _isProcessing = true);
      
      String rawData = barcodes.first.rawValue!;
      
      // Split clean dataset using NaTIS (%) token delimiter
      List<String> diskData = rawData.split('%').map((e) => e.trim()).toList();
      
      Map<String, String> extractedData = {
        'Registration Number': '',
        'VIN Number': '',
        'Make': '',
        'Model': '',
        'Colour': '',
        'Engine Number': '',
      };
      
      if (diskData.length > 5) {
        // 1. REGISTRATION ASSIGNMENT
        if (diskData.length > 6) {
          extractedData['Registration Number'] = diskData[6];
        }

        // 2. OPEN VIN & ENGINE PATTERN MATCHING (Handles 17-21 commercial chars safely)
        for (String item in diskData) {
          String upperItem = item.toUpperCase();
          
          // Official ISO standard VIN formats can be appended with up to 4 trailing registration sequence digits by NaTIS
          if (upperItem.length >= 13 && upperItem.length <= 22 && RegExp(r'^[A-Z0-9]{13,22}$').hasMatch(upperItem)) {
            // Avoid selecting strings that match common vehicle manufacturer tokens
            if (!upperItem.contains('FORD') && !upperItem.contains('NISSAN') && !upperItem.contains('TOYOTA') && !upperItem.contains('BAKKIE')) {
              // Shorter string is likely the Engine code, longer or starting with alpha characters is the VIN
              if (extractedData['VIN Number']!.isEmpty || upperItem.length > extractedData['VIN Number']!.length) {
                extractedData['VIN Number'] = item;
              }
            }
          }
        }

        // 3. TARGETED MAKE & FALLBACK SHIFT PATTERNS
        for (int i = 0; i < diskData.length; i++) {
          String val = diskData[i].toUpperCase();
          if (val == 'NISSAN' || val == 'TOYOTA' || val == 'BMW' || val == 'VOLKSWAGEN' || val == 'FORD') {
            extractedData['Make'] = diskData[i];
            
            // On SA commercial records, the body type 'Pick-up / Bakkie' sits at index + 1 relative to Make
            if (i + 1 < diskData.length && diskData[i + 1].length >= 4) {
              String bodyType = diskData[i + 1];
              if (!bodyType.contains('%') && bodyType.toUpperCase() != extractedData['VIN Number']?.toUpperCase()) {
                extractedData['Model'] = bodyType; // Serves as perfect structural descriptive fallback
              }
            }
          }
        }

        // Clean secondary sweep loop to find Engine Numbers that don't match the captured VIN
        for (String item in diskData) {
          String upperItem = item.toUpperCase();
          if (upperItem.length >= 10 && RegExp(r'^[A-Z0-9]{10,18}$').hasMatch(upperItem)) {
            if (item != extractedData['VIN Number'] && upperItem != extractedData['Make'] && !upperItem.contains('BAKKIE')) {
              extractedData['Engine Number'] = item;
              break;
            }
          }
        }

        // Standard structural safety fallbacks
        if ((extractedData['Make']?.isEmpty ?? true) && diskData.length > 8) extractedData['Make'] = diskData[8];
        if ((extractedData['VIN Number']?.isEmpty ?? true) && diskData.length > 10) extractedData['VIN Number'] = diskData[10];
        if ((extractedData['Engine Number']?.isEmpty ?? true) && diskData.length > 11) extractedData['Engine Number'] = diskData[11];
        
      } else {
        extractedData['Registration Number'] = rawData;
      }

      Navigator.pop(context, extractedData);
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double boxSize = screenSize.width < 400 ? 260 : 300;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Scan License Disk', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _processBarcode,
          ),
          Center(
            child: Container(
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gold, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            bottom: screenSize.height * 0.08,
            left: 24,
            right: 24,
            child: const Text(
              'Align the SA License Disk Barcode inside the frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          )
        ],
      ),
    );
  }
}
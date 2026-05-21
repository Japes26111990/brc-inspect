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

  void _processBarcode(BarcodeCapture capture) {
    if (_isProcessing) return; // Prevent multiple scans at once
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() => _isProcessing = true);
      
      String rawData = barcodes.first.rawValue!;
      
      // South African License Disks separate data using the '%' symbol.
      // Standard format usually has Registration at index 5 or 6, VIN at index 7 or 8.
      // Note: This is a basic parser. We may need to tweak the indexes based on your specific test disks.
      List<String> diskData = rawData.split('%');
      
      Map<String, String> extractedData = {};
      
      if (diskData.length > 10) {
        // Attempting standard SA Disk extraction
        extractedData['Registration Number'] = diskData[6].trim();
        extractedData['Make'] = diskData[7].trim();
        extractedData['Model'] = diskData[8].trim();
        extractedData['Colour'] = diskData[9].trim();
        extractedData['VIN Number'] = diskData[10].trim();
        extractedData['Engine Number'] = diskData[11].trim(); 
      } else {
        // Fallback if the format is weird
        extractedData['Raw'] = rawData;
      }

      // Return the data to the previous screen
      Navigator.pop(context, extractedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Scan License Disk', style: TextStyle(color: AppColors.gold)),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _processBarcode,
          ),
          // A simple targeting overlay
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gold, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              'Align the SA License Disk Barcode inside the frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
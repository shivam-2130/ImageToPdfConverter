// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:pdf_generator/services/ad_mob_service.dart';
import 'package:pdf_generator/controllers/save.dart'; // Assuming save.dart contains the savePDF function

class PDFPreviewScreen extends StatefulWidget {
  final File pdfFile;
  final VoidCallback onSave;

  PDFPreviewScreen({
    Key? key,
    required this.pdfFile,
    required this.onSave,
  }) : super(key: key);

  @override
  State<PDFPreviewScreen> createState() => _PDFPreviewScreenState();
}

class _PDFPreviewScreenState extends State<PDFPreviewScreen> {
  InterstitialAd? _interstitialAd;

  Future<void> requestStoragePermission(BuildContext context) async {
    var status = await Permission.manageExternalStorage.request();

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Storage permission denied")),
      );
    } else {
      showSaveDialog(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _createInterstitalAd();
  }

  void _createInterstitalAd() {
    InterstitialAd.load(
        adUnitId: AdMobService.interstitialAdUnitId!,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) => _interstitialAd = ad,
          onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null,
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _createInterstitalAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _createInterstitalAd();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void showSaveDialog(BuildContext context) {
    String defaultFileName = "doc_${DateTime.now().millisecondsSinceEpoch}";
    TextEditingController fileNameController =
        TextEditingController(text: defaultFileName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enter File Name"),
        content: TextField(
          controller: fileNameController,
          decoration: InputDecoration(hintText: "Enter file name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              String fileName = fileNameController.text.trim();
              if (fileName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please enter the name of the file")),
                );
                return;
              }

              Navigator.pop(context); // Close the dialog first

              await savePDF(context, widget.pdfFile, fileName);

              // Show Snackbar immediately before the page is popped
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("PDF saved successfully!")),
              );

              // Pop the PDF preview screen
              Navigator.pop(context, true);

              // Play interstitial ad after everything else
              Future.delayed(Duration(milliseconds: 500), _showInterstitialAd);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PDF Preview')),
      body: SizedBox.expand(
        child: PDFView(
          filePath: widget.pdfFile.path,
          fitPolicy: FitPolicy.BOTH, // Stretches PDF pages to fit
          pageSnap: false, // Removes snapping behavior
          pageFling: false, // Prevents page flinging
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => requestStoragePermission(context),
        label: Text("Save PDF"),
        icon: Icon(Icons.save),
      ),
    );
  }
}

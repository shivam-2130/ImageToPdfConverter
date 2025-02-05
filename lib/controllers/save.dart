import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> savePDF(
    BuildContext context, File pdfFile, String fileName) async {
  // Request permission to manage external storage (Android 10 and above)
  var status = await Permission.manageExternalStorage.request();

  if (status.isGranted) {
    // Get the external storage path (root external storage)
    final externalStoragePath =
        '/storage/emulated/0/'; // External storage root directory

    // Choose the directory for storing the PDF, e.g., Download or Documents
    final downloadDir = Directory('${externalStoragePath}Download');

    // Create the directory if it doesn't exist
    if (!downloadDir.existsSync()) {
      downloadDir.createSync();
    }

    // Create a new file path for the saved PDF using the user-specified filename
    final newFilePath = "${downloadDir.path}/$fileName.pdf";
    final newFile = File(newFilePath);

    // Copy the PDF to the chosen directory
    await pdfFile.copy(newFilePath);
    print("PDF saved at: $newFilePath");

    // Ensure the widget is still in the tree before showing the SnackBar
  } else {
    // Handle permission denial
    print("Storage permission denied.");

    // Ensure the widget is still in the tree before showing the SnackBar
    Future.delayed(Duration(milliseconds: 100), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Storage permission denied")),
        );
      }
    });
  }
}

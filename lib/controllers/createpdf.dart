import 'dart:io';

import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

Future<File> createPDF(List<File> images) async {
  final pdf = pw.Document();

  for (var image in images) {
    final imageBytes = await image.readAsBytes();
    final pdfImage = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Image(pdfImage),
        ),
      ),
    );
  }

  final directory =
      await getTemporaryDirectory(); // Store temporarily before saving
  final filePath = "${directory.path}/preview.pdf";
  final file = File(filePath);

  await file.writeAsBytes(await pdf.save());
  return file;
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf_generator/services/ad_mob_service.dart';
import 'package:pdf_generator/controllers/createpdf.dart';
import 'package:pdf_generator/views/custom_camera.dart';
import 'package:pdf_generator/views/pdfPreview.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  BannerAd? _banner;

  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  File? _pdfFile;

  void pickImages() async {
    List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _createbanerAd();
  }

  void _createbanerAd() {
    _banner = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId!,
      size: AdSize.fullBanner,
      request: AdRequest(),
      listener: AdMobService.bannerListner,
    );
    _banner!.load();

    debugPrint('Banner ad load called');
  }

  void captureImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  void openCustomCamera() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomCameraScreen(
          onDone: (List<File> capturedImages) {
            setState(() {
              _selectedImages.addAll(capturedImages);
            });
          },
        ),
      ),
    );
  }

  void generatePDF() async {
    if (_selectedImages.isNotEmpty) {
      File pdf = await createPDF(_selectedImages);

      if (!mounted) return; // Ensure widget is still in the tree

      setState(() {
        _pdfFile = pdf;
      });

      if (!mounted) return; // Ensure context is still valid

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFPreviewScreen(
            pdfFile: pdf,
            onSave: () async {},
          ),
        ),
      );

      if (result == true) {
        setState(() {
          _selectedImages.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF3F7FF),
        appBar: AppBar(
          title: Text(
            'PDF Generator',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
          ),
          backgroundColor: Color.fromARGB(255, 56, 144, 244),
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            // 📸 Image Selection Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildSelectionButton(
                    icon: Icons.image,
                    label: "Gallery",
                    onTap: pickImages,
                    color: Color(0xFF4A90E2),
                  ),
                  SizedBox(width: 16),
                  _buildSelectionButton(
                    icon: Icons.camera_alt,
                    label: "Camera",
                    onTap: captureImage,
                    color: Color(0xFF50E3C2),
                  ),
                ],
              ),
            ),

            // 📷 Image Preview Section
            Expanded(
              child: _selectedImages.isEmpty
                  ? _buildEmptyState()
                  : _buildImageGrid(),
            ),
          ],
        ),

        // 📄 Floating Action Button for PDF Generation
        floatingActionButton: _selectedImages.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: generatePDF,
                backgroundColor: Color(0xFF4A90E2),
                icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                label: Text("Generate PDF",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              )
            : null,
        bottomNavigationBar: _banner == null
            ? Container()
            : Container(
                margin: EdgeInsets.only(bottom: 10),
                height: 52,
                child: AdWidget(ad: _banner!),
              ));
  }

  Widget _buildSelectionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                spreadRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 12),
          Text(
            "No images selected",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ReorderableGridView.builder(
        padding: EdgeInsets.only(top: 10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Stack(
            key: Key('$index'), // Unique key for each item
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImages[index],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Page Number
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Page ${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Remove Button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImages.removeAt(index);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(5),
                    child: Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          );
        },
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final File image = _selectedImages.removeAt(oldIndex);
            _selectedImages.insert(newIndex, image);
          });
        },
      ),
    );
  }
}

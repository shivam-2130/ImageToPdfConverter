import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CustomCameraScreen extends StatefulWidget {
  final Function(List<File>) onDone;
  const CustomCameraScreen({required this.onDone, Key? key}) : super(key: key);

  @override
  _CustomCameraScreenState createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  late CameraController _controller;
  List<File> _capturedImages = [];
  bool _isCapturing = false;
  bool _isCameraInitialized = false;
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      _controller = CameraController(firstCamera, ResolutionPreset.high,
          enableAudio: false);
      await _controller.initialize();
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  Future<void> _captureImage() async {
    if (!_controller.value.isInitialized || _isCapturing) return;

    setState(() => _isCapturing = true);

    // Set the correct flash mode before capturing the picture
    await _controller.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);

    try {
      final XFile image = await _controller.takePicture();
      setState(() => _capturedImages.add(File(image.path)));

      // Reset flash to off after capturing the image unless manually toggled
      if (!_flashOn) {
        await _controller.setFlashMode(FlashMode.off);
      }
    } catch (e) {
      print("Error capturing image: $e");
    }
    setState(() => _isCapturing = false);
  }

  void _toggleFlash() async {
    _flashOn = !_flashOn;

    // Toggle the flash mode based on the flashOn flag
    await _controller.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);

    setState(() {});
  }

  void _doneCapturing() {
    if (_capturedImages.isNotEmpty) {
      widget.onDone(_capturedImages);
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CameraPreview(_controller),
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white, size: 30),
                    onPressed: _toggleFlash,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    GestureDetector(
                      onTap: _captureImage,
                      child: Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.grey.shade800, width: 3),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check,
                          color: Colors.green, size: 32),
                      onPressed: _doneCapturing,
                    ),
                  ],
                ),
                if (_capturedImages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _capturedImages.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.all(5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _capturedImages[index],
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

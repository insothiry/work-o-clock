import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';

class ChatImagePreviewScreen extends StatefulWidget {
  final File imageFile;
  final Future<void> Function(String caption, File imageFile) onSend;

  const ChatImagePreviewScreen({
    Key? key,
    required this.imageFile,
    required this.onSend,
  }) : super(key: key);

  @override
  State<ChatImagePreviewScreen> createState() => _ChatImagePreviewScreenState();
}

class _ChatImagePreviewScreenState extends State<ChatImagePreviewScreen> {
  final TextEditingController _captionController = TextEditingController();
  late File currentImageFile;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    currentImageFile = widget.imageFile;
  }

  Future<void> cropImage() async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: currentImageFile.path,
      aspectRatioPresets: [CropAspectRatioPreset.original],
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    if (cropped != null) {
      setState(() {
        currentImageFile = File(cropped.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.file(
                currentImageFile,
                fit: BoxFit.contain,
              ),
            ),
            // Back button
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Crop button
            Positioned(
              top: 16,
              right: 60,
              child: IconButton(
                icon: const Icon(Icons.crop, color: Colors.white),
                onPressed: cropImage,
              ),
            ),
            // Send button
            Positioned(
              top: 16,
              right: 16,
              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send, color: Colors.purpleAccent),
                      onPressed: () async {
                        setState(() => isSending = true);
                        await widget.onSend(
                          _captionController.text,
                          currentImageFile,
                        );
                        setState(() => isSending = false);
                        Get.back();
                      },
                    ),
            ),
            // Caption input
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: TextField(
                  controller: _captionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Add a caption...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white10,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

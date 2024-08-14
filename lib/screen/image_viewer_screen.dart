// Suggested code may be subject to a license. Learn more: ~LicenseLog:931985682.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:3866131840.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:3510476289.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1841311925.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2215999601.
import 'package:flutter/material.dart';
import 'package:sana_mobile/models/image_model.dart';

// ... (import ImageModel di sini)

class ImageViewerScreen extends StatefulWidget {
  final List<ImageModel> images;
  final int initialIndex;

  const ImageViewerScreen({
    Key
    ? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialIndex * 425.0, // Adjust as needed
    );
  }

  
@override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Rafi',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              'Posts',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 3), // Sesuaikan jarak sesuai kebutuhan
            child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.width,
                child: Image.asset(
                  widget.images[index].photo,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: Text(
                  'Teks di bawah gambar ${index + 1}', // Ganti dengan teks yang sesuai
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          );
        },
      ),
    );
  }
}

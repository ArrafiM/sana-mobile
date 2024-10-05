import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MerchantCreate extends StatefulWidget {
  const MerchantCreate({Key? key}) : super(key: key);

  @override
  State<MerchantCreate> createState() => _MerchantCreateState();
}

class _MerchantCreateState extends State<MerchantCreate> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      PermissionStatus cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        // Jika izin kamera tidak diberikan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin akses kamera ditolak')),
        );
        return;
      }
    } else if (source == ImageSource.gallery) {
      // PermissionStatus galleryStatus = await Permission.photos.request();
      // if (!galleryStatus.isGranted) {
      //   // Jika izin galeri tidak diberikan
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Izin akses galeri ditolak')),
      //   );
      //   return;
      // }
      PermissionStatus storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        // Jika izin galeri tidak diberikan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin akses galeri ditolak')),
        );
        return;
      }
    }

    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: Text(message),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  void _login() {
    String email = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    // Check if fields are empty
    if (email.isEmpty || description.isEmpty) {
      _showAlertDialog('Required fields cannot be empty.');
      return;
    }

    // If all validations pass, proceed with login logic
    print('Email: $email');

    // Add your login logic here (e.g., API call)
    // _fetchLogin(context, email, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                'Merchant',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
            child: SingleChildScrollView(
              child: merchantCreateForm(),
            )));
  }

  Container merchantCreateForm() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Title',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // Warna border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // Warna border saat field fokus
                  ),
                  hintText: 'Enter Title',
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 15.0), // Mengatur padding dalam TextField
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              TextField(
                controller: _descriptionController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // Warna border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // Warna border saat field fokus
                  ),
                  hintText: 'Enter Description',
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 15.0), // Mengatur padding dalam TextField
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image != null
                  ? Image.file(
                      _image!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Text('Tidak ada gambar terpilih'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.camera),
                child: Text('Ambil Gambar dari Kamera'),
              ),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: Text('Pilih Gambar dari Galeri'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Text color
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  showMessageDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Gagal login!',
            // style: TextStyle(color: Colors.white), // Mengatur warna teks judul
          ),
          content: Text(message),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              child: const Text(
                'oke',
                style:
                    TextStyle(color: Colors.blue), // Mengatur warna teks tombol
              ),
              onPressed: () {
                print("oke");
                Navigator.pop(context);
                // Navigator.pushNamedAndRemoveUntil(
                //   context,
                //   '/login', // Replace '/login' with the route name for your login screen
                //   (route) => false,
                // );
              },
            ),
          ],
        );
      },
    );
  }
}

Future<void> _fetchLogin(context, email, password) async {
  // Contoh menyimpan token setelah login berhasil
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // Map response = await UserServices.authentication(email, password);
  // print("login response: $response");
  // if (response['error'] != null) {
  //   print("login error");
  //   showMessageDialog(context, response['error']);
  // Navigator.pushReplacement(
  // context,
  // MaterialPageRoute(builder: (context) => const merchantCreateForm()),
  // );
  // } else {
  //   print("login success");
  // await prefs.setString('token', 'token_test');
  // await prefs.setString('token', response['token']);
  // Navigator.pushReplacement(
  //   context,
  //   MaterialPageRoute(builder: (context) => const MainNavigation()),
  // );
  // }
}

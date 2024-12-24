// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sana_mobile/services/user_services.dart';

class ProfileupdateScreen extends StatefulWidget {
  final String name, pathImage;
  final int userId;
  const ProfileupdateScreen(
      {Key? key,
      required this.name,
      required this.userId,
      required this.pathImage})
      : super(key: key);

  @override
  State<ProfileupdateScreen> createState() => _ProfileupdateScreenState();
}

class _ProfileupdateScreenState extends State<ProfileupdateScreen> {
  final TextEditingController _nameController = TextEditingController();
  String publicApiUrl = "";
  File? _image;
  String pathImage = '';
  int userId = 0;
  final ImagePicker _picker = ImagePicker();
  String? myId = '';

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
  void initState() {
    super.initState();
    String apiUrl = UserServices.apiUrl();
    setState(() {
      if (widget.name != '') {
        _nameController.text = widget.name;
      }

      if (widget.pathImage != '') {
        pathImage = widget.pathImage;
      }
      userId = widget.userId;
      publicApiUrl = "$apiUrl/public/";
    });
  }

  

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAlertDialog(String message, bool dissmissiable, String title) {
    showDialog(
      context: context,
      barrierDismissible: dissmissiable,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () {
                if (!dissmissiable) {
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                } else {
                  Navigator.of(context).pop();
                }
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

  void _createProfile() {
    String name = _nameController.text.trim();

    // Check if fields are empty
    if (name.isEmpty) {
      _showAlertDialog('Required fields cannot be empty.', true, 'Alert');
      return;
    }

    if (_image == null && userId == 0) {
      _showAlertDialog('Please select profile photo', true, 'Alert');
      return;
    }

    // If all validations pass, proceed with login logic
    print('name: $name');

    print("update profile id: $userId");
    _putprofile(context, name, _image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              userId != 0
                  ? const Text(
                      'Update',
                      style: TextStyle(fontSize: 12),
                    )
                  : const Text(
                      'Create',
                      style: TextStyle(fontSize: 12),
                    ),
              const Text(
                'profile',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
            child: SingleChildScrollView(
              child: ProfileupdateScreenForm(),
            )));
  }

  Container ProfileupdateScreenForm() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  (pathImage != '' && _image == null)
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(publicApiUrl + pathImage),
                          radius: 80,
                        )
                      : _image != null
                          ? ClipOval(
                              child: Image.file(
                                _image!,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle, // Bentuk lingkaran
                                border: Border.all(
                                  color: Colors.blue, // Warna border
                                  width: 1.0, // Ketebalan border
                                ),
                              ),
                              child: const ClipOval(
                                  child: Icon(Icons.person_outline, size: 150)),
                            ),
                  const SizedBox(width: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize:
                              const Size(120, 40), // Lebar 200, Tinggi 50
                        ),
                        onPressed: () => _pickImage(ImageSource.camera),
                        child: const Icon(Icons.add_a_photo_outlined),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize:
                              const Size(120, 40), // Lebar 200, Tinggi 50
                        ),
                        onPressed: () => _pickImage(ImageSource.gallery),
                        child: const Icon(Icons.photo_library_outlined),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          // name field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // Warna border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // Warna border saat field fokus
                  ),
                  hintText: 'Enter nerchant name',
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 15.0), // Mengatur padding dalam TextField
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createProfile,
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

  Future<void> _putprofile(context, name, File? image) async {
    // Contoh menyimpan token setelah login berhasil
    bool response = await UserServices.putUser(name, image);
    print("merchant updated: $response");
    if (!response) {
      _showAlertDialog("Failed update user", true, 'Alert');
    } else {
      _showAlertDialog("user [$name] updated!", false, 'Successfully');
    }
    ;
  }
}

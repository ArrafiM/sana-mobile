import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sana_mobile/services/merchant_services.dart';
import 'package:sana_mobile/services/user_services.dart';

class MerchantCreate extends StatefulWidget {
  final String name, desc, pathImage;
  final int merchantId;
  const MerchantCreate(
      {Key? key,
      required this.name,
      required this.desc,
      required this.merchantId,
      required this.pathImage})
      : super(key: key);

  @override
  State<MerchantCreate> createState() => _MerchantCreateState();
}

class _MerchantCreateState extends State<MerchantCreate> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String publicApiUrl = "";
  File? _image;
  String pathImage = '';
  int merchantId = 0;
  bool isLoad = false;
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
  void initState() {
    super.initState();
    String apiUrl = UserServices.apiUrl();
    setState(() {
      if (widget.name != '') {
        _nameController.text = widget.name;
      }
      if (widget.desc != '') {
        _descriptionController.text = widget.desc;
      }
      if (widget.pathImage != '') {
        pathImage = widget.pathImage;
      }
      merchantId = widget.merchantId;
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

  void _createMerchant() async {
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();

    // Check if fields are empty
    if (name.isEmpty || description.isEmpty) {
      _showAlertDialog('Required fields cannot be empty.', true, 'Alert');
      return;
    }

    if (_image == null && merchantId == 0) {
      _showAlertDialog('Please select merchant photo', true, 'Alert');
      return;
    }

    // If all validations pass, proceed with login logic
    print('name: $name');

    // Add your login logic here (e.g., API call)
    setState(() {
      isLoad = true;
    });
    if (merchantId == 0) {
      await _postMerchant(context, name, description, _image);
    } else {
      print("update merchant id: $merchantId");
      await _putMerchant(context, name, description, _image);
    }
    setState(() {
      isLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              merchantId != 0
                  ? const Text(
                      'Update',
                      style: TextStyle(fontSize: 12),
                    )
                  : const Text(
                      'Create',
                      style: TextStyle(fontSize: 12),
                    ),
              const Text(
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
          Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Merchant photo'),
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
                              child: ClipOval(
                                  child: Icon(
                                Icons.store,
                                size: 150,
                                color: Colors.grey[500],
                              )),
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
                        child: const Row(
                          children: [
                            Icon(Icons.add_a_photo_outlined),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Photo")
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize:
                                const Size(120, 40), // Lebar 200, Tinggi 50
                          ),
                          onPressed: () => _pickImage(ImageSource.gallery),
                          child: const Row(
                            children: [
                              Icon(Icons.photo_library_outlined),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Album")
                            ],
                          )),
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
          const SizedBox(height: 10),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (!isLoad) {
                  _createMerchant();
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Text color
              ),
              child: !isLoad
                  ? const Text('Save')
                  : const CircularProgressIndicator(
                      color: Colors.white,
                    ),
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

  Future<void> _postMerchant(context, name, password, File? image) async {
    // Contoh menyimpan token setelah login berhasil
    bool response =
        await MerchantServices.createMerchant(name, password, image);
    print("merchant create: $response");
    if (!response) {
      print("login error");
      _showAlertDialog("Failed create merchant", true, 'Alert');
    } else {
      _showAlertDialog("Merchant [$name] created!", false, 'Successfully');
    }
  }

  Future<void> _putMerchant(context, name, password, File? image) async {
    // Contoh menyimpan token setelah login berhasil
    bool response =
        await MerchantServices.putMerchant(merchantId, name, password, image);
    print("merchant updated: $response");
    if (!response) {
      _showAlertDialog("Failed update merchant", true, 'Alert');
    } else {
      _showAlertDialog("Merchant [$name] updated!", false, 'Successfully');
    }
  }
}

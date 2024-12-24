import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sana_mobile/services/merchant_services.dart';
import 'package:sana_mobile/services/user_services.dart';

class MerchandiseUpsert extends StatefulWidget {
  final String name, desc, pathImage, price, merchantId;
  final List tag;
  final int merchandiseId;
  const MerchandiseUpsert(
      {Key? key,
      required this.name,
      required this.desc,
      required this.merchantId,
      required this.pathImage,
      required this.price,
      required this.tag,
      required this.merchandiseId})
      : super(key: key);

  @override
  State<MerchandiseUpsert> createState() => _MerchandiseUpsertState();
}

class _MerchandiseUpsertState extends State<MerchandiseUpsert> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  String publicApiUrl = "";
  File? _image;
  String pathImage = '';
  String merchantId = '';
  int merchandiseId = 0;
  bool addTag = false;
  List tagData = [];
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
      if (widget.price != '') {
        _priceController.text = widget.price;
      }
      if (widget.tag.isNotEmpty) {
        tagData = widget.tag;
      }
      merchantId = widget.merchantId;
      merchandiseId = widget.merchandiseId;
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

  void _createMerchant() {
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();
    String price = _priceController.text.trim();

    // Check if fields are empty
    if (name.isEmpty || description.isEmpty || price.isEmpty) {
      _showAlertDialog('Required fields cannot be empty.', true, 'Alert');
      return;
    }

    if (_image == null && merchandiseId == 0) {
      _showAlertDialog('Please select merchant photo', true, 'Alert');
      return;
    }

    // If all validations pass, proceed with login logic
    print('name: $name');

    // Add your login logic here (e.g., API call)
    if (merchandiseId == 0) {
      _postMerchandise(context, name, description, price);
    } else {
      _putMerchandise(context, name, description, price);
    }
  }

  void _showAddTag(data) {
    String tag = _tagController.text.trim();
    if (data == false) {
      // if (tag.isEmpty) {
      //   _showAlertDialog(
      //       'Required fields tag, cannot be empty.', true, 'Alert');
      //   return;
      // }
      _tagController.clear();
    }
    setState(() {
      addTag = data;
      if (tag.isNotEmpty) {
        tagData.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'My merchant',
                style: TextStyle(fontSize: 12),
              ),
              merchandiseId != 0
                  ? const Text(
                      'Update Item',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    )
                  : const Text(
                      'Add Item',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
            ],
          ),
          centerTitle: true,
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
            child: SingleChildScrollView(
              child: merchandiseUpsertForm(),
            )));
  }

  Container merchandiseUpsertForm() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  hintText: 'Enter item name',
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

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              TextField(
                controller: _priceController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // Warna border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // Warna border saat field fokus
                  ),
                  hintText: 'Enter Price',
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 15.0), // Mengatur padding dalam TextField
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Column(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              tagData.isEmpty
                  ? const Text('Item photo:')
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Item photo:'), Text(':Tag data')],
                    ),
              Row(
                children: [
                  (pathImage != '' && _image == null)
                      ? Container(
                          width: 90,
                          height: 120,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              image: DecorationImage(
                                  image: NetworkImage(publicApiUrl + pathImage),
                                  fit: BoxFit.cover)
                              // border: Border.all()
                              ),
                        )
                      : _image != null
                          ? Container(
                              width: 90,
                              height: 120,
                              decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Image.file(
                                _image!,
                                width: 90,
                                height: 120,
                                fit: BoxFit.cover,
                              ))
                          : Container(
                              width: 90,
                              height: 120,
                              decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  image: DecorationImage(
                                      image: AssetImage(
                                          "assets/photos/galery.png"),
                                      fit: BoxFit.scaleDown)
                                  // border: Border.all()
                                  ),
                            ),
                  // const ClipOval(
                  //     child: Icon(Icons.wallpaper_outlined, size: 100)),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      ElevatedButton(
                          onPressed: () => _pickImage(ImageSource.camera),
                          child: const Column(
                            children: [
                              Icon(Icons.add_a_photo_outlined),
                              Text(
                                "Photo",
                                style: TextStyle(fontSize: 10),
                              )
                            ],
                          )),
                      ElevatedButton(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          child: const Column(
                            children: [
                              Icon(Icons.photo_library_outlined),
                              Text(
                                "Media",
                                style: TextStyle(fontSize: 10),
                              )
                            ],
                          )),
                    ],
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                      height: 120, // Atur tinggi kotak scroll
                      // decoration: BoxDecoration(
                      //     border: Border.all(color: Colors.grey)),
                      width: 150,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Wrap(
                            spacing: 2.0, // Jarak horizontal antar kotak
                            runSpacing: 2.0, // Jarak vertikal antar kotak
                            children: tagData
                                .map((tag) => _buildTagItem(tag))
                                .toList(),
                          ),
                        ),
                      )),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tag',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              addTag == false
                  ? ElevatedButton(
                      onPressed: () {
                        print("show tag");
                        _showAddTag(true);
                      },
                      child: const Icon(Icons.add))
                  : const SizedBox.shrink(),
              addTag == true
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: 50,
                          width: 250,
                          child: TextField(
                            controller: _tagController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black), // Warna border
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .blue), // Warna border saat field fokus
                              ),
                              hintText: 'Enter Tag',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal:
                                      15.0), // Mengatur padding dalam TextField
                            ),
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              print("new tag");
                              _showAddTag(false);
                            },
                            child: const Column(
                              children: [
                                Icon(Icons.check),
                                // Text("Add")
                              ],
                            )),
                      ],
                    )
                  : const SizedBox.shrink()
            ],
          ),

          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createMerchant,
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

  Widget _buildTagItem(String tag) {
    return Chip(
      label: Text(tag),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Membuat sudut melengkung
      ),
      backgroundColor: Colors.blue.shade100,
      deleteIcon: const Icon(Icons.close, color: Colors.red),
      onDeleted: () {
        setState(() {
          tagData.remove(tag);
        });
      },
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

  Future<void> _postMerchandise(context, name, desc, price) async {
    // Contoh menyimpan token setelah login berhasil
    bool response = await MerchantServices.createMerchandise(
        name, desc, _image, price, merchantId, tagData);
    print("merchandise create: $response");
    if (!response) {
      _showAlertDialog("Failed create merchandise", true, 'Alert');
    } else {
      _showAlertDialog("Merchandise [$name] created!", false, 'Successfully');
    }
  }

  Future<void> _putMerchandise(context, name, desc, price) async {
    // Contoh menyimpan token setelah login berhasil
    bool response = await MerchantServices.putMerchandise(
        merchandiseId, name, desc, _image, price, merchantId, tagData);
    print("merchant updated: $response");
    if (!response) {
      _showAlertDialog("Failed update merchant", true, 'Alert');
    } else {
      _showAlertDialog("Merchant [$name] updated!", false, 'Successfully');
    }
  }
}

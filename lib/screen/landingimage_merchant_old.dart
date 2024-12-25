import 'dart:async';
import 'package:flutter/material.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sana_mobile/services/merchant_services.dart';
import 'package:sana_mobile/services/user_services.dart';

class LandingimageMerchant extends StatefulWidget {
  final String merchantId;
  final List landingImage;
  const LandingimageMerchant(
      {required this.merchantId, required this.landingImage, Key? key})
      : super(key: key);

  @override
  State<LandingimageMerchant> createState() => _LandingimageMerchantState();
}

class _LandingimageMerchantState extends State<LandingimageMerchant> {
  List<Asset> images = <Asset>[];
  String _error = 'Pilih gambar!';
  bool _permissionReady = false;
  String merchantId = '';
  List landingImage = [];
  String publicApiUrl = "";
  List<int> removeId = [];
  AppLifecycleListener? _lifecycleListener;
  static const List<Permission> _permissions = [
    Permission.storage,
    // Permission.camera
  ];

  Future<void> _requestPermissions() async {
    final Map<Permission, PermissionStatus> statues =
        await _permissions.request();
    if (statues.values.every((status) => status.isGranted)) {
      _permissionReady = true;
    }
  }

  Future<void> _checkPermissions() async {
    _permissionReady = (await Future.wait(_permissions.map((e) => e.isGranted)))
        .every((isGranted) => isGranted);
  }

  Future<void> _loadAssets() async {
    if (!_permissionReady) {
      openAppSettings();
      return;
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    List<Asset> resultList = <Asset>[];
    String error = 'Pilih gambar!';

    const AlbumSetting albumSetting = AlbumSetting(
      fetchResults: {
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumFavorites,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.album,
          subtype: PHAssetCollectionSubtype.albumRegular,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumSelfPortraits,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumPanoramas,
        ),
        // PHFetchResult(
        //   type: PHAssetCollectionType.smartAlbum,
        //   subtype: PHAssetCollectionSubtype.smartAlbumVideos,
        // ),
      },
    );
    const SelectionSetting selectionSetting = SelectionSetting(
      min: 0,
      max: 3,
      unselectOnReachingMax: true,
    );
    const DismissSetting dismissSetting = DismissSetting(
      enabled: true,
      allowSwipe: true,
    );
    final ThemeSetting themeSetting = ThemeSetting(
      backgroundColor: colorScheme.surface,
      selectionFillColor: colorScheme.primary,
      selectionStrokeColor: colorScheme.onPrimary,
      previewSubtitleAttributes: const TitleAttribute(fontSize: 12.0),
      previewTitleAttributes: TitleAttribute(
        foregroundColor: colorScheme.primary,
      ),
      albumTitleAttributes: TitleAttribute(
        foregroundColor: colorScheme.primary,
      ),
    );
    const ListSetting listSetting = ListSetting(
      spacing: 5.0,
      cellsPerRow: 4,
    );
    const AssetsSetting assetsSetting = AssetsSetting(
      // Set to allow pick videos.
      supportedMediaTypes: {MediaTypes.video, MediaTypes.image},
    );
    final CupertinoSettings iosSettings = CupertinoSettings(
      fetch: const FetchSetting(album: albumSetting, assets: assetsSetting),
      theme: themeSetting,
      selection: selectionSetting,
      dismiss: dismissSetting,
      list: listSetting,
    );

    try {
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: images,
        iosOptions: IOSOptions(
          doneButton: UIBarButtonItem(
              title: 'Confirm', tintColor: colorScheme.primaryFixed),
          cancelButton:
              UIBarButtonItem(title: 'Cancel', tintColor: colorScheme.primary),
          albumButtonColor: colorScheme.primary,
          settings: iosSettings,
        ),
        androidOptions: AndroidOptions(
          actionBarColor: colorScheme.primary,
          actionBarTitleColor: Colors.white,
          statusBarColor: colorScheme.surface,
          actionBarTitle: "Select Photos",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: colorScheme.primary,
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  @override
  void initState() {
    _requestPermissions();
    _lifecycleListener = AppLifecycleListener(
      onResume: _checkPermissions,
    );
    super.initState();
    String apiUrl = UserServices.apiUrl();

    setState(() {
      merchantId = widget.merchantId;
      landingImage = widget.landingImage;
      publicApiUrl = "$apiUrl/public/";
    });
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    super.dispose();
  }

  void _removeImage(index, name) {
    int imageId = landingImage[index]['ID'];
    print("image $imageId");
    if (name == null) {
      setState(() {
        landingImage[index]['name'] = 'delete';
        removeId.add(imageId);
      });
    } else {
      setState(() {
        landingImage[index]['name'] = null;
        removeId.remove(imageId);
      });
    }
    print("all remove imageId: $removeId");
  }

  Widget _myLandingImage() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Jumlah kolom
        crossAxisSpacing: 2.0, // Jarak horizontal antar gambar
        mainAxisSpacing: 2.0, // Jarak vertical antar gambar
      ),
      itemCount: landingImage.length,
      itemBuilder: (context, index) {
        // Asset asset = images[index];
        var name = landingImage[index]['name'];
        return GestureDetector(
            onTap: () {
              _removeImage(index, name);
            },
            child: Stack(
              alignment: AlignmentDirectional.topEnd,
              children: [
                Image.network(
                  publicApiUrl + landingImage[index]['url'],
                  fit: BoxFit.fitHeight,
                  width: 300,
                  height: 300,
                ),
                name == 'delete'
                    ? Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(5)),
                        child: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.white,
                        ))
                    : const SizedBox.shrink()
              ],
            ));
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Jumlah kolom
        crossAxisSpacing: 2.0, // Jarak horizontal antar gambar
        mainAxisSpacing: 2.0, // Jarak vertical antar gambar
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        Asset asset = images[index];
        return GestureDetector(
            onTap: () {
              print("iamge ${images[index].name}");
            },
            child: AssetThumb(
              asset: asset,
              width: 300,
              height: 300,
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Column(
          children: [
            Text(
              'My merchant',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              'Landing Image',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          landingImage.isNotEmpty
              ? Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: _myLandingImage()))
              : const SizedBox.shrink(),
          Center(child: Text('Note: $_error')),
          images.isNotEmpty || removeId.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                      ElevatedButton(
                        onPressed: _loadAssets,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(120, 40),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              color: Colors.white,
                            ),
                            Text("Media", style: TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _uploadMerchantLanding(merchantId, images);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(120, 40),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.save_outlined,
                              color: Colors.white,
                            ),
                            Text(
                              "Save",
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      )
                    ])
              : ElevatedButton(
                  onPressed: _loadAssets,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white,
                  )),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.all(2.0), child: _buildGridView()),
          ),
        ],
      ),
    );
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

  Future<void> _uploadMerchantLanding(merchantId, List<Asset> image) async {
    // Contoh menyimpan token setelah login berhasil
    bool response = await MerchantServices.uploadMerchantImages(
        merchantId, image, removeId);
    print("merchant create: $response");
    if (!response) {
      _showAlertDialog("Failed upload merchant landing image", true, 'Alert');
    } else {
      _showAlertDialog("Merchant landing uploaded!", false, 'Successfully');
    }
  }
}

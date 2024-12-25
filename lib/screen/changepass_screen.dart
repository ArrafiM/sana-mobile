import 'package:flutter/material.dart';
import 'package:sana_mobile/services/user_services.dart';

class ChangepassScreen extends StatefulWidget {
  final int userId;
  const ChangepassScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChangepassScreen> createState() => _ChangepassScreenState();
}

class _ChangepassScreenState extends State<ChangepassScreen> {
  final TextEditingController _oldpassController = TextEditingController();
  final TextEditingController _newpassController = TextEditingController();
  final TextEditingController _newpassconfirmController =
      TextEditingController();
  int userId = 0;
  String? myId = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      userId = widget.userId;
    });
  }

  @override
  void dispose() {
    _oldpassController.dispose();
    _newpassController.dispose();
    _newpassconfirmController.dispose();
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

  void changePass() {
    String oldpass = _oldpassController.text.trim();
    String newpass = _newpassController.text.trim();
    String newpassConfirm = _newpassconfirmController.text.trim();

    // Check if fields are empty
    if (oldpass.isEmpty || newpass.isEmpty || newpassConfirm.isEmpty) {
      _showAlertDialog('Required fields cannot be empty.', true, 'Alert');
      return;
    }

    Map inputData = {
      'oldpass': oldpass,
      'newpass': newpass,
      'confirm_newpass': newpassConfirm,
    };

    print("update profile id: $userId");
    _putprofile(context, inputData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Update',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                'Change password',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
            child: SingleChildScrollView(
              child: changepassScreenForm(),
            )));
  }

  Container changepassScreenForm() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // oldpass field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Password',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              TextField(
                controller: _oldpassController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // Warna border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // Warna border saat field fokus
                  ),
                  hintText: 'Current password',
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 15.0), // Mengatur padding dalam TextField
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // newpass field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Password',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              TextField(
                controller: _newpassController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: 'New password',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // confirm newpass field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm New Password',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              TextField(
                controller: _newpassconfirmController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: 'Confirm new password',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: changePass,
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

  Future<void> _putprofile(context, updateData) async {
    // Contoh menyimpan token setelah login berhasil
    Map response = await UserServices.changePass(updateData);
    print("merchant updated: $response");
    if (response['error'] != null) {
      _showAlertDialog(response['error'], true, 'Alert');
    } else {
      _showAlertDialog("user [password] updated!", false, 'Successfully');
    }
    ;
  }
}

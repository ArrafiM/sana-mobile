import 'package:flutter/material.dart';
import 'package:sana_mobile/services/socket_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Logout extends StatefulWidget {
  const Logout({Key? key}) : super(key: key);

  @override
  State<Logout> createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  @override
  Widget build(BuildContext context) {
    return showLogoutDialog(context);
  }
}

showLogoutDialog(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Expaired!'),
        content: const Text('Sesi anda telah habis, harap login kembali'),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            child: const Text(
              'Oke',
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login', // Replace '/login' with the route name for your login screen
                (route) => false,
              );
            },
          ),
        ],
      );
    },
  );
}

showLogoutConfirmDialog(context) {
  showDialog(
    context: context,
    // barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Logout!'),
        content: const Text('Are you sure?'),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            child: const Text(
              'No',
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              _logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login', // Replace '/login' with the route name for your login screen
                (route) => false,
              );
            },
          ),
        ],
      );
    },
  );
}

void _logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final socketService = SocketService();
  await prefs.remove('token');
  await prefs.remove('user_id');
  socketService.disconnect(); // Disconnect the WebSocket
}

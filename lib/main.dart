import 'package:flutter/material.dart';
import 'package:sana_mobile/services/socket_services.dart';
import 'package:sana_mobile/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sana_mobile/screen/loginpage.dart';
import 'package:sana_mobile/screen/main_navigation.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String?> _tokenFuture;
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _tokenFuture = _checkToken();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Disconnect WebSocket when the app goes to background or is closed
      _socketService.disconnect();
    } else if (state == AppLifecycleState.resumed) {
      // Reconnect WebSocket when the app resumes
      String? userId = await UserServices.checkMyId();
      if (userId != "") {
        _socketService.connect('ws://172.20.10.3:8080/ws?user_id=user$userId');
      }
    }
  }

  Future<String?> _checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      home: FutureBuilder<String?>(
        future: _tokenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return snapshot.data == null
                ? const LoginForm()
                : const MainNavigation();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginForm(),
      },
    );
  }
}

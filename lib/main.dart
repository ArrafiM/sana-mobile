import 'package:flutter/material.dart';
import 'package:sana_mobile/services/socket_services.dart';
import 'package:sana_mobile/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sana_mobile/screen/loginpage.dart';
import 'package:sana_mobile/screen/main_navigation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID', null);
  await dotenv.load(fileName: ".env");
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
    checkAndRequestPermissions();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Disconnect WebSocket when the app goes to background or is closed
      _socketService.disconnect();
    } else if (state == AppLifecycleState.resumed) {
      // Reconnect WebSocket when the app resumes
      String wsUrl = await UserServices.wsUrl();
      _socketService.connect(wsUrl);
    }
  }

  Future<String?> _checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> checkAndRequestPermissions() async {
    // Cek izin notifikasi
    var status = await Permission.notification.status;

    if (status.isDenied) {
      // Meminta izin notifikasi
      await Permission.notification.request();
    }

    // Periksa ulang status
    if (await Permission.notification.isGranted) {
      print("Izin notifikasi diberikan");
    } else {
      print("Izin notifikasi ditolak");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.green,
        // background: Colors.white,
        surface: Colors.grey[200]!,
        error: Colors.red,
      )),
      // theme: ThemeData.light(
      //   useMaterial3: true,
      // ),
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
                : const MainNavigation(index: 1);
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginForm(),
      },
    );
  }
}

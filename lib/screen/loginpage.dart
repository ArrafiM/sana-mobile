import 'package:flutter/material.dart';
import 'package:sana_mobile/screen/main_navigation.dart';
import 'package:sana_mobile/screen/registerpage.dart';
import 'package:sana_mobile/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String publicApiUrl = "${UserServices.apiUrl()}/public/";
  bool isLoad = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to validate email format
  bool _isValidEmail(String email) {
    // Regular expression for email validation
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Function to show an alert dialog
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

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Check if fields are empty
    if (email.isEmpty || password.isEmpty) {
      _showAlertDialog('Required fields cannot be empty.');
      return;
    }

    // Check if email format is valid
    if (!_isValidEmail(email)) {
      _showAlertDialog('Email must be a valid email format.');
      return;
    }

    // If all validations pass, proceed with login logic
    print('Email: $email');
    print('Password: $password');

    // Add your login logic here (e.g., API call)
    setState(() {
      isLoad = true;
    });
    await _fetchLogin(context, email, password);
    setState(() {
      isLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: loginForm(),
            )),
      ),
    );
  }

  Container loginForm() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title text 'login'
          SizedBox(
              width: 80,
              height: 80,
              child: Image.asset('assets/logo/sana_icon3new.png')),
          const Text(
            'SANA',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Email field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // Warna border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // Warna border saat field fokus
                  ),
                  hintText: 'Enter your email',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Password field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // Warna border
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // Warna border saat field fokus
                  ),
                  // enabledBorder: OutlineInputBorder(
                  //   borderSide: BorderSide(color: Colors.red), // Warna border saat field tidak fokus
                  // ),
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Login button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (isLoad == false) {
                  _login();
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Text color
              ),
              child: !isLoad
                  ? const Text('Login')
                  : const CircularProgressIndicator(
                      color: Colors.white,
                    ),
            ),
          ),

          registerButton()
        ],
      ),
    );
  }

  SizedBox registerButton() {
    return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Center(
            child: GestureDetector(
              onTap: () {
                // Aksi ketika teks diklik
                print('register page call!');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterForm()),
                );
              },
              child: const Text(
                "Don't have account?",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue,
                  // decoration: TextDecoration
                  //     .underline, // Opsional, jika ingin menambahkan garis bawah
                ),
              ),
            ),
          ),
        ));
  }
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

// Future<void> getToken() async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   // Mendapatkan registration token
//   String? token = await messaging.getToken();
//   print("FCM Registration Token: $token");
// }

Future<void> _fetchLogin(context, email, password) async {
  // Contoh menyimpan token setelah login berhasil
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Map response = await UserServices.authentication(email, password);
  print("login response: $response");
  if (response['error'] != null) {
    print("login error");
    showMessageDialog(context, response['error']);
    // Navigator.pushReplacement(
    // context,
    // MaterialPageRoute(builder: (context) => const LoginForm()),
    // );
  } else {
    print("login success");
    // await prefs.setString('token', 'token_test');
    await prefs.setString('token', response['token']);
    String userId = '${response['user_id']}';
    await prefs.setString('user_id', userId);
    // getToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigation(index: 1)),
    );
  }
}

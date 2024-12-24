import 'package:flutter/material.dart';
import 'package:sana_mobile/services/user_services.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isPasswordVisible = false;

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

  void _register() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String passwordConfirm = _confirmPasswordController.text.trim();
    String name = _nameController.text.trim();

    // Check if fields are empty
    if (email.isEmpty ||
        password.isEmpty ||
        passwordConfirm.isEmpty ||
        name.isEmpty) {
      _showAlertDialog('Required fields cannot be empty.');
      return;
    }

    // Check if email format is valid
    if (!_isValidEmail(email)) {
      _showAlertDialog('Email must be a valid email format.');
      return;
    }

    if (password != passwordConfirm) {
      _showAlertDialog('password do not match');
      return;
    }

    // If all validations pass, proceed with Register logic
    print('Name: $name');
    print('Email: $email');
    print('Password: $password');
    print('PasswordConfirm: $passwordConfirm');

    Map<String, dynamic> inputData = {
      'name': name,
      'email': email,
      'password': password,
      'confirm_password': passwordConfirm
    };

    print(inputData);
    // Add your Register logic here (e.g., API call)
    _fetchRegister(context, inputData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: registerForm(),
            )),
      ),
    );
  }

  Container registerForm() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title text 'Register'
          const Text(
            'Register',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),

          // Email field
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
                  hintText: 'Enter your name',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

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

          // Password confirm field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password Confirm',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              TextField(
                controller: _confirmPasswordController,
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
                  hintText: 'Enter your confirm password',
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

          // Register button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Text color
              ),
              child: const Text('Register'),
            ),
          ),

          loginButton(),
        ],
      ),
    );
  }

  SizedBox loginButton() {
    return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Center(
            child: GestureDetector(
              onTap: () {
                // Aksi ketika teks diklik
                print('Login page call!');
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login', // Replace '/login' with the route name for your login screen
                  (route) => false,
                );
              },
              child: const Text(
                "Already have account!",
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

showMessageDialog(
    BuildContext context, String title, String message, bool success) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
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
              if (!success) {
                Navigator.pop(context);
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login', // Replace '/Register' with the route name for your Register screen
                  (route) => false,
                );
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> _fetchRegister(context, data) async {
  // Contoh menyimpan token setelah Register berhasil
  Map response = await UserServices.authRegister(data);
  print("Register response: $response");
  if (response['error'] != null) {
    print("Register error");
    showMessageDialog(context, "Register gagal!", response['error'], false);
    // Navigator.pushReplacement(
    // context,
    // MaterialPageRoute(builder: (context) => const RegisterForm()),
    // );
  } else {
    print("Register success");
    showMessageDialog(context, "successfully!", response['message'], true);
    // await prefs.setString('token', 'token_test');
    // await prefs.setString('token', response['token']);
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const MainNavigation()),
    // );
  }
}

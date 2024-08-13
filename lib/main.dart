import 'package:flutter/material.dart';
import 'package:sana_mobile/screen/home.dart';
import 'package:sana_mobile/screen/profile.dart';
import 'package:sana_mobile/screen/sana.dart';
import 'package:sana_mobile/screen/chat_screen.dart';
// import 'package:sana_mobile/screen/menu.dart';
// import 'package:sana_mobile/screen/message.dart';
// import 'package:sana_mobile/screen/notification_screen.dart';

/// Flutter code sample for [NavigationBar].

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 1;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radio_button_unchecked_sharp),
            activeIcon: Icon(Icons.radio_button_checked_sharp),
            label: 'Sana',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat_rounded),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        unselectedItemColor: Colors.black,
        unselectedIconTheme: const IconThemeData(size: 30),
        unselectedLabelStyle:
            const TextStyle(color: Colors.black, fontSize: 12),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueGrey[900],
        selectedLabelStyle: optionStyle,
        selectedIconTheme: const IconThemeData(size: 35),
        onTap: _onItemTapped,
      ),
      body: <Widget>[
        /// Home page
        const HomeScreen(),

        // Sana Page
        const SanaScreen(),

        // Chat Page
        const ChatScreen(),

        // profile
        const ProfileScreen(),
      ][_selectedIndex],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

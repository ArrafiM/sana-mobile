import 'package:flutter/material.dart';
import 'package:sana_mobile/screen/home.dart';
import 'package:sana_mobile/screen/profile.dart';
import 'package:sana_mobile/screen/sana.dart';

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
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.chat_outlined),
          //   activeIcon: Icon(Icons.chat_rounded),
          //   label: 'Chats',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        unselectedItemColor: Colors.black,
        unselectedIconTheme: const IconThemeData(size: 20),
        unselectedLabelStyle:
            const TextStyle(color: Colors.black, fontSize: 12),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueGrey[900],
        selectedLabelStyle: optionStyle,
        selectedIconTheme: const IconThemeData(size: 25),
        onTap: _onItemTapped,
      ),
      body: <Widget>[
        /// Home page
        const HomeScreen(),

        // Sana Page
        const SanaScreen(),

        // Chat Page
        // const ChatScreen(),

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
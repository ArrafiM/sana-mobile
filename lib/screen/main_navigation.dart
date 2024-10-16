import 'package:flutter/material.dart';
import 'package:sana_mobile/screen/merchant_screen.dart';
import 'package:sana_mobile/screen/explore_screen.dart';
import 'package:sana_mobile/screen/sana.dart';

class MainNavigation extends StatefulWidget {
  final int index;
  const MainNavigation({Key? key, required this.index}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 1;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedIndex = widget.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
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
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'Merchant',
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
        const ExploreScreen(),
        const SanaScreen(),
        const MerchantScreen()
      ][_selectedIndex],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

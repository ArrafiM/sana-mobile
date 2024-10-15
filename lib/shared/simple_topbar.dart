import 'package:flutter/material.dart';

class SimpleTopBar extends StatelessWidget implements PreferredSizeWidget {
  const SimpleTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "My merchant",
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/material.dart';

class MenuBar extends StatelessWidget implements PreferredSizeWidget {
  const MenuBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('강원 🧡 정윤 가계부', style: TextStyle(color: Colors.white)),
      backgroundColor: Theme.of(context).primaryColor,
      iconTheme: IconThemeData(color: Colors.white),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

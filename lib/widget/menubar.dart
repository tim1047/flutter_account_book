import 'package:flutter/material.dart';

class MenuBar extends StatelessWidget implements PreferredSizeWidget {
  const MenuBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('강원 🧡 정윤 가계부'),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

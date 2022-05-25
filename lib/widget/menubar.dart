import 'package:flutter/material.dart';

class MenuBar extends StatelessWidget with PreferredSizeWidget{
  const MenuBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('강원 🧡 정윤 가계부'),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
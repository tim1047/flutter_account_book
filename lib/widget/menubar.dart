import 'package:flutter/material.dart';

class MenuBar extends StatelessWidget with PreferredSizeWidget{
  const MenuBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('๊ฐ์ ๐งก ์ ์ค ๊ฐ๊ณ๋ถ'),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
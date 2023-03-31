import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  bool darkTheme = false;

  bool get theme => darkTheme;

  ThemeNotifier() {
    darkTheme = false;
  }

  changeTheme() {
    darkTheme = !darkTheme;
    notifyListeners();
  }
}
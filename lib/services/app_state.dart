import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool _amharicMode = false;
  bool get amharicMode => _amharicMode;

  void toggleAmharic() {
    _amharicMode = !_amharicMode;
    notifyListeners();
  }

  String t(String english, String amharic) => _amharicMode ? amharic : english;
}

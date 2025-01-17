import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontService extends ChangeNotifier {
  static final FontService _instance = FontService._();
  factory FontService() => _instance;
  
  FontService._() {
    _loadFontSize();
  }

  double _fontBoyutu = 1.0;
  double get fontBoyutu => _fontBoyutu;

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    _fontBoyutu = prefs.getDouble('font_boyutu') ?? 1.0;
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    if (size >= 0.8 && size <= 1.4) {
      final prefs = await SharedPreferences.getInstance();
      _fontBoyutu = size;
      await prefs.setDouble('font_boyutu', size);
      notifyListeners();
    }
  }
} 
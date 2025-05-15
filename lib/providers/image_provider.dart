import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../model/filter.dart';

class AppImageProvider extends ChangeNotifier {
  Uint8List? _currentImage;
  Filter? _currentFilter;

  Uint8List? get currentImage => _currentImage;
  Filter? get currentFilter => _currentFilter;

  void changeImageFile(File image) {
    _currentImage = image.readAsBytesSync();
    notifyListeners();
  }
  void changeImage(Uint8List image) {
    _currentImage = image;
    notifyListeners();
  }

  void changeFilter(Filter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void clear() {
    _currentImage = null;
    _currentFilter = null;
    notifyListeners();
  }
}
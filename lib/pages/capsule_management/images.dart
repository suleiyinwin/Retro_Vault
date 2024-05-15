import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class StagedImages extends ChangeNotifier {
  List<Uint8List?> images = List<Uint8List?>.filled(10, null);

  void fill(Uint8List newImage) {
    for (int i = 0; i <= 9; i++) {
      if (images[i] == null) {
        images[i] = newImage;
        break;
      }
    }
    notifyListeners();
  }

  int freeCount() {
    int count = 0;

    for (final image in images) {
      if (image == null) count++;
    }

    return count;
  }

  void removeByContent(Uint8List bytes) {
    images[images.indexOf(bytes)] = null;
    notifyListeners();
  }

  void clear() {
    images = List<Uint8List?>.filled(10, null);
  }
}

class CapsuleImages extends ChangeNotifier {
  List<String> images;

  CapsuleImages({required this.images});

  int freeCount() {
    int count = 0;

    for (final image in images) {
      if (image.isEmpty) count++;
    }

    return count;
  }

  void fill(String newImage) {
    for (int i = 0; i <= 9; i++) {
      if (images[i].isEmpty) {
        images[i] = newImage;
        break;
      }
    }
  }

  void replaceAt(int index, String newImage) {
    images[index] = newImage;
    notifyListeners();
  }

  void removeByUrl(String url) {
    for (int i = 0; i <= 9; i++) {
      if (images[i] == url) {
        images[i] = '';
        break;
      }
    }
    notifyListeners();
  }

  List<int> freeIndices() {
    List<int> free = [];

    for (int i = 0; i <= 9; ++i) {
      if (images[i].isEmpty) {
        free.add(i);
      }
    }

    return free;
  }
}
import 'package:flutter/cupertino.dart';

import '../models/image_model.dart';

class ChatProvider with ChangeNotifier{
  List<ImageModel?> images = [];
  int imageListSize = 0;

  updateUI() {
    notifyListeners();
  }
  set imageListSizeVale(int val) {
    imageListSize = val;
  }
}

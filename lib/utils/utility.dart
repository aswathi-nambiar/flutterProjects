import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../models/image_model.dart';
import 'constants.dart';

class Utility {
  static String getInitials(String name) => name.isNotEmpty
      ? name.trim().split(RegExp(' +')).map((s) => s[0]).take(2).join()
      : '';

  static Uint8List imageFromBase64String({String? base64String}) {
    return base64Decode(base64String ?? '');
  }

  static Future<File?> testCompressAndGetFile(File file) async {
    final filePath = file.absolute.path;
    bool isPngImage = false;
    if (filePath.endsWith('.png')) {
      isPngImage = true;
    }
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp|.pn'));
    final splitter = filePath.substring(0, (lastIndex));
    final targetPath = "${splitter}_out${filePath.substring(lastIndex)}";
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: isPngImage ? 40 : 80,
      format: isPngImage ? CompressFormat.png : CompressFormat.jpeg,
    );

    return result;
  }

  static Future<int> updateFileSize(ImageModel? file, int curSize) async {
    Uint8List fileInUnit8List =
        imageFromBase64String(base64String: file?.base64);
    int bytes = fileInUnit8List.lengthInBytes;
    return curSize - bytes;
  }

  static canUpload(int curFileSize, List<ImageModel?> images,
      {bool uploadingMultiSelect = false}) {
    int maxAllowedImageSize = uploadingMultiSelect ? 5 : 4;

    if (curFileSize <= maxAllowedLimit &&
        images.length <= maxAllowedImageSize) {
      return true;
    }
    return false;
  }

  static Future<File?> getCompressedImage(
    XFile? imageFile,
  ) async {
    File file = File(imageFile!.path);
    int originalImageBytes = imageFile != null ? await imageFile.length() : 0;
    var kb = originalImageBytes / 1024;
    var mb = kb / 1024;
    print('ORIGINAL IMAGE SIZE in mb:${mb}');

    //compress the image
    File? result = await Utility.testCompressAndGetFile(file);

    return result;
  }
}

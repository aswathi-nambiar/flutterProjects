import 'dart:typed_data';

class ImageModel {
  String? base64;
  int? imageId;
  String? imageName;
  Uint8List? decodedString;

  ImageModel(
      {this.base64, this.imageId = 0, this.imageName, this.decodedString});
}

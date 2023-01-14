import 'package:flutter/cupertino.dart';

import 'image_upload_section.dart';


class ImageUpload extends StatelessWidget {
  const ImageUpload({
    Key? key,
    required this.onUploadNotAllowed,
  }) : super(key: key);
  final ValueChanged<String>? onUploadNotAllowed;

  @override
  Widget build(BuildContext context) {
    return ImageUploadView(
      onUploadError: _handleUploadNotPossible,
    );
  }

  _handleUploadNotPossible(String message) {
    onUploadNotAllowed!(message);
  }
}

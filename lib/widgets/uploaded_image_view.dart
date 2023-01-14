import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../models/image_model.dart';

class UploadedImage extends StatelessWidget {
  final ImageModel uploadedFile;
  final ValueChanged<ImageModel?>? onTap;

  const UploadedImage(
      {Key? key, required this.uploadedFile, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.loose,
      clipBehavior: Clip.hardEdge,
      children: [
        Container(
          height: 90,
          margin: const EdgeInsets.only(right: 15),
          child: Container(
            padding: EdgeInsets.zero,
            child: ((uploadedFile.decodedString?.length ?? 0) > 0)
                ? Image.memory(
                    uploadedFile.decodedString ?? Uint8List(0),
                    fit: BoxFit.cover,
                  )
                : Container(),
          ),
        ),
        Positioned(
          top: 0,
          right: 0.0,
          child: SizedBox(
            width: 20,
            height: 20,
            child: MaterialButton(
              onPressed: () {
                onTap!(uploadedFile);
              },
              color: Colors.red,
              textColor: Colors.white,
              padding: const EdgeInsets.all(3),
              shape: const CircleBorder(),
              child: Icon(
                Icons.clear,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

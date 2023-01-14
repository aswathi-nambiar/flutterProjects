import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:doctors_app/widgets/uploaded_image_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../utils/constants.dart';
import '../data_provider/chat_provider.dart';
import '../models/image_model.dart';
import '../utils/utility.dart';

class ImageUploadView extends StatefulWidget {
  final ValueChanged<String>? onUploadError;

  const ImageUploadView({Key? key, required this.onUploadError})
      : super(key: key);

  @override
  ImageUploadViewState createState() => ImageUploadViewState();
}

class ImageUploadViewState extends State<ImageUploadView> {
  ImageUploadViewState();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Shows the bottomsheet with options of Camera, Gallery and Cancel
  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // image picker with Gallery as the source
              _handleImagePickChoice();
            },
            child: Text('Gallery'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // image picker with camera as the source
              _handleImagePickChoice(isCamera: true);
            },
            child: Text('Camera'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var images = Provider.of<ChatProvider>(context, listen: false).images;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dimen_8),
      ),
      child: Column(
        children: [
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              if (images.isEmpty) {
                _showActionSheet(context);
              }
            },
            child: ListTile(
              contentPadding: const EdgeInsets.only(
                  left: dimen_12, right: dimen_12, bottom: dimen_10),
              horizontalTitleGap: dimen_10,
              minLeadingWidth: dimen_0,
              leading: SvgPicture.asset(
                'assets/images/camera.svg',
                width: dimen_20,
                height: dimen_15,
                color: Colors.black,
              ),
              title: _getUploadImageHeader(),
            ),
          ),
          Visibility(
            visible: images.isNotEmpty ? true : false,
            child: _getUploadedImagesView(),
          ),
        ],
      ),
    );
  }

  /// return Uploaded Files header for image section
  _getUploadImageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 11.0),
          child: Text(
            'Upload File',
            style: const TextStyle(fontSize: dimen_15),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
              '(You can upload 5 images and total size should not exceed more than 5MB)',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xff000000).withOpacity(0.5),
              )),
        ),
      ],
    );
  }

  /// Return the Listview of Uploaded images
  _getUploadedImagesView() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _getUploadedImages(),
      ),
    );
  }

  /// Returns the Add new Image Widget
  _getPlusButtonView() {
    var images = Provider.of<ChatProvider>(context, listen: false).images;
    var imageListSize =
        Provider.of<ChatProvider>(context, listen: false).imageListSize ??
            0;
    return GestureDetector(
      onTap: () {
        if (Utility.canUpload(imageListSize, images)) {
          _showActionSheet(context);
        }
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.all(0),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Utility.canUpload(imageListSize, images)
                    ? primaryColor
                    : disableButtonColor,
                width: 2,
              ),
            ),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: Utility.canUpload(imageListSize, images)
                        ? primaryColor
                        : disableButtonColor,
                    size: 15,
                  ),
                  Text(
                    'add'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Utility.canUpload(imageListSize, images)
                          ? primaryColor
                          : disableButtonColor,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Return the Widget showing the list of uploaded images
  _getUploadedImages() {
    var images = Provider.of<ChatProvider>(context, listen: false).images;
    var imageListSize =
        Provider.of<ChatProvider>(context, listen: false).imageListSize ??
            0;

    List<Widget> imageWidgets = [];
    if (images.isNotEmpty) {
      for (ImageModel? selectedImage in images) {
        if (selectedImage != null) {
          imageWidgets.add(UploadedImage(
            uploadedFile: selectedImage,
            onTap: _handleDelete,
          ));
        }
      }
    }

    if (imageWidgets.isNotEmpty && Utility.canUpload(imageListSize, images)) {
      imageWidgets.insert(0, _getPlusButtonView());
    }
    return imageWidgets;
  }

  /// This function handles the deletion of the uploaded image
  void _handleDelete(ImageModel? file) {
    var images = Provider.of<ChatProvider>(context, listen: false).images;
    var imageListSize =
        Provider.of<ChatProvider>(context, listen: false).imageListSize;
    images.removeWhere((element) => element?.base64 == file?.base64);

    Utility.updateFileSize(file, imageListSize).then((value) =>
        Provider.of<ChatProvider>(context, listen: false)
            .imageListSizeVale = value);
    setState(() {});
  }


  //Image picker related

  final ImagePicker _picker = ImagePicker();

  /// This function handles the image picked through the gallery or camera. It compresses
  /// the image if it is greater than 1mb and performs the check of upload restriction
  /// of maximum 5 images or 5MB.

  Future<void> _handleImagePickChoice({bool isCamera = false}) async {
    var images = Provider.of<ChatProvider>(context, listen: false).images;
    int imageListSize =
        Provider.of<ChatProvider>(context, listen: false).imageListSize;
    List<XFile?>? pickedFileList = [];

    // if the user has chosen Camera option
    if (isCamera) {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: null,
        maxHeight: null,
        imageQuality: null,
      );
      if (pickedFile != null) {
        pickedFileList.add(pickedFile);
      }
    }
    // if the user has chosen Gallery option
    else {
      pickedFileList = await _picker.pickMultiImage(
        maxWidth: null,
        maxHeight: null,
        imageQuality: null,
      );
    }

    try {
      if (pickedFileList != null) {
        int runningSize = 0;
        for (XFile? imageFile in pickedFileList) {
          XFile? selectedImage;
          int originalImageBytes =
              imageFile != null ? await imageFile.length() : 0;
          // Checking if the selected image is greater than 1 Mb. If it is greater than 1Mb then that image will be compressed.
          if (originalImageBytes > oneMb) {
            File? result = await Utility.getCompressedImage(imageFile);
            XFile newlyCompressedFile = XFile(result!.path);
            int newByte = await newlyCompressedFile.length();
            originalImageBytes = newByte;
            var newkb = newByte / 1024;
            var newmb = newkb / 1024;
            print('NEW IMAGE SIZE AFTER COMPRESSION in mb:$newmb');

            selectedImage = newlyCompressedFile;
          } else {
            selectedImage = imageFile;
            // will remove the below commented code once the edit flow is tested
            int imagEByetesNew = await selectedImage?.length() ?? 0;
            /* var newkb1 = imagEByetesNew / 1024;
            var newmb1 = newkb1 / 1024;
            print(' IMAGE SIZE WITHOUT COMPRESSION <1Mb in mb:$newmb1');*/
          }
          File newfile = File(selectedImage!.path);
          List<int> newimageBytes = newfile.readAsBytesSync();

          /// need to remove the below code later on
          String base64OfSelectedImage = base64Encode(newimageBytes);
          Uint8List fileInUnit8List = Utility.imageFromBase64String(
              base64String: base64OfSelectedImage);

          // will remove the below commented code once the edit flow is tested
          /*int length = fileInUnit8List.lengthInBytes;
          var newkb2 = length / 1024;
          var newmb2 = newkb2 / 1024;
          print('IMAGE SIZE of BASE64  : $newmb2');*/

          //check if all the images added have size combined lesser than 5mb
          List<ImageModel?>? imageFiles = [];
          imageFiles.addAll(images);
          imageFiles.add(ImageModel(
              base64: base64OfSelectedImage,
              imageName: selectedImage.name,
              decodedString: fileInUnit8List));

          runningSize += originalImageBytes;

          int updatedSize = runningSize + imageListSize;
          if (updatedSize >= maxAllowedLimit) {
            widget.onUploadError!(
                'You can upload maximum 5 images and total size should not exceed more than 5MB');

            break;
          }

          if (Utility.canUpload(updatedSize, imageFiles,
              uploadingMultiSelect: true)) {
            if (selectedImage != null) {
              setState(() {
                images.add(ImageModel(
                    base64: base64OfSelectedImage,
                    decodedString: fileInUnit8List,
                    imageName: selectedImage?.name));
              });
              if (!mounted) return;
              Provider.of<ChatProvider>(context, listen: false)
                  .imageListSizeVale = updatedSize;
              Provider.of<ChatProvider>(context, listen: false)
                  .updateUI();
            }
          } else {
            widget.onUploadError!(
                'You can upload maximum 5 images and total size should not exceed more than 5MB');
          }
        }
      }
    } catch (e) {
      setState(() {
        widget.onUploadError!(e.toString());
      });
    }
  }
}

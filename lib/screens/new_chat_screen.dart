import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:doctors_app/utils/responsive_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import 'package:doctors_app/utils/utils.dart';
import 'package:doctors_app/widgets/widgets.dart';

import '../data_provider/chat_provider.dart';
import '../models/image_model.dart';
import '../utils/utility.dart';
import 'common_snackbar.dart';

class NewChatScreen extends StatelessWidget {
  final String doctorName;
  final String doctorImage;
  final bool isOnline;
  final bool isChatBot;

  final ValueChanged<String>? onUploadNotAllowed;
  const NewChatScreen({
    Key? key,
    required this.doctorName,
    required this.doctorImage,
    required this.isOnline,
    required this.onUploadNotAllowed,
    this.isChatBot = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Stack(
        children: [
          SizedBox(
            height: 81.h,
            child: ChatListView(
              isChatBot: isChatBot,
            ),
          ),
          ChatButtonBar(
            onUploadError: _handleUploadNotPossible,
          ),
        ],
      ),
    );
  }

  _handleUploadNotPossible(String message) {
    onUploadNotAllowed!(message);
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: SafeArea(
        child: Container(
          decoration: kBoxDecoIndigo,
          padding: EdgeInsets.only(right: 1.5.h, top: 0.5.h),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black87,
                ),
              ),
              CachedImage(
                doctorImage: doctorImage,
                height: 40.0,
                width: 40.0,
              ),
              SizedBox(
                width: 1.5.h,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      doctorName,
                      style: GoogleFonts.yantramanav(
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isOnline == false ? 'Offline' : 'Online',
                      style: GoogleFonts.yantramanav(
                        color: Colors.grey.shade600,
                        fontSize: 12.0.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatButtonBar extends StatefulWidget {
  final ValueChanged<String>? onUploadError;
  const ChatButtonBar({Key? key, required this.onUploadError})
      : super(key: key);

  @override
  State<ChatButtonBar> createState() => _ChatButtonBarState();
}

class _ChatButtonBarState extends State<ChatButtonBar> {
  @override
  Widget build(BuildContext context) {
    var images = Provider.of<ChatProvider>(context, listen: false).images;
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: EdgeInsets.all(1.0.h),
        color: Colors.white,
        height: 8.0.h,
        width: double.infinity,
        child: Row(
          children: [
            InkWell(
              onTap: () {
                if (images.isEmpty) {
                  _showActionSheet(context);
                }
              },
              child: Icon(
                UniconsLine.paperclip,
                color: Colors.grey.shade400,
                size: 30.0,
              ),
            ),
            SizedBox(
              width: 1.5.h,
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  isDense: true,
                  hintText: "Write message...",
                  hintStyle: GoogleFonts.yantramanav(
                    color: Colors.black54,
                    fontSize: 16.0.sp,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(
              width: 1.5.h,
            ),
            FloatingActionButton(
              onPressed: () {},
              child: const Icon(
                UniconsLine.message,
                color: Colors.white,
                size: 20,
              ),
              backgroundColor: const Color(0xff1651DA),
              elevation: 0,
            ),
          ],
        ),
      ),
    );
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
              Provider.of<ChatProvider>(context, listen: false).updateUI();
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

class ChatListView extends StatelessWidget {
  final bool isChatBot;
  const ChatListView({
    Key? key,
    this.isChatBot = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: isChatBot ? chatBotsChat.length : chats.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: kBoxDecoIndigo,
            height: 12.h,
            padding: const EdgeInsets.only(
              left: 15.0,
              right: 15.0,
              top: 10.0,
              bottom: 15.0,
            ),
            child: Align(
              alignment: ((isChatBot
                          ? chatBotsChat[index].messageType
                          : chats[index].messageType) ==
                      'receiver'
                  ? Alignment.topLeft
                  : Alignment.topRight),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: ((isChatBot
                              ? chatBotsChat[index].messageType
                              : chats[index].messageType) ==
                          'receiver'
                      ? Colors.grey.withOpacity(0.2)
                      : Colors.blue.shade200),
                ),
                padding: EdgeInsets.all(2.0.h),
                child: Text(
                  isChatBot
                      ? chatBotsChat[index].message
                      : chats[index].message,
                  style: TextStyle(fontSize: 12.0.sp),
                ),
              ),
            ),
          );
        });
  }
}

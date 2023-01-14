import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/constants.dart';

typedef OnSnackBarClose();

showSnackBar(
    {required BuildContext context,
    required String message,
    String? assetPath,
    String? packageName,
    //create, update, cancel
    bool? forWorkOrderSuccessOperation = false,
    OnSnackBarClose? onSnackBarClose}) {
  SnackBar snackBar = createSnackBar(
      message, assetPath, packageName, forWorkOrderSuccessOperation);
  var showSnackBar = ScaffoldMessenger.of(context).showSnackBar(snackBar);

  showSnackBar.closed.then((value) {
    onSnackBarClose?.call();
  });
}

SnackBar createSnackBar(String message, String? assetPath, String? packageName,
    bool? forWorkOrderSuccessOperation) {
  if (forWorkOrderSuccessOperation ?? false) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 2000),
      content: getSnackBarContent(message, assetPath, packageName),
    );
  } else {
    return SnackBar(
      duration: const Duration(milliseconds: 4000),
      content: getSnackBarContent(message, assetPath, packageName),
    );
  }
}

Widget getSnackBarContent(
    String message, String? assetPath, String? packageName) {
  return Row(
    children: [
      assetPath != null && assetPath != ''
          ? SvgPicture.asset(
              assetPath,
              package: packageName ?? '',
            )
          : const SizedBox(
              height: dimen_4,
            ),
      Flexible(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

displayError({String title, String message}) {
  Get.snackbar(
    title ?? "Error",
    message ?? "Oops something went wrong",
    backgroundColor: Colors.red,
    colorText: Colors.white,
    icon: Icon(FontAwesomeIcons.exclamationCircle, color: Colors.white),
    shouldIconPulse: true,
    onTap: (_) {},
    barBlur: 20,
    isDismissible: true,
    duration: Duration(seconds: 5),
  );
}
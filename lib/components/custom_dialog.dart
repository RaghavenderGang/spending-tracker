import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class CustomDialog {
  void showErrorDialog(BuildContext context, String title, Exception e,
      String details, Function _backPress) {
    AwesomeDialog(
      context: context,
      animType: AnimType.TOPSLIDE,
      dialogType: DialogType.ERROR,
      title: title,
      desc: details == "" ? '${(e as dynamic).message}' : details,
      btnOkOnPress: _backPress,
      btnOkColor: Colors.red,
    ).show();
  }

  void showSuccessDialog(
      BuildContext context, String title, String details, Function _backPress) {
    AwesomeDialog(
      context: context,
      animType: AnimType.TOPSLIDE,
      dialogType: DialogType.SUCCES,
      title: title,
      desc: details,
      btnOkOnPress: _backPress,
      btnOkColor: Colors.green,
    ).show();
  }
}

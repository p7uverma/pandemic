import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(content),
      ),
    );
}

void hideKeyboard() {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

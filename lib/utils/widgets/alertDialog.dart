import 'package:flutter/material.dart';
showAlert(
    {required String title, required String text, required bool actions,required context}) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () => Future.value(false),
            child:AlertDialog(
              title: Text(title),
              content: Text(text),
              actions: [
                (actions)
                    ? ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'))
                    : Container()
              ],
            ));
      });
}
import 'package:flutter/material.dart';

class CustomProgressDialog {
  final BuildContext _context;
  bool _isShowing = false;

  CustomProgressDialog(this._context);

  // Show the progress dialog
  void show({String message = "Loading..."}) {
    if (_isShowing) return; // Prevent showing multiple dialogs

    _isShowing = true;

    showDialog(
      context: _context,
      barrierDismissible: false, // Prevent dismissing dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  // Hide the progress dialog
  void hide() {
    if (!_isShowing) return; // Only hide if it's showing

    _isShowing = false;
    Navigator.pop(_context); // Close the dialog
  }

  // Dismiss method, which can be used to close the dialog explicitly
  void dismiss() {
    if (_isShowing) {
      _isShowing = false;
      Navigator.pop(_context); // Close the dialog
    }
  }

  // Getter to check if the dialog is currently showing
  bool get isShowing => _isShowing;
}

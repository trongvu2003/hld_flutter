import 'package:flutter/material.dart';

class AppDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String content,
    String cancelText = 'Huỷ',
    String confirmText = 'OK',
    VoidCallback? onConfirm,
    Color? confirmColor,
  }) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
            child: Text(
              confirmText,
              style: TextStyle(color: confirmColor ?? Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
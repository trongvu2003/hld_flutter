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
    Color? cancelColor,
    Color? backgroundColor,
    Color? cancelBgColor,
    Color? confirmBgColor,
  }) {
    return showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: backgroundColor,
            title: Text(title),
            content: Text(content),
            actions: [
              // Nút Huỷ
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: cancelBgColor,
                  foregroundColor: cancelColor ?? Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(cancelText),
              ),

              // Nút OK/Xác nhận
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: confirmBgColor,
                  foregroundColor: confirmColor ?? Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (onConfirm != null) onConfirm();
                },
                child: Text(confirmText),
              ),
            ],
          ),
    );
  }
}

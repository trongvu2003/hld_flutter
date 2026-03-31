import 'package:flutter/material.dart';

class PostStatusToast extends StatelessWidget {
  final bool isCreating;
  final bool isSuccess;
  final double progress;

  const PostStatusToast({
    super.key,
    required this.isCreating,
    required this.isSuccess,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 90.0),
          child: Material(
            elevation: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCreating) ...[
                    Text(
                      "Đang đăng bài...",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                    ),
                  ] else if (isSuccess) ...[
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Đăng bài thành công",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AvatarDetailDialog extends StatelessWidget {
  final String mediaUrl;

  const AvatarDetailDialog({Key? key, required this.mediaUrl})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0, // Độ zoom tối đa
            child: Center(
              child: CachedNetworkImage(
                imageUrl: mediaUrl,
                fit: BoxFit.contain,
                placeholder:
                    (context, url) =>
                        const CircularProgressIndicator(color: Colors.white),
                errorWidget:
                    (context, url, error) =>
                        const Icon(Icons.error, color: Colors.white, size: 50),
              ),
            ),
          ),

          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

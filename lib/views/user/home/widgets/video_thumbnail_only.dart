  import 'package:flutter/material.dart';
  import 'package:video_player/video_player.dart';

  class VideoThumbnailOnly extends StatefulWidget {
    final String videoUrl;

    const VideoThumbnailOnly({super.key, required this.videoUrl});

    @override
    State<VideoThumbnailOnly> createState() => _VideoThumbnailOnlyState();
  }

  class _VideoThumbnailOnlyState extends State<VideoThumbnailOnly> {
    late VideoPlayerController _controller;
    bool _isInitialized = false;

    @override
    void initState() {
      super.initState();
      // Chỉ khởi tạo để lấy khung hình đầu tiên, KHÔNG gọi _controller.play()
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        ..initialize().then((_) {
          // Kiểm tra mounted để tránh lỗi nếu widget bị huỷ trước khi load xong
          if (mounted) {
            setState(() {
              _isInitialized = true;
            });
          }
        });
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      if (!_isInitialized) {
        return Container(
          width: double.infinity, // 👈 FULL WIDTH
          height: 200,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      final ratio = _controller.value.aspectRatio;

      double maxHeight;
      if (ratio < 1) {
        maxHeight = 350;
      } else {
        maxHeight = 250;
      }

      return SizedBox(
        width: double.infinity, // 👈 QUAN TRỌNG
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: ratio,
                child: VideoPlayer(_controller),
              ),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
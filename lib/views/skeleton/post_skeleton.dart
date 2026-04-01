import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hld_flutter/views/skeleton/skeleton_box.dart';

class PostSkeleton extends StatelessWidget {
  const PostSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Sử dụng ClipOval bọc ngoài Skeleton để tạo hình tròn hoàn hảo cho Avatar
              ClipOval(child: Skeleton(width: 45, height: 45, radius: 22.5)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 120, height: 16, radius: 4), // Tên
                  const SizedBox(height: 6),
                  Skeleton(width: 80, height: 12, radius: 4), // Thời gian
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content text placeholders (Bo góc nhẹ)
          Skeleton(width: double.infinity, height: 14, radius: 4),
          const SizedBox(height: 6),
          Skeleton(width: double.infinity, height: 14, radius: 4),
          const SizedBox(height: 6),
          Skeleton(width: 200, height: 14, radius: 4),
          const SizedBox(height: 16),

          Skeleton(width: double.infinity, height: 200, radius: 12),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Skeleton(width: 40, height: 20, radius: 4),
              Skeleton(width: 40, height: 20, radius: 4),
              Skeleton(width: 40, height: 20, radius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

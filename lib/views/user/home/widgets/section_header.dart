import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import 'scale_button.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback? onSeeAllClick;

  const SectionHeader({
    required this.title,
    this.isExpanded = false,
    this.onSeeAllClick,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.lightTheme,
            ),
          ),
          if (onSeeAllClick != null)
            ScaleButton(
              onTap: onSeeAllClick!,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(blurRadius: 4, color: Colors.black12),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      isExpanded ? 'Thu gọn' : 'Xem tất cả',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.double_arrow,
                      size: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
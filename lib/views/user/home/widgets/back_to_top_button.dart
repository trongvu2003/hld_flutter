// BACK TO TOP BUTTON - tương đương BackToTopButton với shimmer
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class BackToTopButton extends StatefulWidget {
  final VoidCallback onTap;

  const BackToTopButton({required this.onTap});

  @override
  State<BackToTopButton> createState() => BackToTopButtonState();
}

class BackToTopButtonState extends State<BackToTopButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final v = _ctrl.value;
          return Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 12,
                  color: Colors.black26,
                  offset: Offset(0, 4),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [
                  (v - 0.3).clamp(0.0, 1.0),
                  v.clamp(0.0, 1.0),
                  (v + 0.3).clamp(0.0, 1.0),
                ],
                colors: [
                  AppColors.lightTheme.withOpacity(0.8),
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.8),
                  Colors.grey,
                ],
              ),
            ),
            child: Icon(
              Icons.keyboard_double_arrow_up,
              size: 28,
              color: Colors.black,
            ),
          );
        },
      ),
    );
  }
}
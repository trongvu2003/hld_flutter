import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hld_flutter/theme/app_colors.dart';

class FootBar extends StatefulWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final VoidCallback? onCreatePost;

  const FootBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCreatePost,
  });

  @override
  State<FootBar> createState() => _FootBarState();
}

class _FootBarState extends State<FootBar> with SingleTickerProviderStateMixin {
  late AnimationController _rotateCtrl;

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // thêm space cho FAB nhô lên
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 16,
                    color: Colors.black26,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _TabItem(
                    label: 'Trang chủ',
                    icon: Icons.home,
                    isSelected: widget.currentIndex == 0,
                    onTap: () => widget.onTap(0),
                  ),
                  _TabItem(
                    label: 'Lịch hẹn',
                    icon: Icons.calendar_today,
                    isSelected: widget.currentIndex == 1,
                    onTap: () => widget.onTap(1),
                  ),

                  const SizedBox(width: 64),

                  _TabItem(
                    label: 'Thông báo',
                    icon: Icons.notifications,
                    isSelected: widget.currentIndex == 2,
                    onTap: () => widget.onTap(2),
                  ),
                  _TabItem(
                    label: 'Cá nhân',
                    icon: Icons.person,
                    isSelected: widget.currentIndex == 3,
                    onTap: () => widget.onTap(3),
                  ),
                ],
              ),
            ),
          ),

          //  FAB xoay (tương đương CircleButton)
          Positioned(
            top: 0, // nhô lên trên bar 20dp - tương đương offset(y=-20)
            child: _RotatingFab(
              rotateCtrl: _rotateCtrl,
              onTap: () {
                Navigator.pushNamed(context, '/createpost');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tương đương animateColorAsState backgroundColor
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightTheme : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 4),

            // Tương đương offsetY animation
            AnimatedSlide(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              // isSelected → y=0, không selected → y lên nhẹ
              offset: isSelected ? Offset.zero : const Offset(0, -0.3),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: isSelected ? 1.0 : 0.8,
                child: Icon(
                  icon,
                  size: 24,
                  // Tương đương: isSelected → onBackground, else → secondary.copy(0.7)
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.onBackground
                          : Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.7),
                ),
              ),
            ),

            const SizedBox(height: 4),

            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 500),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.onBackground
                        : Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.7),
              ),
              child: Text(label),
            ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ── ROTATING FAB - tương đương CircleButton
class _RotatingFab extends StatelessWidget {
  final AnimationController rotateCtrl;
  final VoidCallback onTap;
  final double size;

  const _RotatingFab({
    required this.rotateCtrl,
    required this.onTap,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: rotateCtrl,
          builder: (context, child) {
            final angle = rotateCtrl.value * 2 * pi;
            return Stack(
              alignment: Alignment.center,
              children: [
                // ── Rotating gradient border ─────────────────
                // Tương đương graphicsLayer { rotationZ = angle } + border(brandBrush)
                Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          Color(0xFFFFD846),
                          Color(0xFFFF9F43),
                          Colors.white,
                          Color(0xFFFFD846),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Static background (không xoay) ───────────
                // Tương đương graphicsLayer { rotationZ = -angle } + background
                Container(
                  width: size - 7, // border width = 3dp mỗi bên
                  height: size - 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.background,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 12,
                        color: Colors.black26,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add,
                    size: size * 0.6,
                    color: AppColors.lightTheme,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

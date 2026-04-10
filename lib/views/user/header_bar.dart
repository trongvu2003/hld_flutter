import 'package:flutter/material.dart';
import 'package:hld_flutter/theme/app_colors.dart';

String shortenUserName(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    final firstInitial = parts.first[0].toUpperCase();
    final lastName = parts.last;
    return '$firstInitial. $lastName';
  }
  return fullName;
}

String truncateName(String name, int maxLength) {
  return name.length > maxLength ? '${name.substring(0, maxLength)}...' : name;
}

class HeadBar extends StatelessWidget implements PreferredSizeWidget {
  final String? userName;

  const HeadBar({super.key, this.userName});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final shortName = userName != null && userName!.isNotEmpty
        ? shortenUserName(userName!)
        : 'Guest';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.lightTheme,
            Colors.white,
          ],
        ),
      ),
      padding: const EdgeInsets.only(bottom: 12),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            verticalDirection: VerticalDirection.down,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo - tương đương Image với shadow + clip CircleShape
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo_hellodoc.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'HelloDoc',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Xin chào, $shortName',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
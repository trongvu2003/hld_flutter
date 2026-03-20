import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class WelcomeBanner extends StatelessWidget {
  const WelcomeBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            AppColors.lightTheme,
            AppColors.lightBlueCustom,
            Colors.white,
            AppColors.lightBlueCustom,
          ],
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(blurRadius: 12, color: Colors.black26, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Welcome to HelloDoc',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 2
            )
          ),
          const SizedBox(height: 4),
          Text(
            'SỨC KHỎE LÀ VÀNG',
            style:
            Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: 1,
                  width: 30,
                  color: Theme.of(context).colorScheme.primary),
              Text(
                DateTime.now().year.toString(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                  height: 1,
                  width: 30,
                  color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ],
      ),
    );
  }
}

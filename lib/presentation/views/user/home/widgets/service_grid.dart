import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import 'scale_button.dart';
const services = [
  {
    'name': 'Tính BMI',
    "image": "assets/images/speak.png",
    'route': '/bmi-checking',
  },
  {
    'name': 'Fast Talk',
    "image": "assets/images/speak.png",
    'route': '/fast-talk',
  },
  {
    'name': 'Ngôn ngữ kí hiệu',
    "image": "assets/images/speak.png",
    'route': '/sign-language',
  },
  {
    'name': 'Tiếng việt sang video cử chỉ',
    "image": "assets/images/speak.png",
    'route': '/text-to-video',
  },
];
class ServiceGrid extends StatelessWidget {
  final void Function(String route) onTap;

  const ServiceGrid({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rows = <List<Map<String, dynamic>>>[];
    for (var i = 0; i < services.length; i += 2) {
      rows.add(
        services.sublist(
          i,
          (i + 2) > services.length ? services.length : i + 2,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children:
        rows.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                ...row.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == 0 && row.length > 1 ? 8 : 0,
                        left: index == 1 ? 8 : 0,
                      ),
                      child: _ServiceItem(
                        name: item['name'] as String,
                        icon: item['image'] as String,
                        onTap: () => onTap(item['route'] as String),
                      ),
                    ),
                  );
                }),
                if (row.length == 1) const Expanded(child: SizedBox()),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final String name;
  final String icon;
  final VoidCallback onTap;

  const _ServiceItem({
    required this.name,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onTap: onTap,
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          color: AppColors.lightDarkTheme.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withOpacity(0.3),
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.lightTheme.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 4,
                        color: Colors.black12,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(icon, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

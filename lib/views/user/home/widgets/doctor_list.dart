
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import 'scale_button.dart';
import 'section_header.dart';

class DoctorList extends StatefulWidget {
  final List<Map<String, dynamic>> doctors;
  final void Function(Map<String, dynamic>) onTap;

  const DoctorList({required this.doctors, required this.onTap});

  @override
  State<DoctorList> createState() => DoctorListState();
}

class DoctorListState extends State<DoctorList> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final displayed =
    _showAll ? widget.doctors : widget.doctors.take(6).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          SectionHeader(
            title: 'Bác sĩ nổi bật',
            isExpanded: _showAll,
            onSeeAllClick:
            widget.doctors.length > 6
                ? () => setState(() => _showAll = !_showAll)
                : null,
          ),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: displayed.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder:
                  (_, i) => _DoctorItem(
                doctor: displayed[i],
                onTap: () => widget.onTap(displayed[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorItem extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onTap;

  const _DoctorItem({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = doctor['avatarURL'] ?? '';
    final specialty = (doctor['specialty'] as Map?)?['name'] ?? '';

    return ScaleButton(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: AppColors.lightDarkTheme.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 6,
                    color: Colors.black12,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  doctor['avatarURL'] ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              doctor['name'] ?? '',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              specialty,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,color:AppColors.lightTheme.withOpacity(0.8)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultIcon(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Icon(
        Icons.person,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hld_flutter/models/responsemodel/specialty.dart';
import '../../../../theme/app_colors.dart';
import 'scale_button.dart';
import 'section_header.dart';

class SpecialtyList extends StatefulWidget {
  final List<GetSpecialtyResponse> specialties;
  final void Function(Map<String, dynamic>) onTap;

  const SpecialtyList({required this.specialties, required this.onTap});

  @override
  State<SpecialtyList> createState() => _SpecialtyListState();
}

class _SpecialtyListState extends State<SpecialtyList> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final displayed =
        _showAll ? widget.specialties : widget.specialties.take(6).toList();

    return Column(
      children: [
        SectionHeader(
          title: 'Chuyên khoa',
          isExpanded: _showAll,
          onSeeAllClick:
              widget.specialties.length > 6
                  ? () => setState(() => _showAll = !_showAll)
                  : null,
        ),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: displayed.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder:
                (_, i) => SpecialtyItem(
                  specialty: displayed[i],
                  onTap: () => widget.onTap({
                    'id': displayed[i].id,
                    'name': displayed[i].name,
                    'description': displayed[i].description,
                  }),
                ),
          ),
        ),
      ],
    );
  }
}

class SpecialtyItem extends StatelessWidget {
  final GetSpecialtyResponse specialty;
  final VoidCallback onTap;

  const SpecialtyItem({required this.specialty, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconUrl = specialty.icon ?? '';
    print("Icon Chuyen Khoa day" + iconUrl);
    return ScaleButton(
      onTap: onTap,
      child: Container(
        width: 110,
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.lightDarkTheme.withOpacity(0.1),
          borderRadius: BorderRadius.circular(28),
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
              width: 70,
              height: 70,
              child: Center(
                child:
                    iconUrl.isNotEmpty
                        ? Image.network(
                          iconUrl,
                          width: 45,
                          height: 45,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (_, __, ___) =>
                                  Image.asset("assets/images/heart.png"),
                        )
                        : Image.asset("assets/images/heart.png"),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              specialty.name ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

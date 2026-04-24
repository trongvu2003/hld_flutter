import 'package:flutter/material.dart';
import '../../../../../../data/models/responsemodel/doctor.dart';
import '../../../../../../data/models/responsemodel/service_output.dart';


class ViewIntroduce extends StatelessWidget {
  final GetDoctorResponse doctor;
  final void Function(String url) onImageClick;

  const ViewIntroduce({
    super.key,
    required this.doctor,
    required this.onImageClick,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Giới thiệu'),
          const SizedBox(height: 10),
          Text(
            doctor.description?.isNotEmpty == true
                ? doctor.description!
                : 'Chưa cập nhật giới thiệu',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: 'Bằng cấp & chứng chỉ'),
          const SizedBox(height: 10),
          _CertRow(
            icon: Icons.school,
            text:
                doctor.certificates?.isNotEmpty == true
                    ? doctor.certificates!
                    : 'Chưa cập nhật bằng cấp',
          ),
          const SizedBox(height: 8),
          _CertRow(
            icon: Icons.workspace_premium,
            text:
                doctor.certificates?.isNotEmpty == true
                    ? doctor.certificates!
                    : 'Chưa cập nhật bằng cấp',
          ),

          const SizedBox(height: 16),
          _SectionTitle(title: 'Địa chỉ'),
          const SizedBox(height: 10),
          Text(
            doctor.address?.isNotEmpty == true
                ? doctor.address!
                : 'Chưa cập nhật nơi làm việc',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            textAlign: TextAlign.justify,
          ),

          const SizedBox(height: 16),
          _SectionTitle(title: 'Dịch vụ & Giá cả'),
          const SizedBox(height: 10),

          if (doctor.services == null || doctor.services!.isEmpty)
            const Text(
              'Chưa cập nhật dịch vụ',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            )
          else
            ...doctor.services!.map(
              (service) =>
                  _ServiceItem(service: service, onImageClick: onImageClick),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.lightBlue,
      ),
    );
  }
}

class _CertRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CertRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 22, color: Colors.black),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final ServiceOutput service;
  final void Function(String) onImageClick;

  const _ServiceItem({required this.service, required this.onImageClick});

  String _formatPrice(num price) {
    final formatted = price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '${formatted}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.health_and_safety,
                    size: 18,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    service.specialtyName ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Text(
                'Giá: ${_formatPrice(service.minprice)} - ${_formatPrice(service.maxprice)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          // if (service.imageService != null &&
          //     (service.imageService as List).isNotEmpty) ...[
          //   const SizedBox(height: 8),
          //   SizedBox(
          //     height: 120,
          //     child: ListView.separated(
          //       scrollDirection: Axis.horizontal,
          //       itemCount: (service.imageService as List).length,
          //       separatorBuilder: (_, __) => const SizedBox(width: 8),
          //       itemBuilder: (context, i) {
          //         final imageUrl = service.imageService[i] as String;
          //         return GestureDetector(
          //           onTap: () => onImageClick(imageUrl),
          //           child: ClipRRect(
          //             borderRadius: BorderRadius.circular(8),
          //             child: Image.network(
          //               imageUrl,
          //               width: 120,
          //               height: 120,
          //               fit: BoxFit.cover,
          //               errorBuilder:
          //                   (_, __, ___) => Container(
          //                     width: 120,
          //                     height: 120,
          //                     color: Colors.grey.shade200,
          //                     child: const Icon(Icons.broken_image),
          //                   ),
          //             ),
          //           ),
          //         );
          //       },
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../../data/models/responsemodel/user_response.dart';
import '../../../../../theme/app_colors.dart';

class ProfileSection extends StatelessWidget {
  final User user;
  final Function(String) onImageClick;

  const ProfileSection({
    Key? key,
    required this.user,
    required this.onImageClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 290,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 200,
                child: Image.network(
                  user.avatarURL ?? '',
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Image.asset(
                        'assets/images/avatar_doctor.jpg',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/setting');
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightTheme,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.settings, color: Colors.black),
                  ),
                ),
              ),
              Positioned(
                top: 140,
                left: 20,
                child: GestureDetector(
                  onTap: () => onImageClick(user.avatarURL!),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipOval(
                      child: Image.network(
                        user.avatarURL ?? '',
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Image.asset(
                              'assets/images/avatar_doctor.jpg',
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 210,
                left: 150,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: 0.5,
                        color: Colors.black,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/editoptionpage');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightTheme,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Chỉnh sửa",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

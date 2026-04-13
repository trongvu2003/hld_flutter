import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../models/responsemodel/user_response.dart';
import '../../../../../theme/app_colors.dart';

class OtherUserIntroSection extends StatelessWidget {
  final User user;
  final Function(String) onImageClick;
  final VoidCallback onToggleReportBox;

  const OtherUserIntroSection({
    Key? key,
    required this.user,
    required this.onImageClick,
    required this.onToggleReportBox,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
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
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.lightTheme,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.lightTheme,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.report),
                    ),
                  ),
                ),
                Positioned(
                  top: 140,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      if (user.avatarURL != null &&
                          user.avatarURL!.isNotEmpty) {
                        onImageClick(user.avatarURL!);
                      }
                    },
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
                        style: const TextStyle(
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
        ],
      ),
    );
  }
}

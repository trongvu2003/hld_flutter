import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hld_flutter/repositories/auth_repository.dart';
import 'package:hld_flutter/repositories/doctor_repository.dart';
import 'package:hld_flutter/repositories/post_repository.dart';
import 'package:hld_flutter/repositories/review_repository.dart';
import 'package:hld_flutter/repositories/specialty_repository.dart';
import 'package:hld_flutter/repositories/user_repository.dart';
import 'package:hld_flutter/routes/app_pages.dart';
import 'package:hld_flutter/services/auth_service.dart';
import 'package:hld_flutter/services/doctor_service.dart';
import 'package:hld_flutter/services/notification_service.dart';
import 'package:hld_flutter/services/post_service.dart';
import 'package:hld_flutter/services/review_service.dart';
import 'package:hld_flutter/services/specialty_service.dart';
import 'package:hld_flutter/services/user_service.dart';
import 'package:hld_flutter/viewmodels/appointment_viewmodel.dart';
import 'package:hld_flutter/viewmodels/auth_viewmodel.dart';
import 'package:hld_flutter/viewmodels/doctor_viewmodel.dart';
import 'package:hld_flutter/viewmodels/notification_viewmodel.dart';
import 'package:hld_flutter/viewmodels/post_viewmodel.dart';
import 'package:hld_flutter/viewmodels/review_viewmodel.dart';
import 'package:hld_flutter/viewmodels/specialty_viewmodel.dart';
import 'package:hld_flutter/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'repositories/appointment_repository.dart';
import 'repositories/notification_repository.dart';
import 'routes/app_routes.dart';
import 'services/appointment_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(AuthRepository(AuthService())),
        ),
        ChangeNotifierProvider(
          create: (_) => UserViewModel(UserRepository(UserService())),
        ),

        ChangeNotifierProvider(
          create: (_) => PostViewModel(PostRepository(PostService())),
        ),

        ChangeNotifierProvider(
          create:
              (_) =>
                  SpecialtyViewModel(SpecialtyRepository(SpecialtyService())),
        ),

        ChangeNotifierProvider(
          create: (_) => DoctorViewModel(DoctorRepository(DoctorService())),
        ),
        ChangeNotifierProvider(
          create: (_) => ReviewViewModel(ReviewRepository(ReviewService())),
        ),
        ChangeNotifierProvider(
          create:
              (_) => AppointmentViewModel(
                AppointmentRepository(AppointmentService()),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (_) => NotificationViewModel(
                NotificationRepository(NotificationService()),
              ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hellodoc',
      initialRoute: AppRoutes.intro1,
      routes: AppPages.routes,
    );
  }
}

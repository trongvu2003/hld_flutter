import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hld_flutter/routes/app_pages.dart';
import 'package:hld_flutter/viewmodels/appointment_viewmodel.dart';
import 'package:hld_flutter/viewmodels/auth_viewmodel.dart';
import 'package:hld_flutter/viewmodels/doctor_viewmodel.dart';
import 'package:hld_flutter/viewmodels/notification_viewmodel.dart';
import 'package:hld_flutter/viewmodels/post_viewmodel.dart';
import 'package:hld_flutter/viewmodels/review_viewmodel.dart';
import 'package:hld_flutter/viewmodels/specialty_viewmodel.dart';
import 'package:hld_flutter/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/DI/injection_geit.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Khởi tạo SharedPreferences và lấy Token
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('accessToken');
  String startRoute;
  if (token == null || token.isEmpty || token == "unknown") {
    startRoute = AppRoutes.intro1;
  } else {
    startRoute = AppRoutes.main;
  }
  await dotenv.load(fileName: ".env");
  setupLocator();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<UserViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<PostViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<SpecialtyViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<DoctorViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<ReviewViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<AppointmentViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<NotificationViewModel>()),
      ],
      child: MyApp(initialRoute: startRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hellodoc',
      initialRoute: initialRoute,
      routes: AppPages.routes,
    );
  }
}

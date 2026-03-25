import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hld_flutter/repositories/auth_repository.dart';
import 'package:hld_flutter/repositories/user_repository.dart';
import 'package:hld_flutter/routes/app_pages.dart';
import 'package:hld_flutter/services/auth_service.dart';
import 'package:hld_flutter/services/user_service.dart';
import 'package:hld_flutter/viewmodels/auth_viewmodel.dart';
import 'package:hld_flutter/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';

void main()async{
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            AuthRepository(AuthService()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => UserViewModel(
            UserRepository(UserService()),
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
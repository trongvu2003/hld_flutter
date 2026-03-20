import 'package:flutter/material.dart';
import 'package:hld_flutter/views/auth/intro1_screen.dart';
import 'package:hld_flutter/views/auth/start_screen.dart';
import 'package:hld_flutter/views/user/home/home_screen.dart';
import 'package:hld_flutter/views/user/main_screen.dart';
import '../views/auth/signin_screen.dart';
import '../views/auth/signup_screen.dart';
import 'app_routes.dart';
import '../views/auth/intro_screen.dart';

class AppPages {
  static final routes = <String, WidgetBuilder>{
    AppRoutes.intro1: (context) => const IntroScreen(),
    AppRoutes.intro2:(context)=> const Intro2Screen(),
    AppRoutes.startScreen:(context)=>const StartScreen(),
    AppRoutes.signin:(context)=> const SignInScreen(),
    AppRoutes.signup:(context)=>const SignupScreen(),
    AppRoutes.home:(context)=>const HomeScreen(),
    AppRoutes.main:(context)=>const MainScreen(),
  };
}
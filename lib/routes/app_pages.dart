import 'package:flutter/material.dart';
import 'package:hld_flutter/views/auth/intro1_screen.dart';
import 'package:hld_flutter/views/auth/start_screen.dart';
import 'package:hld_flutter/views/user/booking/appointment_detail_screen.dart';
import 'package:hld_flutter/views/user/booking/confirm_booking_screen.dart';
import 'package:hld_flutter/views/user/home/doctor/doctor_profile.dart';
import 'package:hld_flutter/views/user/home/home_screen.dart';
import 'package:hld_flutter/views/user/main_screen.dart';
import 'package:hld_flutter/views/user/post/create_post_screen.dart';
import '../views/auth/signin_screen.dart';
import '../views/auth/signup_screen.dart';
import '../views/user/booking/appointment_list_screen.dart';
import '../views/user/booking/booking_calendar_screen.dart';
import '../views/user/booking/service_selection_screen.dart';
import '../views/user/home/BMIchecking/bmi_checker_screen.dart';
import '../views/user/home/doctor/doctor_list_screen.dart';
import '../views/user/home/doctor/manage_clinic.dart';
import '../views/user/home/doctor/registerclinic.dart';
import '../views/user/home/personal/edit_option_page.dart';
import '../views/user/home/personal/edit_user_profile.dart';
import '../views/user/home/personal/otheruserprofile.dart';
import '../views/user/home/personal/setting_page.dart';
import '../views/user/home/personal/use_owner_profile.dart';
import '../views/user/post/postdetailscreen.dart';
import 'app_routes.dart';
import '../views/auth/intro_screen.dart';

class AppPages {
  static final routes = <String, WidgetBuilder>{
    AppRoutes.intro1: (context) => const IntroScreen(),
    AppRoutes.intro2: (context) => const Intro2Screen(),
    AppRoutes.startScreen: (context) => const StartScreen(),
    AppRoutes.signin: (context) => const SignInScreen(),
    AppRoutes.signup: (context) => const SignupScreen(),
    AppRoutes.home: (context) => const HomeScreen(),
    AppRoutes.main: (context) => const MainScreen(),
    AppRoutes.createpost: (context) {
      final args =
      ModalRoute
          .of(context)!
          .settings
          .arguments as Map<String, dynamic>;
      return CreatePostScreen(
        postId: args?['postId'],
        userId: args['userId'],
        userRole: args['userRole'],
      );
    },
    AppRoutes.doctorlistscreen: (context) {
      final args =
      ModalRoute
          .of(context)!
          .settings
          .arguments as Map<String, dynamic>;
      return DoctorListScreen(
        specialtyId: args['specialtyId'],
        specialtyName: args['specialtyName'],
        specialtyDesc: args['specialtyDesc'],
      );
    },
    AppRoutes.otheruserprofile: (context) {
      final args =
      ModalRoute
          .of(context)!
          .settings
          .arguments as Map<String, dynamic>;
      return DoctorScreen(
        initialTabIndex: args['initialTabIndex'] ?? 0,
        doctorId: args['doctorId'],
        currentUserId: args['currentUserId'],
      );
    },
    AppRoutes.appointmentlistscreen: (context) {
      final args =
      ModalRoute
          .of(context)!
          .settings
          .arguments as Map<String, dynamic>;
      return AppointmentListScreen(
        userRole: args['userRole'],
        userId: args['userId'],
      );
    },

    AppRoutes.appointmentdetailscreen: (context) {
      final args = Map<String, dynamic>.from(
        ModalRoute
            .of(context)!
            .settings
            .arguments as Map,
      );
      return AppointmentDetailScreen(
        isEditing: args['isEditMode'] ?? false,
        appointmentId: args['appointmentId'],
        doctorId: args['doctorId'] ?? '',
        doctorName: args['doctorName'] ?? '',
        doctorAddress: args['doctorAddress'] ?? '',
        doctorAvatar: args['doctorAvatar'] ?? '',
        specialtyName: args['specialtyName'] ?? '',
        hasHomeService: args['hasHomeService'] ?? false,
        // Data cũ để hiển thị (Initial Data)
        initialDate: args['selectedDate'],
        initialTime: args['selectedTime'],
        initialNotes: args['notes'],
        initialMethod: args['method'],
      );
    },
    AppRoutes.bookingcalendar: (context) {
      final args = Map<String, dynamic>.from(
        ModalRoute
            .of(context)
            ?.settings
            .arguments as Map? ?? {},
      );

      return BookingCalendarScreen(
        doctorId: args['doctorId']?.toString() ?? '',
      );
    },

    AppRoutes.confirmbookingscreen: (context) => const ConfirmBookingScreen(),
    AppRoutes.notificationpage: (context) => const ConfirmBookingScreen(),
    AppRoutes.personal: (context) => const ProfileUserPage(),
    AppRoutes.editoptionpage: (context) => const EditOptionPage(),
    AppRoutes.editprofile: (context) => const EditUserProfile(),
    AppRoutes.setting: (context) => const SettingScreen(),

    AppRoutes.profileotheruserpage: (context) {
      final args = Map<String, dynamic>.from(
        ModalRoute
            .of(context)
            ?.settings
            .arguments as Map? ?? {},
      );

      return ProfileOtherUserPage(
        userOwnerID: args['userOwnerID']?.toString() ?? '',
      );
    },

    AppRoutes.postdetail: (context) {
      final args = Map<String, dynamic>.from(
        ModalRoute
            .of(context)
            ?.settings
            .arguments as Map? ?? {},
      );
      return PostDetailScreen(postId: args['postId']?.toString() ?? '');
    },

    AppRoutes.doctorRegister: (context) => const RegisterClinicScreen(),
    AppRoutes.serviceselection: (context) {
      final args = Map<String, dynamic>.from(
        ModalRoute
            .of(context)
            ?.settings
            .arguments as Map? ?? {},
      );

      return ServiceSelectionScreen(
        appointmentId: args['appointmentId']?.toString() ?? '',
        patientName: args['patientName']?.toString() ?? '',
        doctorId: args['doctorId']?.toString() ?? '',
      );
    },
    AppRoutes.editClinic: (context) => const EditClinicServiceScreen(),
    AppRoutes.bmichecking: (context) => const BmiCheckerScreen(),
  };
}

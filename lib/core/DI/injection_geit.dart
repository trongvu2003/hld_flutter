import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hld_flutter/data/repositories/appointment_repository_impl.dart';
import 'package:hld_flutter/domain/repositories/appointment_repository.dart';
import '../../data/datasources/services/appointment_service.dart';
import '../../data/datasources/services/auth_service.dart';
import '../../data/datasources/services/doctor_service.dart';
import '../../data/datasources/services/notification_service.dart';
import '../../data/datasources/services/post_service.dart';
import '../../data/datasources/services/report_service.dart';
import '../../data/datasources/services/review_service.dart';
import '../../data/datasources/services/specialty_service.dart';
import '../../data/datasources/services/user_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/doctor_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../data/repositories/specialty_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/repositories/specialty_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/appointment/cancel_appointment_usecase.dart';
import '../../domain/usecases/appointment/confirm_appointment_usecase.dart';
import '../../domain/usecases/appointment/create_appointment_usecase.dart';
import '../../domain/usecases/appointment/delete_appointment_usecase.dart';
import '../../domain/usecases/appointment/get_appointment_doctor_usecase.dart';
import '../../domain/usecases/appointment/get_appointment_user_usecase.dart';
import '../../domain/usecases/appointment/update_appointment_usecase.dart';
import '../../domain/usecases/auth/extract_role_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/save_token_usecase.dart';
import '../../domain/usecases/doctor/apply_doctor_usecase.dart';
import '../../domain/usecases/doctor/get_available_slots_usecase.dart';
import '../../domain/usecases/doctor/get_doctor_by_id_usecase.dart';
import '../../domain/usecases/doctor/get_doctors_usecase.dart';
import '../../domain/usecases/doctor/update_clinic_usecase.dart';
import '../../domain/usecases/notification/create_notification_usecase.dart';
import '../../domain/usecases/notification/delete_notification_usecase.dart';
import '../../domain/usecases/notification/get_notifications_usecase.dart';
import '../../domain/usecases/notification/get_unread_notifications_usecase.dart';
import '../../domain/usecases/notification/mark_all_as_read_usecase.dart';
import '../../domain/usecases/notification/mark_as_read_usecase.dart';
import '../../domain/usecases/post/comment/create_comment_usecase.dart';
import '../../domain/usecases/post/comment/delete_comment_usecase.dart';
import '../../domain/usecases/post/comment/get_comments_usecase.dart';
import '../../domain/usecases/post/comment/update_comment_usecase.dart';
import '../../domain/usecases/post/create_post_usecase.dart';
import '../../domain/usecases/post/delete_post_usecase.dart';
import '../../domain/usecases/post/get_post_by_id_usecase.dart';
import '../../domain/usecases/post/get_posts_by_user_usecase.dart';
import '../../domain/usecases/post/get_posts_usecase.dart';
import '../../domain/usecases/post/get_similar_posts_usecase.dart';
import '../../domain/usecases/post/update_post_usecase.dart';
import '../../domain/usecases/report/send_report_usecase.dart';
import '../../domain/usecases/review/get_reviews_by_doctor_usecase.dart';
import '../../domain/usecases/specialty/get_specialties_usecase.dart';
import '../../domain/usecases/specialty/get_specialty_by_id_usecase.dart';
import '../../domain/usecases/specialty/get_specialty_by_name_usecase.dart';
import '../../domain/usecases/user/get_current_user_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import '../../domain/usecases/user/send_fcm_token_usecase.dart';
import '../../domain/usecases/user/update_user_usecase.dart';
import '../../presentation/viewmodels/appointment_viewmodel.dart';
import '../../presentation/viewmodels/auth_viewmodel.dart';
import '../../presentation/viewmodels/doctor_viewmodel.dart';
import '../../presentation/viewmodels/notification_viewmodel.dart';
import '../../presentation/viewmodels/post_viewmodel.dart';
import '../../presentation/viewmodels/report_viewmodel.dart';
import '../../presentation/viewmodels/review_viewmodel.dart';
import '../../presentation/viewmodels/specialty_viewmodel.dart';
import '../../presentation/viewmodels/user_viewmodel.dart';
import '../network/dio_client.dart';

final getIt = GetIt.instance;

// Sử dụng registerLazySingleton cho Data Layer: Các Service và Repository chỉ khởi tạo khi cần thiết và dùng chung một instance duy nhất (giúp tiết kiệm bộ nhớ).

// Sử dụng registerFactory cho ViewModels: Đây là điểm mấu chốt. Mỗi khi truy cập một màn hình mới, một ViewModel mới sẽ được tạo ra, tránh việc dữ liệu cũ của màn hình trước còn sót lại (state leakage).

void setupLocator() {
  // 1. TẦNG SERVICES (Tầng giao tiếp API trực tiếp)
  // Register Dio (singleton)
  getIt.registerLazySingleton<Dio>(() => DioClient.create());
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt()));
  getIt.registerLazySingleton<UserService>(() => UserService(getIt()));
  getIt.registerLazySingleton<PostService>(() => PostService(getIt()));
  getIt.registerLazySingleton<SpecialtyService>(
    () => SpecialtyService(getIt()),
  );
  getIt.registerLazySingleton<DoctorService>(() => DoctorService(getIt()));
  getIt.registerLazySingleton<ReviewService>(() => ReviewService(getIt()));
  getIt.registerLazySingleton<AppointmentService>(
    () => AppointmentService(getIt()),
  );
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(getIt()),
  );
  getIt.registerLazySingleton<ReportService>(() => ReportService(getIt()));

  // 2. TẦNG REPOSITORIES (Nhận inject từ Services)
  // getIt() sẽ tự động lấy đúng Service ở trên truyền vào
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<SpecialtyRepository>(
    () => SpecialtyRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<DoctorRepository>(
    () => DoctorRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<ReViewRepository>(
    () => ReViewRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(getIt()),
  );

  // USECASES
  // Auth
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => SaveTokenUseCase());
  getIt.registerLazySingleton(() => ExtractRoleUseCase());
  // User
  getIt.registerLazySingleton(() => GetCurrentUserUseCase());
  getIt.registerLazySingleton(() => GetUserByIdUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateUserUseCase(getIt()));
  getIt.registerLazySingleton(() => SendFcmTokenUseCase(getIt()));
  // Post
  getIt.registerLazySingleton(() => GetPostsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreatePostUseCase(getIt()));
  getIt.registerLazySingleton(() => DeletePostUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdatePostUseCase(getIt()));
  getIt.registerLazySingleton(() => GetPostByIdUseCase(getIt()));
  getIt.registerLazySingleton(() => GetSimilarPostsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetPostsByUserUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCommentsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateCommentUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateCommentUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteCommentUseCase(getIt()));

  // Specialty
  getIt.registerLazySingleton(() => GetSpecialtiesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetSpecialtyByIdUseCase(getIt()));
  getIt.registerLazySingleton(() => GetSpecialtyByNameUseCase(getIt()));

  // Doctor
  getIt.registerLazySingleton(() => GetDoctorsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDoctorByIdUseCase(getIt()));
  getIt.registerLazySingleton(() => GetAvailableSlotsUseCase(getIt()));
  getIt.registerLazySingleton(() => ApplyDoctorUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateClinicUseCase(getIt()));

  // Review
  getIt.registerLazySingleton(() => GetReviewsByDoctorUseCase(getIt()));

  // Appointment
  getIt.registerLazySingleton(() => GetAppointmentUserUseCase(getIt()));
  getIt.registerLazySingleton(() => GetAppointmentDoctorUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateAppointmentUseCase(getIt()));
  getIt.registerLazySingleton(() => CancelAppointmentUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateAppointmentUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteAppointmentUseCase(getIt()));
  getIt.registerLazySingleton(() => ConfirmAppointmentUseCase(getIt()));

  // Notification
  getIt.registerLazySingleton(() => GetNotificationsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetUnreadNotificationsUseCase(getIt()));
  getIt.registerLazySingleton(() => MarkAsReadUseCase(getIt()));
  getIt.registerLazySingleton(() => MarkAllAsReadUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteNotificationUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateNotificationUseCase(getIt()));

  // Report
  getIt.registerLazySingleton(() => SendReportUseCase(getIt()));

  // 3. TẦNG VIEWMODELS (Nhận inject từ Repositories)
  // Vì hiện tại bạn đang bỏ tất cả ViewModel vào main.dart (Global),
  getIt.registerFactory<AuthViewModel>(
    () => AuthViewModel(
      loginUseCase: getIt(),
      saveTokenUseCase: getIt(),
      extractRoleUseCase: getIt(),
    ),
  );

  getIt.registerFactory<UserViewModel>(
    () => UserViewModel(
      getCurrentUserUseCase: getIt(),
      getUserByIdUseCase: getIt(),
      updateUserUseCase: getIt(),
      sendFcmTokenUseCase: getIt(),
    ),
  );
  getIt.registerFactory<PostViewModel>(
    () => PostViewModel(
      getPostsUseCase: getIt(),
      createPostUseCase: getIt(),
      deletePostUseCase: getIt(),
      updatePostUseCase: getIt(),
      getPostByIdUseCase: getIt(),
      getSimilarPostsUseCase: getIt(),
      getPostsByUserUseCase: getIt(),
      getCommentsUseCase: getIt(),
      createCommentUseCase: getIt(),
      updateCommentUseCase: getIt(),
      deleteCommentUseCase: getIt(),
    ),
  );
  getIt.registerFactory<SpecialtyViewModel>(
    () => SpecialtyViewModel(
      getSpecialtiesUseCase: getIt(),
      getSpecialtyByIdUseCase: getIt(),
      getSpecialtyByNameUseCase: getIt(),
    ),
  );
  getIt.registerFactory<DoctorViewModel>(
    () => DoctorViewModel(
      getDoctorsUseCase: getIt(),
      getDoctorByIdUseCase: getIt(),
      getAvailableSlotsUseCase: getIt(),
      applyDoctorUseCase: getIt(),
      updateClinicUseCase: getIt(),
    ),
  );
  getIt.registerFactory<ReviewViewModel>(
    () => ReviewViewModel(getReviewsByDoctorUseCase: getIt()),
  );
  getIt.registerFactory<AppointmentViewModel>(
    () => AppointmentViewModel(
      getAppointmentUserUC: getIt(),
      getAppointmentDoctorUC: getIt(),
      createAppointmentUC: getIt(),
      cancelAppointmentUC: getIt(),
      updateAppointmentUC: getIt(),
      deleteAppointmentUC: getIt(),
      confirmAppointmentUC: getIt(),
    ),
  );
  getIt.registerFactory<NotificationViewModel>(
    () => NotificationViewModel(
      getNotificationsUseCase: getIt(),
      getUnreadNotificationsUseCase: getIt(),
      markAsReadUseCase: getIt(),
      markAllAsReadUseCase: getIt(),
      deleteNotificationUseCase: getIt(),
      createNotificationUseCase: getIt(),
    ),
  );
  getIt.registerFactory<ReportViewModel>(
    () => ReportViewModel(sendReportUseCase: getIt()),
  );
}

/// Áp dụng gelt+ ListenableBuilder
// 1. TÌM (Bằng GetIt)
// final _userVM = getIt<UserViewModel>();
//
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     // 2. NGHE (Bằng ListenableBuilder)
//     body: ListenableBuilder(
//         listenable: _userVM,
//         builder: (context, child) {
//           // Nó sẽ tự rebuild chỗ này khi _userVM thay đổi
//           return Text(_userVM.user?.name ?? '');
//         }
//     ),
//   );
// }

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
  getIt.registerLazySingleton<SpecialtyService>(() => SpecialtyService(getIt()));
  getIt.registerLazySingleton<DoctorService>(() => DoctorService(getIt()));
  getIt.registerLazySingleton<ReviewService>(() => ReviewService(getIt()));
  getIt.registerLazySingleton<AppointmentService>(() => AppointmentService(getIt()));
  getIt.registerLazySingleton<NotificationService>(() => NotificationService(getIt()));
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

  // 3. TẦNG VIEWMODELS (Nhận inject từ Repositories)
  // Vì hiện tại bạn đang bỏ tất cả ViewModel vào main.dart (Global),
  getIt.registerFactory<AuthViewModel>(() => AuthViewModel(getIt()));
  getIt.registerFactory<UserViewModel>(() => UserViewModel(getIt()));
  getIt.registerFactory<PostViewModel>(() => PostViewModel(getIt()));
  getIt.registerFactory<SpecialtyViewModel>(() => SpecialtyViewModel(getIt()));
  getIt.registerFactory<DoctorViewModel>(() => DoctorViewModel(getIt()));
  getIt.registerFactory<ReviewViewModel>(() => ReviewViewModel(getIt()));
  getIt.registerFactory<AppointmentViewModel>(
    () => AppointmentViewModel(getIt()),
  );
  getIt.registerFactory<NotificationViewModel>(
    () => NotificationViewModel(getIt()),
  );
  getIt.registerFactory<ReportViewModel>(() => ReportViewModel(getIt()));
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

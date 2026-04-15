import 'package:get_it/get_it.dart';
import 'package:hld_flutter/repositories/report_repository.dart';
import 'package:hld_flutter/services/report_service.dart';
import 'package:hld_flutter/viewmodels/report_viewmodel.dart';
import '../../repositories/appointment_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/doctor_repository.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/post_repository.dart';
import '../../repositories/review_repository.dart';
import '../../repositories/specialty_repository.dart';
import '../../repositories/user_repository.dart';
import '../../services/appointment_service.dart';
import '../../services/auth_service.dart';
import '../../services/doctor_service.dart';
import '../../services/notification_service.dart';
import '../../services/post_service.dart';
import '../../services/review_service.dart';
import '../../services/specialty_service.dart';
import '../../services/user_service.dart';
import '../../viewmodels/appointment_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/doctor_viewmodel.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../../viewmodels/post_viewmodel.dart';
import '../../viewmodels/review_viewmodel.dart';
import '../../viewmodels/specialty_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';

final getIt = GetIt.instance;

// Sử dụng registerLazySingleton cho Data Layer: Các Service và Repository chỉ khởi tạo khi cần thiết và dùng chung một instance duy nhất (giúp tiết kiệm bộ nhớ).

// Sử dụng registerFactory cho ViewModels: Đây là điểm mấu chốt. Mỗi khi truy cập một màn hình mới, một ViewModel mới sẽ được tạo ra, tránh việc dữ liệu cũ của màn hình trước còn sót lại (state leakage).

void setupLocator() {
  // 1. TẦNG SERVICES (Tầng giao tiếp API trực tiếp)
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<UserService>(() => UserService());
  getIt.registerLazySingleton<PostService>(() => PostService());
  getIt.registerLazySingleton<SpecialtyService>(() => SpecialtyService());
  getIt.registerLazySingleton<DoctorService>(() => DoctorService());
  getIt.registerLazySingleton<ReviewService>(() => ReviewService());
  getIt.registerLazySingleton<AppointmentService>(() => AppointmentService());
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<ReportService>(() => ReportService());

  // 2. TẦNG REPOSITORIES (Nhận inject từ Services)
  // getIt() sẽ tự động lấy đúng Service ở trên truyền vào
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt()));
  getIt.registerLazySingleton<UserRepository>(() => UserRepository(getIt()));
  getIt.registerLazySingleton<PostRepository>(() => PostRepository(getIt()));
  getIt.registerLazySingleton<SpecialtyRepository>(
    () => SpecialtyRepository(getIt()),
  );
  getIt.registerLazySingleton<DoctorRepository>(
    () => DoctorRepository(getIt()),
  );
  getIt.registerLazySingleton<ReviewRepository>(
    () => ReviewRepository(getIt()),
  );
  getIt.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepository(getIt()),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(getIt()),
  );
  getIt.registerLazySingleton<ReportRepository>(
        () => ReportRepository(getIt()),
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
  getIt.registerFactory<ReportViewModel>(
        () => ReportViewModel(getIt()),
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

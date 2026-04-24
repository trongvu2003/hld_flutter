# hld_flutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


lib/
├── core/                   # 1. TẦNG CORE: Dùng chung cho toàn bộ project
│   ├── di/                 # Dependency Injection (Chuyển thư mục DI của bạn ra đây)
│   ├── errors/             # Custom Exceptions, Failures
│   ├── network/            # Cấu hình Dio/Http client
│   └── utils/              # Constants, helpers, formatters
│
├── data/                   # 2. TẦNG DATA: Xử lý nguồn dữ liệu
│   ├── datasources/        # Nguồn dữ liệu (Ví dụ: remote_api_datasource, local_db_datasource)
│   │                       # -> (Bạn có thể chuyển các file trong lib/services vào đây)
│   ├── models/             # DTOs (Data Transfer Objects)
│   │   ├── request/        # -> (Chuyển từ domain/models/requestmodel sang đây)
│   │   └── response/       # -> (Chuyển từ domain/models/responsemodel sang đây)
│   └── repositories/       # Implementations (Triển khai code thực tế) của các Interface ở tầng Domain
│                           # -> (Chuyển thư mục lib/repositories vào đây)
│
├── domain/                 # 3. TẦNG DOMAIN: Chứa logic nghiệp vụ thuần (Không phụ thuộc UI/thư viện bên ngoài)
│   ├── entities/           # Pure Models (Class dữ liệu thuần, không có phương thức fromJson/toJson)
│   ├── repositories/       # Interfaces (Chỉ chứa abstract class định nghĩa các hàm, KHÔNG gọi API ở đây)
│   └── usecases/           # Các hành động cụ thể của user (VD: LoginUseCase, GetPostUseCase)
│
├── presentation/           # 4. TẦNG PRESENTATION: Hiển thị UI và quản lý trạng thái
│   ├── routes/             # Định tuyến navigation (Chuyển từ lib/routes vào đây)
│   ├── theme/              # Cấu hình màu sắc, font chữ
│   ├── viewmodels/         # State Management (Bloc, Cubit, Provider, GetX, v.v.)
│   ├── views/              # Các màn hình chính (Screens/Pages: auth, user, skeleton...)
│   └── widgets/            # Các UI component dùng chung (Button, TextField, Header...)
│
└── main.dart               # Entry point
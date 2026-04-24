import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hld_flutter/presentation/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../data/models/requestmodel/doctor.dart';
import '../../../../viewmodels/doctor_viewmodel.dart';
import '../../../../viewmodels/specialty_viewmodel.dart';
import '../../../../viewmodels/user_viewmodel.dart';

class RegisterClinicScreen extends StatefulWidget {
  const RegisterClinicScreen({super.key});

  @override
  State<RegisterClinicScreen> createState() => _RegisterClinicScreenState();
}

class _RegisterClinicScreenState extends State<RegisterClinicScreen> {
  String userId = "";

  // Form States
  String cccdText = "";
  String licenseNumber = "";
  String clinicAddress = "";
  String? specialtyId;

  // Image States
  File? frontCccdFile;
  File? backCccdFile;
  File? faceFile;
  File? licenseFile;
  File? avatarFile;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<SpecialtyViewModel>().fetchSpecialties();
      final userVM = context.read<UserViewModel>();
      if (userVM.currentUser != null) {
        setState(() {
          userId = userVM.currentUser!.id;
        });
      }
    });
  }

  // Điều kiện để nút Đăng ký sáng lên
  bool get isFormValid {
    return cccdText.isNotEmpty &&
        licenseNumber.isNotEmpty &&
        clinicAddress.isNotEmpty &&
        specialtyId != null &&
        frontCccdFile != null &&
        backCccdFile != null &&
        faceFile != null &&
        licenseFile != null;
  }

  Future<void> _handleApply() async {
    final doctorVM = context.read<DoctorViewModel>();

    // Đóng gói dữ liệu vào Model chuẩn
    final request = ApplyDoctorRequest(
      license: licenseNumber,
      cccd: cccdText,
      specialty: specialtyId ?? "",
      address: clinicAddress,
      licenseUrl: licenseFile,
      faceUrl: faceFile,
      avatarUrl: avatarFile,
      frontCccdUrl: frontCccdFile,
      backCccdUrl: backCccdFile,
    );

    //  Đẩy xuống ViewModel xử lý (Truyền thêm context để hiện SnackBar)
    await doctorVM.applyForDoctor(userId, request, context);

    //  Xử lý điều hướng nếu thành công
    if (doctorVM.applyMessage == "success" && mounted) {
      Navigator.pop(context);
      doctorVM.setApplyMessage(""); // Reset state
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorVM = context.watch<DoctorViewModel>();
    final specialtyVM = context.watch<SpecialtyViewModel>();
    final specialties = specialtyVM.specialties;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _HeadbarResClinic(onBack: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chức năng này sẽ cho phép bạn mở và quảng bá phòng khám, dịch vụ của bạn đến các người dùng khác của hệ thống. \n"
              "Hãy điền các thông tin dưới đây, hãy đảm bảo hình ảnh bạn gửi rõ ràng và không qua chỉnh sửa",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),

            _InputEditField(
              label: "Mã số căn cước công dân",
              hint: "05xxxxxxxxx",
              keyboardType: TextInputType.number,
              onChanged: (val) => setState(() => cccdText = val),
            ),
            const SizedBox(height: 16),

            const Text(
              "Ảnh chụp căn cước công dân",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ImageInputField(
                  description: "Ảnh CCCD mặt trước",
                  imageFile: frontCccdFile,
                  onImageSelected:
                      (file) => setState(() => frontCccdFile = file),
                ),
                _ImageInputField(
                  description: "Ảnh CCCD mặt sau",
                  imageFile: backCccdFile,
                  onImageSelected:
                      (file) => setState(() => backCccdFile = file),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              "Ảnh chụp mặt bạn",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Center(
              child: _ImageInputField(
                description: "Ảnh mặt bạn",
                imageFile: faceFile,
                onImageSelected: (file) => setState(() => faceFile = file),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Chuyên khoa",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              hint: const Text("Chọn chuyên khoa"),
              value: specialtyId,
              items:
                  specialties.map((specialty) {
                    return DropdownMenuItem<String>(
                      value: specialty.id,
                      child: Text(specialty.name),
                    );
                  }).toList(),
              onChanged: (val) {
                setState(() => specialtyId = val);
              },
            ),
            const SizedBox(height: 16),

            _InputEditField(
              label: "Mã giấy phép hành nghề do bộ y tế cấp",
              hint: "Nhập mã giấy phép hành nghề",
              onChanged: (val) => setState(() => licenseNumber = val),
            ),
            const SizedBox(height: 16),

            _InputEditField(
              label: "Địa chỉ phòng khám",
              hint: "Nhập địa chỉ phòng khám",
              onChanged: (val) => setState(() => clinicAddress = val),
            ),
            const SizedBox(height: 16),

            const Text(
              "Ảnh giấy phép hành nghề",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Center(
              child: _ImageInputField(
                description: "Ảnh giấy phép hành nghề",
                imageFile: licenseFile,
                onImageSelected: (file) => setState(() => licenseFile = file),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Tôi cam kết những thông tin tôi đăng là đúng và sẵn sàng chịu trách nhiệm trước pháp luật\n\n"
              "Việc bạn thực hiện đăng kí phòng khám trên ứng dụng đồng nghĩa với việc bạn phải tuân thủ theo chính sách về bác sĩ sử dụng dịch vụ trên hệ thống, chi tiết xem tại đây.\n",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            if (doctorVM.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isFormValid ? _handleApply : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightTheme,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Yêu cầu xét duyệt hồ sơ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _HeadbarResClinic extends StatelessWidget {
  final VoidCallback onBack;

  const _HeadbarResClinic({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.lightTheme,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: onBack,
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 24,
                  ),
                ),
              ),
              const Text(
                "Đăng kí phòng khám",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputEditField extends StatelessWidget {
  final String label;
  final String hint;
  final Function(String) onChanged;
  final TextInputType keyboardType;

  const _InputEditField({
    required this.label,
    required this.hint,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageInputField extends StatelessWidget {
  final String description;
  final File? imageFile;
  final Function(File) onImageSelected;

  const _ImageInputField({
    required this.description,
    required this.imageFile,
    required this.onImageSelected,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      onImageSelected(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.lightTheme,
                  width: 2,
                ),
                image:
                    imageFile != null
                        ? DecorationImage(
                          image: FileImage(imageFile!),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  imageFile == null
                      ? Icon(
                        Icons.camera_alt_rounded,
                        size: 36,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )
                      : null,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 120,
            child: Text(
              description,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

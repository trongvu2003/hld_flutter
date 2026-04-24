import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../data/models/requestmodel/doctor.dart';
import '../../../../../data/models/responsemodel/doctor.dart';
import '../../../../../data/models/responsemodel/service_output.dart';
import '../../../../../data/models/responsemodel/specialty.dart';
import '../../../../theme/app_colors.dart';
import '../../../../viewmodels/doctor_viewmodel.dart';
import '../../../../viewmodels/specialty_viewmodel.dart';
import '../../../../viewmodels/user_viewmodel.dart';

class EditClinicServiceScreen extends StatefulWidget {
  const EditClinicServiceScreen({super.key});

  @override
  State<EditClinicServiceScreen> createState() =>
      _EditClinicServiceScreenState();
}

class _EditClinicServiceScreenState extends State<EditClinicServiceScreen> {
  bool _isInitialized = false;

  // Local States
  List<WorkHour> _oldSchedule = [];
  List<WorkHour> _newSchedule = [];
  List<ServiceInput> _servicesInput = [];
  List<ServiceOutput> _servicesCreated = [];

  String _clinicSpecialtyId = "";
  String _clinicSpecialtyName = "";

  String _selectedSpecialtyId = "";
  String _selectedSpecialtyName = "";
  List<XFile> _imageService = [];

  bool _hasHomeService = false;
  bool _isClinicPaused = false;

  // Controllers
  final TextEditingController _minPriceCtrl = TextEditingController();
  final TextEditingController _maxPriceCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();

  final TextEditingController _dayCtrl = TextEditingController();
  final TextEditingController _hourCtrl = TextEditingController();
  final TextEditingController _minuteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpecialtyViewModel>().fetchSpecialties();
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final userVm = context.read<UserViewModel>();
    final doctorVm = context.read<DoctorViewModel>();

    final user = userVm.currentUser;
    if (user != null) {
      await doctorVm.getDoctorById(user.id);

      final doctor = doctorVm.selectedDoctor;
      if (doctor != null && mounted) {
        setState(() {
          _servicesCreated = List.from(doctor.services);
          _oldSchedule = List.from(doctor.workingHours);
          _addressCtrl.text = doctor.address ?? "";
          _hasHomeService = doctor.hasHomeService ?? false;
          _isClinicPaused = doctor.isClinicPaused ?? false;

          _clinicSpecialtyId = doctor.specialty.id;
          _clinicSpecialtyName = doctor.specialty.name;

          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _dayCtrl.dispose();
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _imageService.addAll(images);
      });
    }
  }

  void _addService() {
    if (_selectedSpecialtyId.isNotEmpty &&
        _selectedSpecialtyName.isNotEmpty &&
        _minPriceCtrl.text.isNotEmpty &&
        _maxPriceCtrl.text.isNotEmpty) {
      setState(() {
        _servicesInput.add(
          ServiceInput(
            specialtyId: _selectedSpecialtyId,
            specialtyName: _selectedSpecialtyName,
            imageService: _imageService.map((e) => e.path).toList(),
            // Lưu path ảnh
            minprice: _minPriceCtrl.text,
            maxprice: _maxPriceCtrl.text,
            description: _descCtrl.text,
          ),
        );

        // Reset form
        _selectedSpecialtyId = "";
        _selectedSpecialtyName = "";
        _imageService.clear();
        _minPriceCtrl.clear();
        _maxPriceCtrl.clear();
        _descCtrl.clear();
      });
    }
  }

  void _removeServiceCreated(ServiceOutput service) {
    setState(() {
      _servicesCreated.removeWhere(
        (item) =>
            item.specialtyId == service.specialtyId &&
            item.specialtyName == service.specialtyName &&
            item.description == service.description,
      );
    });
  }

  void _removeTime(WorkHour time) {
    setState(() {
      // Xoá ở lịch cũ (nếu có)
      _oldSchedule.removeWhere(
        (item) =>
            item.dayOfWeek == time.dayOfWeek &&
            item.hour == time.hour &&
            item.minute == time.minute,
      );

      // Xoá ở lịch mới (nếu có)
      _newSchedule.removeWhere(
        (item) =>
            item.dayOfWeek == time.dayOfWeek &&
            item.hour == time.hour &&
            item.minute == time.minute,
      );
    });
  }

  void _addTime() {
    int? d = int.tryParse(_dayCtrl.text);
    int? h = int.tryParse(_hourCtrl.text);
    int? m = int.tryParse(_minuteCtrl.text);

    if (d != null &&
        d >= 2 &&
        d <= 8 &&
        h != null &&
        h >= 0 &&
        h <= 23 &&
        m != null &&
        m >= 0 &&
        m <= 59) {
      final newTime = WorkHour(dayOfWeek: d, hour: h, minute: m);

      // Kiểm tra trùng lặp
      bool exists = _newSchedule.any(
        (t) => t.dayOfWeek == d && t.hour == h && t.minute == m,
      );
      if (!exists) {
        setState(() {
          _newSchedule.add(newTime);
          _dayCtrl.clear();
          _hourCtrl.clear();
          _minuteCtrl.clear();
        });
      }
    }
  }

  void _saveClinicData() {
    final doctorId = context.read<UserViewModel>().currentUser?.id ?? '';
    final request = ModifyClinicRequest(
      address: _addressCtrl.text,
      description: _descCtrl.text,
      workingHours: _newSchedule,
      oldWorkingHours: _oldSchedule,
      services: _servicesInput,
      oldServices: _servicesCreated,
      images: _imageService.map((e) => e.path).toList(),
      hasHomeService: _hasHomeService,
      isClinicPaused: _isClinicPaused,
      specialtyId: _clinicSpecialtyId,
    );

    context.read<DoctorViewModel>().updateClinic(request, doctorId, context);
  }

  @override
  Widget build(BuildContext context) {
    final specialtyVm = context.watch<SpecialtyViewModel>();
    final allSpecialties = specialtyVm.specialties;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.lightTheme,
        title: const Text(
          "Chỉnh sửa phòng khám",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:
          !_isInitialized
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Chức năng này sẽ cho phép bạn chỉnh sửa thông tin phòng khám, dịch vụ của bạn",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Chuyên khoa phòng khám",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildAutoComplete(allSpecialties, _clinicSpecialtyName, (
                      id,
                      name,
                    ) {
                      setState(() {
                        _clinicSpecialtyId = id;
                        _clinicSpecialtyName = name;
                      });
                    }),
                    const Divider(height: 32),

                    const Text(
                      "Thêm dịch vụ mới",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildAutoComplete(allSpecialties, _selectedSpecialtyName, (
                      id,
                      name,
                    ) {
                      setState(() {
                        _selectedSpecialtyId = id;
                        _selectedSpecialtyName = name;
                      });
                    }),
                    const SizedBox(height: 16),

                    // Image Picker
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightTheme,
                      ),
                      onPressed: _pickImages,
                      icon: const Icon(Icons.camera_alt, color: Colors.black),
                      label: const Text(
                        "Chọn ảnh",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    if (_imageService.isNotEmpty)
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _imageService.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.file(
                                File(_imageService[index].path),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Prices
                    const Text(
                      "Phí dịch vụ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minPriceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Từ",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _maxPriceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Đến",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Text(
                      "Thông tin giới thiệu",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Add Service Button
                    InkWell(
                      onTap: _addService,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        color: Colors.grey[300],
                        child: const Column(
                          children: [
                            Text(
                              "Thêm dịch vụ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Icon(Icons.add),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Service Tags
                    const Text(
                      "Các dịch vụ đã thêm",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Wrap(
                      spacing: 8.0,
                      children:
                          _servicesCreated
                              .map(
                                (service) => Chip(
                                  label: Text(service.specialtyName),
                                  onDeleted:
                                      () => _removeServiceCreated(service),
                                  deleteIcon: const Icon(
                                    Icons.delete_forever,
                                    size: 18,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    const Divider(height: 32, thickness: 2),
                    TextField(
                      controller: _addressCtrl,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        labelText: "Địa chỉ phòng khám",
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    CheckboxListTile(
                      title: const Text("Có dịch vụ khám tại nhà"),
                      value: _hasHomeService,
                      onChanged:
                          (val) =>
                              setState(() => _hasHomeService = val ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.lightTheme,
                      checkColor: Colors.black,
                    ),
                    const Divider(height: 32, thickness: 2),

                    const Text(
                      "Lịch hiện tại",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildScheduleGrid(),
                    const SizedBox(height: 16),

                    // Time Picker
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _dayCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Thứ (2-8)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _hourCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Giờ",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _minuteCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Phút",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _addTime,
                          icon: const Icon(
                            Icons.add_circle,
                            size: 32,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: const Text("Tạm ngưng phòng khám"),
                      value: _isClinicPaused,
                      onChanged: (val) => setState(() => _isClinicPaused = val),
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.red,
                      activeTrackColor: Colors.red.shade200,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                    const Divider(height: 32, thickness: 2),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightTheme,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _saveClinicData,
                        child: const Text(
                          "Lưu thông tin phòng khám",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
    );
  }

  Widget _buildAutoComplete(
    List<GetSpecialtyResponse> allSpecialties,
    String initialValue,
    Function(String, String) onSelected,
  ) {
    return Autocomplete<GetSpecialtyResponse>(
      initialValue: TextEditingValue(text: initialValue),
      displayStringForOption: (option) => option.name,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<GetSpecialtyResponse>.empty();
        }
        return allSpecialties.where(
          (item) => item.name.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          ),
        );
      },
      onSelected: (GetSpecialtyResponse selection) {
        onSelected(selection.id, selection.name);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            hintText: "Nhập tên dịch vụ",
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }

  Widget _buildScheduleGrid() {
    final weekdays = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];

    Map<int, List<WorkHour>> scheduleByDay = {};
    final allSchedules = [..._oldSchedule, ..._newSchedule];

    for (var time in allSchedules) {
      if (!scheduleByDay.containsKey(time.dayOfWeek)) {
        scheduleByDay[time.dayOfWeek] = [];
      }
      scheduleByDay[time.dayOfWeek]!.add(time);
    }

    int maxRows = 0;
    scheduleByDay.forEach((key, value) {
      value.sort(
        (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
      );

      if (value.length > maxRows) maxRows = value.length;
    });

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Table(
          border: TableBorder.all(color: Colors.transparent),
          children: [
            TableRow(
              children:
                  weekdays
                      .map(
                        (day) => Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            for (int i = 0; i < maxRows; i++)
              TableRow(
                children: List.generate(7, (dayIndex) {
                  int actualDay = dayIndex + 2; // Thứ 2 đến Chủ nhật (2-8)
                  List<WorkHour> times = scheduleByDay[actualDay] ?? [];
                  if (i < times.length) {
                    WorkHour time = times[i];
                    String timeStr =
                        "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
                    return InkWell(
                      onTap: () => _removeTime(time),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                              color:
                                  _newSchedule.contains(time)
                                      ? Colors.blue
                                      : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                }),
              ),
          ],
        ),
      ),
    );
  }
}

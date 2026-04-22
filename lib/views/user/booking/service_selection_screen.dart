import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../theme/app_colors.dart';
import '../../../viewmodels/doctor_viewmodel.dart';
import '../../../viewmodels/user_viewmodel.dart';

class ServiceItemModel {
  final String id;
  final String name;
  final int price;
  final String? description;

  ServiceItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
  });
}

class ServiceSelectionScreen extends StatefulWidget {
  final String appointmentId;
  final String patientName;
  final String doctorId;

  const ServiceSelectionScreen({
    super.key,
    required this.appointmentId,
    required this.patientName,
    required this.doctorId,
  });

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  Set<String> _selectedServices = {};
  bool _showPayment = false;
  bool _useCustomPrice = false;

  final TextEditingController _customPriceController = TextEditingController();
  final TextEditingController _customNoteController = TextEditingController();

  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  // Danh sách dịch vụ chung (Fallback nếu bác sĩ chưa cấu hình)
  final List<ServiceItemModel> _commonServices = [
    ServiceItemModel(
      id: "common_1",
      name: "Khám tổng quát",
      price: 200000,
      description: "Khám sức khỏe tổng quát",
    ),
    ServiceItemModel(
      id: "common_2",
      name: "Tái khám",
      price: 150000,
      description: "Tái khám theo dõi",
    ),
    ServiceItemModel(
      id: "common_3",
      name: "Tư vấn sức khỏe",
      price: 100000,
      description: "Tư vấn và giải đáp thắc mắc",
    ),
    ServiceItemModel(
      id: "common_4",
      name: "Xét nghiệm cơ bản",
      price: 150000,
      description: "Xét nghiệm máu, nước tiểu",
    ),
    ServiceItemModel(
      id: "common_5",
      name: "Đo huyết áp",
      price: 50000,
      description: "Kiểm tra huyết áp",
    ),
    ServiceItemModel(
      id: "common_6",
      name: "Tư vấn dinh dưỡng",
      price: 180000,
      description: "Tư vấn chế độ ăn uống",
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorViewModel>().getDoctorById(widget.doctorId);
    });
  }

  @override
  void dispose() {
    _customPriceController.dispose();
    _customNoteController.dispose();
    super.dispose();
  }

  int _parsePrice(String? priceStr) {
    if (priceStr == null || priceStr.isEmpty) return 0;
    final cleanStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanStr) ?? 0;
  }

  List<ServiceItemModel> _getAvailableServices(DoctorViewModel docVm) {
    final doctor = docVm.selectedDoctor;

    if (doctor != null && doctor.services.isNotEmpty) {
      return doctor.services.map((service) {
        int min = _parsePrice(service.minprice?.toString());
        int max = _parsePrice(service.maxprice?.toString());
        int avgPrice = max > 0 ? ((min + max) ~/ 2) : min;

        return ServiceItemModel(
          id: service.specialtyId?.toString() ?? '',
          name: service.specialtyName?.toString() ?? '',
          price: avgPrice,
          description: service.description?.toString(),
        );
      }).toList();
    }
    return _commonServices;
  }

  int _calculateTotalAmount(List<ServiceItemModel> availableServices) {
    if (_useCustomPrice) {
      return _parsePrice(_customPriceController.text);
    } else {
      return availableServices
          .where((s) => _selectedServices.contains(s.id))
          .fold(0, (sum, item) => sum + item.price);
    }
  }

  @override
  Widget build(BuildContext context) {
    final docVm = context.watch<DoctorViewModel>();
    final isLoading = docVm.isLoading;
    final availableServices = _getAvailableServices(docVm);
    final hasDoctorServices =
        (docVm.selectedDoctor?.services.isNotEmpty ?? false);
    final totalAmount = _calculateTotalAmount(availableServices);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _showPayment ? "Thanh toán" : "Chọn dịch vụ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.lightTheme,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_showPayment) {
              setState(() => _showPayment = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body:
          isLoading
              ? _buildLoading()
              : (_showPayment
                  ? _buildPaymentScreen(totalAmount, availableServices)
                  : _buildSelectionContent(
                    availableServices,
                    hasDoctorServices,
                  )),
      bottomNavigationBar:
          (!isLoading && !_showPayment) ? _buildBottomBar(totalAmount) : null,
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Đang tải dịch vụ...", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSelectionContent(
    List<ServiceItemModel> services,
    bool hasDoctorServices,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hasDoctorServices) ...[
            _buildWarningBanner(),
            const SizedBox(height: 16),
          ],
          _buildToggleChips(),
          const SizedBox(height: 16),
          if (_useCustomPrice)
            _buildCustomPriceForm()
          else
            _buildServicesList(services),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Text("ℹ️", style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bạn chưa thiết lập dịch vụ riêng",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF856404),
                  ),
                ),
                Text(
                  "Đang hiển thị dịch vụ chung của phòng khám",
                  style: TextStyle(fontSize: 12, color: Color(0xFF856404)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChips() {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Text("Chọn từ danh sách"),
            selected: !_useCustomPrice,
            onSelected: (val) {
              if (val) setState(() => _useCustomPrice = false);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChoiceChip(
            label: const Text("Nhập giá tự do"),
            selected: _useCustomPrice,
            onSelected: (val) {
              if (val) {
                setState(() {
                  _useCustomPrice = true;
                  _selectedServices.clear();
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomPriceForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nhập thông tin dịch vụ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customNoteController,
              decoration: const InputDecoration(
                labelText: "Tên dịch vụ",
                hintText: "VD: Khám tổng quát...",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customPriceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: "Số tiền",
                hintText: "VD: 200000",
                suffixText: "₫",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList(List<ServiceItemModel> services) {
    if (services.isEmpty) {
      return const Center(child: Text("Chưa có dịch vụ nào"));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final service = services[index];
        final isSelected = _selectedServices.contains(service.id);

        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedServices.remove(service.id);
              } else {
                _selectedServices.add(service.id);
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.lightTheme.withOpacity(0.15)
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (service.description != null &&
                          service.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          service.description!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(service.price),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightTheme,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color:
                      isSelected ? AppColors.lightTheme : Colors.grey.shade300,
                  size: 28,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(int totalAmount) {
    bool isValid = false;
    if (_useCustomPrice) {
      isValid =
          _customNoteController.text.isNotEmpty &&
          _parsePrice(_customPriceController.text) > 0;
    } else {
      isValid = _selectedServices.isNotEmpty;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tổng cộng",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  currencyFormatter.format(totalAmount),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTheme,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed:
                  isValid ? () => setState(() => _showPayment = true) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightTheme,
                disabledBackgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Tiếp tục",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentScreen(
    int totalAmount,
    List<ServiceItemModel> availableServices,
  ) {
    List<ServiceItemModel> finalServices = [];
    if (_useCustomPrice) {
      finalServices.add(
        ServiceItemModel(
          id: "custom",
          name:
              _customNoteController.text.isEmpty
                  ? "Dịch vụ khám bệnh"
                  : _customNoteController.text,
          price: _parsePrice(_customPriceController.text),
        ),
      );
    } else {
      finalServices =
          availableServices
              .where((s) => _selectedServices.contains(s.id))
              .toList();
    }

    final qrData =
        "Thanh toán khám bệnh: ${currencyFormatter.format(totalAmount)}";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bệnh nhân: ${widget.patientName}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Chi tiết dịch vụ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...finalServices.map(
                    (s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              s.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            currencyFormatter.format(s.price),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tổng cộng",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currencyFormatter.format(totalAmount),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightTheme,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    "Quét mã QR để thanh toán",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Vui lòng quét mã để hoàn tất thanh toán",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final userId =
                    context.read<UserViewModel>().currentUser!.id ?? '';
                // context.read<AppointmentViewModel>().confirmAppointmentDone(
                //   appointmentId: widget.appointmentId,
                //   userId: userId,
                // );

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightTheme,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Hoàn thành",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

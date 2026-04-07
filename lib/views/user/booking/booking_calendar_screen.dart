import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../viewmodels/doctor_viewmodel.dart';

class BookingCalendarScreen extends StatefulWidget {
  final String doctorId;

  const BookingCalendarScreen({super.key, required this.doctorId});

  @override
  State<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  DateTime _currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime _selectedDate = _normalizeDate(DateTime.now());
  String _selectedTime = "";

  final List<String> daysOfWeek = [
    "TH2",
    "TH3",
    "TH4",
    "TH5",
    "TH6",
    "TH7",
    "CN",
  ];

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.doctorId.isNotEmpty) {
        context.read<DoctorViewModel>().fetchAvailableSlots(widget.doctorId);
      }
    });
  }

  String _formatDateToDDMMYYYY(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DoctorViewModel>();
    final bool isLoading = vm.isLoading;
    final availableSlotsList = vm.doctorSlots?.availableSlots ?? [];

    // Lọc ra tập hợp các ngày có lịch trống từ data thật
    final Set<DateTime> availableDates = {};
    for (var slot in availableSlotsList) {
      try {
        final parsedDate = DateTime.parse(slot.date);
        availableDates.add(_normalizeDate(parsedDate));
      } catch (_) {}
    }

    // Lấy danh sách giờ của ngày đang chọn
    List<String> availableTimes = [];
    if (availableDates.contains(_selectedDate)) {
      final selectedSlotInfo = availableSlotsList.firstWhere((slot) {
        try {
          return _normalizeDate(DateTime.parse(slot.date)) == _selectedDate;
        } catch (_) {
          return false;
        }
      });
      if (selectedSlotInfo != null && selectedSlotInfo.slots != null) {
        availableTimes =
            selectedSlotInfo.slots!
                .map((s) => s.displayTime.toString())
                .toList();
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _TopBar(
          title: "Chọn lịch hẹn khám",
          onBack: () => Navigator.pop(context),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    "Chọn ngày",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // LỊCH
                  _buildCalendarCard(availableDates),
                  const SizedBox(height: 24),

                  const Text(
                    "Chọn giờ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),

                  // DANH SÁCH GIỜ
                  _buildTimeSlots(availableTimes, availableDates),
                  const SizedBox(height: 32),

                  // NÚT XÁC NHẬN
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (_selectedTime.isNotEmpty &&
                                  availableDates.contains(_selectedDate))
                              ? () {
                                Navigator.pop(context, {
                                  'date': _formatDateToDDMMYYYY(_selectedDate),
                                  'time': _selectedTime,
                                });
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightTheme,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor:
                            Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Xác nhận",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
    );
  }

  Widget _buildCalendarCard(Set<DateTime> availableDates) {
    final colors = Theme.of(context).colorScheme;
    final int daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final int firstWeekday =
        DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed:
                    () => setState(
                      () =>
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month - 1,
                            1,
                          ),
                    ),
              ),
              Text(
                "Tháng ${_currentMonth.month} / ${_currentMonth.year}",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: colors.onBackground,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed:
                    () => setState(
                      () =>
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month + 1,
                            1,
                          ),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                daysOfWeek
                    .map(
                      (day) => Expanded(
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colors.onBackground,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + (firstWeekday - 1),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) return const SizedBox();

              final dayNumber = index - (firstWeekday - 1) + 1;
              final currentDate = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                dayNumber,
              );

              final isPast = currentDate.isBefore(
                _normalizeDate(DateTime.now()),
              );
              final isSelected = currentDate == _selectedDate;
              final isAvailable = availableDates.contains(currentDate);
              final isClickable = !isPast && isAvailable;

              Color bgColor = Colors.transparent;
              if (isSelected) {
                bgColor = AppColors.lightTheme.withOpacity(0.2);
              } else if (isAvailable && !isPast) {
                bgColor = AppColors.mainTheme;
              } else if (!isAvailable && !isPast) {
                bgColor = Colors.white;
              }

              return GestureDetector(
                onTap:
                    isClickable
                        ? () {
                          setState(() {
                            _selectedDate = currentDate;
                            _selectedTime = "";
                          });
                        }
                        : null,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bgColor,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    dayNumber.toString(),
                    style: TextStyle(
                      color: isPast ? Colors.grey : colors.onBackground,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots(
    List<String> availableTimes,
    Set<DateTime> availableDates,
  ) {
    if (availableTimes.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          availableDates.contains(_selectedDate)
              ? "Không có giờ phù hợp cho ngày này"
              : "Vui lòng chọn ngày có lịch khám",
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: availableTimes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final time = availableTimes[index];
        final isSelected = _selectedTime == time;
        final colors = Theme.of(context).colorScheme;

        return InkWell(
          onTap: () => setState(() => _selectedTime = time),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.lightTheme : Colors.white,
              border: Border.all(color: AppColors.lightTheme),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }
}

// TOP BAR
class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightTheme,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 24),
                  onPressed: onBack,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

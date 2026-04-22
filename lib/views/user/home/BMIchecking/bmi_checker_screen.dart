import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/app_colors.dart';

class BmiCheckerScreen extends StatefulWidget {
  const BmiCheckerScreen({super.key});

  @override
  State<BmiCheckerScreen> createState() => _BmiCheckerScreenState();
}

class _BmiCheckerScreenState extends State<BmiCheckerScreen> {
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  double? _bmi;

  BMIInfo? get _bmiInfo => _bmi != null ? getBMIInfo(_bmi!) : null;

  void _calculateBmi() {
    FocusScope.of(context).unfocus(); // Ẩn bàn phím
    final w = double.tryParse(_weightCtrl.text);
    final h = double.tryParse(_heightCtrl.text);

    if (w != null && h != null && h > 0) {
      final hMet = h / 100;
      setState(() {
        _bmi = w / (hMet * hMet);
      });
    }
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightTheme.withOpacity(0.05),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Header Label
                      Text(
                        "Chỉ số khối cơ thể (BMI)",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Theo dõi cân nặng để có sức khỏe tốt hơn",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Input Section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.1),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            BmiRowInput(
                              controller: _weightCtrl,
                              label: "Cân nặng",
                              suffix: "kg",
                              icon: Icons.monitor_weight,
                            ),
                            const SizedBox(height: 20),
                            BmiRowInput(
                              controller: _heightCtrl,
                              label: "Chiều cao",
                              suffix: "cm",
                              icon: Icons.height,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton.icon(
                                onPressed: _calculateBmi,
                                icon: const Icon(
                                  Icons.calculate_sharp,
                                  color: Colors.black,
                                ),
                                label: const Text(
                                  "Tính toán ngay",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.black,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lightTheme,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Results Section (AnimatedVisibility)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        child:
                            _bmi != null && _bmiInfo != null
                                ? ResultCard(bmi: _bmi!, info: _bmiInfo!)
                                : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.lightTheme,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color:Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: Text(
              "Kiểm tra sức khỏe",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BmiRowInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData icon;

  const BmiRowInput({
    super.key,
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            hintText: "0",
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightTheme.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.lightTheme, size: 20),
              ),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightTheme.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      suffix,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.lightTheme,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color:AppColors.lightTheme.withOpacity(0.8), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class ResultCard extends StatelessWidget {
  final double bmi;
  final BMIInfo info;

  const ResultCard({super.key, required this.bmi, required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Phân tích kết quả",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),

          // Dynamic Gauge
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: info.progress),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.fastOutSlowIn,
                  builder: (context, progress, child) {
                    return CustomPaint(
                      size: const Size(200, 200),
                      painter: BmiGaugePainter(progress: progress),
                    );
                  },
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      bmi.toStringAsFixed(1),
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: info.color,
                      ),
                    ),
                    Text(
                      "BMI",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: info.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: info.color, width: 2),
            ),
            child: Text(
              info.category,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: info.color,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Health Advice Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: info.color, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    info.advice,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // BMI Scale Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              LegendItem(label: "Gầy", color: Color(0xFF3498DB)),
              LegendItem(label: "BT", color: Color(0xFF2ECC71)),
              LegendItem(label: "Thừa", color: Color(0xFFF1C40F)),
              LegendItem(label: "Béo", color: Color(0xFFE74C3C)),
            ],
          ),
        ],
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const LegendItem({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class BmiGaugePainter extends CustomPainter {
  final double progress;

  BmiGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10;

    const startAngle = 135 * pi / 180;
    const sweepAngle = 270 * pi / 180;

    // Vẽ Background Track
    final bgPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 20.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Vẽ Progress Track
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [
        Color(0xFF3498DB),
        Color(0xFF2ECC71),
        Color(0xFFF1C40F),
        Color(0xFFE74C3C),
        Color(0xFFE74C3C),
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      transform: GradientRotation(
        -pi / 2 + (45 * pi / 180),
      ), // Điều chỉnh xoay gradient khớp với arc
    );

    final progressPaint =
        Paint()
          ..shader = gradient.createShader(
            Rect.fromCircle(center: center, radius: radius),
          )
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 20.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant BmiGaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Logic Models
class BMIInfo {
  final String category;
  final String advice;
  final Color color;
  final double progress;

  BMIInfo(this.category, this.advice, this.color, this.progress);
}

BMIInfo getBMIInfo(double bmi) {
  if (bmi < 18.5) {
    return BMIInfo(
      "Thiếu cân",
      "Cơ thể bạn đang ở mức thiếu cân. Hãy bổ sung thêm dinh dưỡng.",
      const Color(0xFF3498DB),
      (bmi / 40).clamp(0.0, 1.0),
    );
  } else if (bmi < 24.9) {
    return BMIInfo(
      "Bình thường",
      "Bạn có một thân hình lý tưởng. Hãy tiếp tục duy trì nhé!",
      const Color(0xFF2ECC71),
      (bmi / 40).clamp(0.0, 1.0),
    );
  } else if (bmi < 29.9) {
    return BMIInfo(
      "Thừa cân",
      "Ái chà! Hơi thừa cân một chút rồi. Hãy chăm chỉ vận động nhé.",
      const Color(0xFFF1C40F),
      (bmi / 40).clamp(0.0, 1.0),
    );
  } else {
    return BMIInfo(
      "Béo phì",
      "Cảnh báo béo phì! Bạn nên điều chỉnh chế độ ăn uống và tập luyện.",
      const Color(0xFFE74C3C),
      (bmi / 40).clamp(0.0, 1.0),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import 'scale_button.dart';

class AiSearchBar extends StatefulWidget {
  final void Function(String query) onSubmit;

  const AiSearchBar({required this.onSubmit});

  @override
  State<AiSearchBar> createState() => AiSearchBarState();
}

class AiSearchBarState extends State<AiSearchBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _ctrl,
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              widget.onSubmit(v.trim());
              _ctrl.clear();
            }
          },
          decoration: InputDecoration(
            hintText: 'Bạn muốn hỏi gì hôm nay?',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),

            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                "assets/images/ai_hellodoc_logo.png",
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),

            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ScaleButton(
                onTap: () {
                  if (_ctrl.text.trim().isNotEmpty) {
                    widget.onSubmit(_ctrl.text.trim());
                    _ctrl.clear();
                  }
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightTheme.withOpacity(0.5),
                  ),
                  child: Icon(
                    Icons.send,
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),

            filled: true,
            fillColor: theme.colorScheme.surface,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}


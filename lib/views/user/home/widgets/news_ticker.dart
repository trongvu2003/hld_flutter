import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class NewsTicker extends StatefulWidget {
  final List<Map<String, dynamic>> newsList;
  final void Function(Map<String, dynamic>) onNewsTap;

  const NewsTicker({required this.newsList, required this.onNewsTap});

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker> {
  bool _showAll = false;
  int _firstIndex = 0;
  int _secondIndex = 0;
  Timer? _t1, _t2;

  List<Map<String, dynamic>> get _first =>
      widget.newsList.take(widget.newsList.length ~/ 2).toList();

  List<Map<String, dynamic>> get _second =>
      widget.newsList.skip(widget.newsList.length ~/ 2).toList();

  String _forceText(String t) => t.length < 30 ? (t + '     ') * 3 : t;

  Duration _delay(String t) {
    final w = t.length * 8.0;
    final d = (w > 360 ? w : 360.0) / 50;
    return Duration(milliseconds: (d * 1000).toInt() + 2000);
  }

  void _startTimers() {
    _t1?.cancel();
    _t2?.cancel();
    if (_showAll) return;

    void tick1() {
      _t1 = Timer(_delay(_forceText(_first[_firstIndex]['title'] ?? '')), () {
        if (!mounted || _showAll) return;
        setState(() => _firstIndex = (_firstIndex + 1) % _first.length);
        tick1();
      });
    }

    void tick2() {
      if (_second.isEmpty) return;
      _t2 = Timer(_delay(_forceText(_second[_secondIndex]['title'] ?? '')), () {
        if (!mounted || _showAll) return;
        setState(() => _secondIndex = (_secondIndex + 1) % _second.length);
        tick2();
      });
    }

    if (_first.isNotEmpty) tick1();
    tick2();
  }

  @override
  void initState() {
    super.initState();
    _startTimers();
  }

  @override
  void dispose() {
    _t1?.cancel();
    _t2?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
        ),
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: Colors.black12, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.lightTheme.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.newspaper,
                  size: 20,
                  color: AppColors.lightTheme,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tin tức',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (widget.newsList.length > 2)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAll = !_showAll;
                      if (!_showAll) _startTimers();
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _showAll ? 'Thu gọn' : 'Xem thêm',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightTheme,
                        ),
                      ),
                      Icon(
                        _showAll ? Icons.expand_less : Icons.expand_more,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Divider(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 12),

          // Content
          _showAll ? _buildList(context) : _buildTicker(context),
        ],
      ),
    );
  }

  Widget _buildTicker(BuildContext context) {
    return Column(
      children: [
        if (_first.isNotEmpty)
          GestureDetector(
            onTap: () => widget.onNewsTap(_first[_firstIndex]),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MarqueeText(
                    key: ValueKey('f$_firstIndex'),
                    text:
                        _forceText(
                          _first[_firstIndex]['title'] ?? '',
                        ).toLowerCase(),
                  ),
                ),
              ],
            ),
          ),
        if (_second.isNotEmpty) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => widget.onNewsTap(_second[_secondIndex]),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MarqueeText(
                    key: ValueKey('s$_secondIndex'),
                    text:
                        _forceText(
                          _second[_secondIndex]['title'] ?? '',
                        ).toLowerCase(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    return Column(
      children:
          widget.newsList.map((news) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () => widget.onNewsTap(news),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        news['title'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  thickness: 1,
                ),
              ],
            );
          }).toList(),
    );
  }
}

// Marquee text widget
class _MarqueeText extends StatefulWidget {
  final String text;

  const _MarqueeText({super.key, required this.text});

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText> {
  final _ctrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scroll());
  }

  Future<void> _scroll() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted || !_ctrl.hasClients) continue;
      final max = _ctrl.position.maxScrollExtent;
      if (max <= 0) continue;
      await _ctrl.animateTo(
        max,
        duration: Duration(milliseconds: (max * 18).toInt()),
        curve: Curves.linear,
      );
      if (mounted && _ctrl.hasClients) _ctrl.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _ctrl,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: 1,
      ),
    );
  }
}

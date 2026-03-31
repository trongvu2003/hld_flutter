import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hld_flutter/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/user_viewmodel.dart';

class ContainerPost {
  final String imageUrl;
  final String name;
  final String label;

  ContainerPost({
    required this.imageUrl,
    required this.name,
    required this.label,
  });
}

class CreatePostScreen extends StatefulWidget {
  final String? postId;

  const CreatePostScreen({super.key, this.postId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<XFile> _selectedMedia = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  static const int _maxChars = 400;

  bool get _isEditMode => widget.postId != null;

  bool get _isPostEnabled =>
      _textController.text.trim().isNotEmpty || _selectedMedia.isNotEmpty;

  late AnimationController _buttonAnimCtrl;
  late Animation<double> _buttonScaleAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserViewModel>().loadUser();
    });
    
    _buttonAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonScaleAnim = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _buttonAnimCtrl, curve: Curves.easeOut));

    _textController.addListener(() {
      setState(() {});
      if (_isPostEnabled) {
        _buttonAnimCtrl.forward();
      } else {
        _buttonAnimCtrl.reverse();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _buttonAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    try {
      // Xin quyền
      PermissionStatus status;

      if (Platform.isAndroid) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.photos.request();
      }

      if (!status.isGranted) {
        _showSnack('Bạn cần cấp quyền truy cập ảnh');
        return;
      }

      // Chỉ mở thư viện (KHÔNG phải Google Drive)
      final List<XFile> picked = await _picker.pickMultiImage();

      if (picked.isNotEmpty) {
        setState(() {
          _selectedMedia = [..._selectedMedia, ...picked];
        });
        _buttonAnimCtrl.forward();
      }
    } catch (e) {
      _showSnack('Không thể truy cập thư viện ảnh.');
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
    if (!_isPostEnabled) _buttonAnimCtrl.reverse();
  }

  void _validateAndPost() {
    final trimmed = _textController.text.trim();
    if (trimmed.isEmpty && _selectedMedia.isEmpty) {
      _showEmptyContentDialog();
      return;
    }
    if (trimmed.length > _maxChars) return;

    // TODO: call ViewModel create/update
    _showSnack(_isEditMode ? 'Bài viết đã được lưu!' : 'Đã đăng bài viết!');
    Navigator.pop(context);
  }

  void _showEmptyContentDialog() {
    showDialog(context: context, builder: (_) => const _EmptyContentDialog());
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userViewModel= context.watch<UserViewModel>();
    final user = userViewModel.user;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.colorScheme.secondaryContainer,
        body: SafeArea(
          child:
              _isLoading
                  ? const _LoadingOverlay()
                  : Column(
                    children: [
                      _Header(
                        isEditMode: _isEditMode,
                        isPostEnabled: _isPostEnabled,
                        buttonScaleAnim: _buttonScaleAnim,
                        onBack: () => Navigator.pop(context),
                        onPost: _validateAndPost,
                      ),

                      //Body
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            _PostBody(
                              avatarUrl: user?.avatarURL ?? "",
                              userName: user?.name ?? "",
                              controller: _textController,
                              charCount: _textController.text.length,
                              maxChars: _maxChars,
                            ),
                            if (_selectedMedia.isNotEmpty)
                              _MediaPreviewList(
                                media: _selectedMedia,
                                onRemove: _removeMedia,
                              ),
                            if (_isUpdating) const _LoadingOverlay(),
                          ],
                        ),
                      ),
                      _Footer(onTap: _pickMedia),
                    ],
                  ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isEditMode;
  final bool isPostEnabled;
  final Animation<double> buttonScaleAnim;
  final VoidCallback onBack;
  final VoidCallback onPost;

  const _Header({
    required this.isEditMode,
    required this.isPostEnabled,
    required this.buttonScaleAnim,
    required this.onBack,
    required this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.2),
      color: AppColors.lightTheme,
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // Back button
              IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                  size: 22,
                ),
              ),

              // Title (centered)
              Expanded(
                child: Text(
                  isEditMode ? 'Chỉnh sửa bài viết' : 'Tạo bài viết',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
              ),

              // Post button
              ScaleTransition(
                scale: buttonScaleAnim,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: isPostEnabled ? onPost : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isPostEnabled ? AppColors.lightTheme : Colors.grey,
                      foregroundColor:
                          isPostEnabled
                              ? Colors.black
                              : Colors.grey.withOpacity(0.5),
                      elevation: isPostEnabled ? 4 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      isEditMode ? 'Lưu' : 'Đăng',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostBody extends StatefulWidget {
  final String avatarUrl;
  final String userName;
  final TextEditingController controller;
  final int charCount;
  final int maxChars;

  const _PostBody({
    required this.avatarUrl,
    required this.userName,
    required this.controller,
    required this.charCount,
    required this.maxChars,
  });

  @override
  State<_PostBody> createState() => _PostBodyState();
}

class _PostBodyState extends State<_PostBody> {
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode =
        FocusNode()..addListener(() {
          setState(() => _isFocused = _focusNode.hasFocus);
        });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Color _counterColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (widget.charCount > widget.maxChars) return cs.error;
    if (widget.charCount > widget.maxChars * 0.9) return cs.tertiary;
    return cs.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      color: cs.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + Name row
            Row(
              children: [
                _GradientAvatar(imageUrl: widget.avatarUrl),
                const SizedBox(width: 12),
                Text(
                  widget.userName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Text field with animated gradient border
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient:
                    _isFocused
                        ? LinearGradient(
                          colors: [cs.primary, cs.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : null,
              ),
              padding: _isFocused ? const EdgeInsets.all(2) : EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(_isFocused ? 10 : 12),
                ),
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  maxLines: 12,
                  minLines: 5,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurface,
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(widget.maxChars),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Hãy nói gì đó ...',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ),

            // Character counter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _counterColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.charCount}/${widget.maxChars} ký tự',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _counterColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Gradient Avatar ──────────────────────────────────────────────────────────

class _GradientAvatar extends StatelessWidget {
  final String imageUrl;

  const _GradientAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [cs.primary.withOpacity(0.5), cs.secondary.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: cs.primaryContainer.withOpacity(0.3),
      ),
    );
  }
}

// ─── Media Preview List ───────────────────────────────────────────────────────

class _MediaPreviewList extends StatelessWidget {
  final List<XFile> media;
  final void Function(int) onRemove;

  const _MediaPreviewList({required this.media, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 204,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: media.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder:
            (_, i) => _MediaCard(file: media[i], onRemove: () => onRemove(i)),
      ),
    );
  }
}

class _MediaCard extends StatefulWidget {
  final XFile file;
  final VoidCallback onRemove;

  const _MediaCard({required this.file, required this.onRemove});

  @override
  State<_MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<_MediaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  bool _isVideo(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext);
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVideo = _isVideo(widget.file.path);

    return ScaleTransition(
      scale: _scaleAnim,
      child: SizedBox(
        width: 180,
        height: 180,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              Image.file(
                File(widget.file.path),
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
              ),

              // Gradient overlay for video
              if (isVideo)
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),

              // Video play icon
              if (isVideo)
                Center(
                  child: Icon(
                    Icons.play_circle_filled_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: 48,
                  ),
                ),

              // Delete button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTapDown: (_) => _ctrl.reverse(),
                  onTapUp: (_) {
                    _ctrl.forward();
                    widget.onRemove();
                  },
                  onTapCancel: () => _ctrl.forward(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final VoidCallback onTap;

  const _Footer({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      elevation: 4,
      color: cs.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 72,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.image_search_rounded,
                  size: 36,
                  color: cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thêm ảnh hoặc video',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Loading Overlay ──────────────────────────────────────────────────────────

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      color: cs.surface.withOpacity(0.8),
      alignment: Alignment.center,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: cs.primary, strokeWidth: 4),
              const SizedBox(height: 16),
              Text(
                'Đang xử lý...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty Content Dialog ─────────────────────────────────────────────────────

class _EmptyContentDialog extends StatelessWidget {
  const _EmptyContentDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: Icon(Icons.warning_rounded, color: cs.error, size: 48),
      title: Text(
        'Nội dung trống',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
        ),
      ),
      content: Text(
        'Vui lòng nhập nội dung hoặc chọn ít nhất một hình ảnh để đăng bài.',
        style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          ),
          child: Text(
            'Đã hiểu',
            style: TextStyle(fontWeight: FontWeight.w600, color: cs.onPrimary),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}

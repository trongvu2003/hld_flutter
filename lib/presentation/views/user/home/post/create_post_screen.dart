import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hld_flutter/presentation/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../../../data/models/requestmodel/post.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../viewmodels/user_viewmodel.dart';
import '../../../../viewmodels/post_viewmodel.dart';

class CreatePostScreen extends StatefulWidget {
  final String? postId;
  final String userId;
  final String userRole;

  const CreatePostScreen({
    super.key,
    this.postId,
    required this.userId,
    required this.userRole,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedMedia = [];
  List<String> _existingMedia = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  static const int _maxChars = 400;

  bool get _isEditMode => widget.postId != null;

  // Cho phép đăng nếu có text HOẶC có ảnh cũ HOẶC có ảnh mới
  bool get _isPostEnabled =>
      _textController.text.trim().isNotEmpty ||
      _selectedMedia.isNotEmpty ||
      _existingMedia.isNotEmpty;

  late AnimationController _buttonAnimCtrl;
  late Animation<double> _buttonScaleAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      context.read<UserViewModel>().loadCurrentUser();

      // Lấy thông tin bài viết cũ nếu đang ở chế độ chỉnh sửa
      if (_isEditMode) {
        setState(() => _isLoading = true);
        final postVM = context.read<PostViewModel>();
        await postVM.getPostById(widget.postId!);

        if (mounted && postVM.postDetail != null) {
          setState(() {
            _textController.text = postVM.postDetail!.content ?? '';
            _existingMedia =
                postVM.postDetail!.media?.map((e) => e.toString()).toList() ??
                [];
            _isLoading = false;
            _isLoading = false;
          });
        } else if (mounted) {
          setState(() => _isLoading = false);
        }
      }
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

  Future<void> _validateAndPost() async {
    final trimmed = _textController.text.trim();

    if (trimmed.isEmpty && _selectedMedia.isEmpty) {
      _showEmptyContentDialog();
      return;
    }

    final user = context.read<UserViewModel>().currentUser;
    final postVM = context.read<PostViewModel>();

    if (user == null) {
      _showSnack("Không tìm thấy user");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final mediaPaths = _selectedMedia.map((e) => e.path).toList();

      final request = CreatePostRequest(
        userId: user.id,
        userModel: user.role,
        content: trimmed,
        mediaPaths: mediaPaths,
      );
      if (_isEditMode) {
        await postVM.updatePost(widget.postId!, request);
        _showSnack("Đã cập nhật bài viết!");
      } else {
        await postVM.createPost(request);
      }


      if (mounted) {
        // Lệnh này sẽ xoá sạch các trang trung gian (trang Sửa, trang Chi tiết)
        // và đưa thẳng người dùng về màn hình Home
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.main,
              (route) => false,
        );
      }
    } catch (e) {
      _showSnack("Lỗi: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showEmptyContentDialog() {
    showDialog(context: context, builder: (_) => const _EmptyContentDialog());
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();
    final user = userViewModel.currentUser;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white.withOpacity(0.9),
        body: SafeArea(
          child: Column(
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
                    // Trong ListView của hàm build:
                    if (_selectedMedia.isNotEmpty || _existingMedia.isNotEmpty)
                      _MediaPreviewList(
                        existingMedia: _existingMedia,
                        newMedia: _selectedMedia,
                        onRemoveExisting: (index) {
                          setState(() => _existingMedia.removeAt(index));
                          if (!_isPostEnabled) _buttonAnimCtrl.reverse();
                        },
                        onRemoveNew: (index) {
                          setState(() => _selectedMedia.removeAt(index));
                          if (!_isPostEnabled) _buttonAnimCtrl.reverse();
                        },
                      ),
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
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: widget.controller,
                  maxLines: 12,
                  minLines: 5,
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

//  Gradient Avatar
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
          colors: [
            AppColors.lightTheme.withOpacity(0.5),
            Colors.black.withOpacity(0.5),
          ],
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

//  Media Preview List
class _MediaPreviewList extends StatelessWidget {
  final List<String> existingMedia;
  final List<XFile> newMedia;
  final void Function(int) onRemoveExisting;
  final void Function(int) onRemoveNew;

  const _MediaPreviewList({
    required this.existingMedia,
    required this.newMedia,
    required this.onRemoveExisting,
    required this.onRemoveNew,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = existingMedia.length + newMedia.length;

    return SizedBox(
      height: 204,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: totalCount,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          // Hiển thị ảnh cũ trước
          if (i < existingMedia.length) {
            return _MediaCard(
              networkUrl: existingMedia[i],
              onRemove: () => onRemoveExisting(i),
            );
          }
          // Sau đó hiển thị ảnh mới chọn
          final newIndex = i - existingMedia.length;
          return _MediaCard(
            localFile: newMedia[newIndex],
            onRemove: () => onRemoveNew(newIndex),
          );
        },
      ),
    );
  }
}

class _MediaCard extends StatefulWidget {
  final String? networkUrl;
  final XFile? localFile;
  final VoidCallback onRemove;

  const _MediaCard({this.networkUrl, this.localFile, required this.onRemove});

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
    final isNetwork = widget.networkUrl != null;
    final pathToCheck = isNetwork ? widget.networkUrl! : widget.localFile!.path;
    final isVideo = _isVideo(pathToCheck);

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
              if (isNetwork)
                Image.network(
                  widget.networkUrl!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: const Icon(Icons.broken_image_rounded),
                      ),
                )
              else
                Image.file(
                  File(widget.localFile!.path),
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: const Icon(Icons.broken_image_rounded),
                      ),
                ),

              // Overlay cho Video
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
              if (isVideo)
                Center(
                  child: Icon(
                    Icons.play_circle_filled_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: 48,
                  ),
                ),

              // Nút xoá
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
    return Material(
      elevation: 4,
      color: Colors.white,
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
                  color: AppColors.lightTheme,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.image_search_rounded,
                  size: 36,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thêm ảnh hoặc video',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//
// // Loading Overlay
// class _LoadingOverlay extends StatelessWidget {
//   const _LoadingOverlay();
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final cs = theme.colorScheme;
//
//     return Container(
//       color: cs.surface.withOpacity(0.8),
//       alignment: Alignment.center,
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         elevation: 8,
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(color: cs.primary, strokeWidth: 4),
//               const SizedBox(height: 16),
//               Text(
//                 'Đang xử lý...',
//                 style: theme.textTheme.bodyLarge?.copyWith(
//                   fontWeight: FontWeight.w500,
//                   color: cs.onSurface,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// Empty Content Dialog

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

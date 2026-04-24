import 'package:flutter/material.dart';
import 'package:hld_flutter/presentation/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/models/responsemodel/review_response.dart';
import '../../../../../viewmodels/review_viewmodel.dart';

class ReviewTab extends StatefulWidget {
  final String doctorId;
  final String currentUserId;

  const ReviewTab({
    super.key,
    required this.doctorId,
    required this.currentUserId,
  });

  @override
  State<ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab> {
  bool _showWriteReview = false;
  bool _refreshTrigger = false;
  String? _editingReviewId;
  int? _editingRating;
  String? _editingComment;

  void _openWriteReview({String? reviewId, int? rating, String? comment}) {
    setState(() {
      _showWriteReview = true;
      _editingReviewId = reviewId;
      _editingRating = rating;
      _editingComment = comment;
    });
  }

  void _closeWriteReview() {
    setState(() {
      _showWriteReview = false;
      _editingReviewId = null;
      _editingRating = null;
      _editingComment = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (_showWriteReview) {
    //   return WriteReviewScreen(
    //     doctorId: widget.doctorId,
    //     userId: widget.currentUserId,
    //     initialRating: _editingRating,
    //     initialComment: _editingComment,
    //     reviewId: _editingReviewId,
    //     onBackClick: _closeWriteReview,
    //     onSubmitClick: (_, __) {
    //       setState(() => _refreshTrigger = !_refreshTrigger);
    //       _closeWriteReview();
    //     },
    //   );
    // }
    return ViewRating(
      doctorId: widget.doctorId,
      refreshTrigger: _refreshTrigger,
      userId: widget.currentUserId,
      onEditReview: (reviewId, rating, comment) =>
          _openWriteReview(reviewId: reviewId, rating: rating, comment: comment),
      onDeleteReview: () =>
          setState(() => _refreshTrigger = !_refreshTrigger),
    );
  }
}


class ViewRating extends StatefulWidget {
  final String doctorId;
  final bool refreshTrigger;
  final String userId;
  final void Function(String reviewId, int rating, String comment) onEditReview;
  final VoidCallback onDeleteReview;

  const ViewRating({
    super.key,
    required this.doctorId,
    required this.refreshTrigger,
    required this.userId,
    required this.onEditReview,
    required this.onDeleteReview,
  });

  @override
  State<ViewRating> createState() => _ViewRatingState();
}

class _ViewRatingState extends State<ViewRating> {
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  @override
  void didUpdateWidget(ViewRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTrigger != widget.refreshTrigger ||
        oldWidget.doctorId != widget.doctorId) {
      _fetchReviews();
    }
  }

  void _fetchReviews() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewViewModel>().fetchReviewsByDoctor(widget.doctorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("ReviewTab nhận DoctorID: ${widget.doctorId}");
    return Consumer<ReviewViewModel>(
      builder: (context, vm, _) {
        final reviews = vm.reviews;
        final isLoading = vm.isLoading;

        final average = reviews.isEmpty
            ? 0.0
            : reviews
            .where((r) => r.rating != null)
            .map((r) => r.rating!)
            .fold(0, (a, b) => a + b) /
            reviews.length;

        final filtered = _selectedRating == 0
            ? reviews
            : reviews.where((r) => r.rating == _selectedRating).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RatingSummary(
                average: average,
                count: reviews.length,
                selectedRating: _selectedRating,
                onRatingSelected: (r) =>
                    setState(() => _selectedRating = r),
              ),

              const SizedBox(height: 20),
              if (isLoading)
                ...List.generate(3, (_) => const _ReviewItemSkeleton())
              else
                ...filtered.map(
                      (review) => ReviewItem(
                    review: review,
                    currentUserId: widget.userId,
                    onEditClick: widget.onEditReview,
                    onDeleteClick: (_) => widget.onDeleteReview(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// RATING SUMMARY
class RatingSummary extends StatelessWidget {
  final double average;
  final int count;
  final int selectedRating;
  final void Function(int) onRatingSelected;

  const RatingSummary({
    super.key,
    required this.average,
    required this.count,
    required this.selectedRating,
    required this.onRatingSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Điểm trung bình
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  average.toStringAsFixed(1),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/5',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
            Text(
              '$count đánh giá',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onBackground,
              ),
            ),
          ],
        ),

        const SizedBox(width: 15),

        // Filter chips
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: List.generate(5, (i) {
              final star = 5 - i;
              final isSelected = selectedRating == star;
              return GestureDetector(
                onTap: () => onRatingSelected(isSelected ? 0 : star),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 11, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.grey
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.lightTheme.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$star',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 3),
                      const Text('★'),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// REVIEW ITEM
class ReviewItem extends StatefulWidget {
  final ReviewResponse review;
  final String currentUserId;
  final void Function(String reviewId, int rating, String comment) onEditClick;
  final void Function(String reviewId) onDeleteClick;

  const ReviewItem({
    super.key,
    required this.review,
    required this.currentUserId,
    required this.onEditClick,
    required this.onDeleteClick,
  });

  @override
  State<ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
  bool _showMenu = false;

  bool get _canEditOrDelete =>
      widget.currentUserId == widget.review.user?.id;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Avatar + tên + ngày + menu ───────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              ClipOval(
                child: Image.network(
                  review.user?.userImage ?? '',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 48,
                    height: 48,
                    color: theme.colorScheme.primaryContainer,
                    child: const Icon(Icons.person),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Tên + sao
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review.user?.name ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        // Ngày
                        Text(
                          review.createdAt?.substring(0, 10) ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Sao
                    Row(
                      children: List.generate(
                        review.rating ?? 0,
                            (_) => Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Menu 3 chấm
              if (_canEditOrDelete)
                Stack(
                  children: [
                    IconButton(
                      onPressed: () =>
                          setState(() => _showMenu = true),
                      icon: const Icon(Icons.more_vert),
                    ),
                    if (_showMenu)
                      Positioned(
                        right: 0,
                        top: 36,
                        child: _DropdownMenu(
                          onEdit: () {
                            setState(() => _showMenu = false);
                            widget.onEditClick(
                              review.id ?? '',
                              review.rating ?? 5,
                              review.comment ?? '',
                            );
                          },
                          onDelete: () {
                            // setState(() => _showMenu = false);
                            // context
                            //     .read<ReviewViewModel>()
                            //     .deleteReview(
                            //   review.id ?? '',
                            //       () => widget.onDeleteClick(
                            //       review.id ?? ''),
                            // );
                          },
                          onDismiss: () =>
                              setState(() => _showMenu = false),
                        ),
                      ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            review.comment?.isNotEmpty == true
                ? review.comment!
                : 'Không có nội dung',
            style: const TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 12),
          Divider(color: theme.dividerColor.withOpacity(0.3)),
        ],
      ),
    );
  }
}


class _DropdownMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDismiss;

  const _DropdownMenu({
    required this.onEdit,
    required this.onDelete,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 120,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: Text('Xóa')),
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade300),
              InkWell(
                onTap: onEdit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: Text('Sửa')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Skeleton
class _ReviewItemSkeleton extends StatelessWidget {
  const _ReviewItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: 120,
                    height: 14,
                    color: Colors.grey.shade300),
                const SizedBox(height: 6),
                Container(
                    width: 80,
                    height: 12,
                    color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Container(
                    width: double.infinity,
                    height: 12,
                    color: Colors.grey.shade300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ─── Star rating row
class StarRatingRow extends StatelessWidget {
  final int selectedStar;
  final void Function(int) onStarSelected;

  const StarRatingRow({
    super.key,
    required this.selectedStar,
    required this.onStarSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: List.generate(5, (i) {
        final star = 5 - i;
        final isSelected = selectedStar == star;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onStarSelected(star),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.secondaryContainer
                    : theme.colorScheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Text('$star',
                      style:
                      const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  const Text('★'),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

//
// // WRITE REVIEW SCREEN
// class WriteReviewScreen extends StatefulWidget {
//   final String doctorId;
//   final String userId;
//   final int? initialRating;
//   final String? initialComment;
//   final String? reviewId;
//   final VoidCallback onBackClick;
//   final void Function(int rating, String comment) onSubmitClick;
//
//   const WriteReviewScreen({
//     super.key,
//     required this.doctorId,
//     required this.userId,
//     this.initialRating,
//     this.initialComment,
//     this.reviewId,
//     required this.onBackClick,
//     required this.onSubmitClick,
//   });
//
//   @override
//   State<WriteReviewScreen> createState() => _WriteReviewScreenState();
// }
//
// class _WriteReviewScreenState extends State<WriteReviewScreen> {
//   late int _selectedStar;
//   late TextEditingController _commentController;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedStar = widget.initialRating ?? 5;
//     _commentController =
//         TextEditingController(text: widget.initialComment ?? '');
//   }
//
//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── App bar row ─────────────────────────────────────────────
//           Row(
//             children: [
//               IconButton(
//                 onPressed: widget.onBackClick,
//                 icon: const Icon(Icons.arrow_back),
//               ),
//               Expanded(
//                 child: Center(
//                   child: Text(
//                     'Viết đánh giá',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 48), // balance icon
//             ],
//           ),
//
//           const SizedBox(height: 24),
//
//           // ── Chọn sao ────────────────────────────────────────────────
//           const Text(
//             'Đánh giá của bạn:',
//             style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
//           ),
//           const SizedBox(height: 12),
//           StarRatingRow(
//             selectedStar: _selectedStar,
//             onStarSelected: (s) => setState(() => _selectedStar = s),
//           ),
//
//           const SizedBox(height: 24),
//
//           // ── Nhận xét ────────────────────────────────────────────────
//           const Text(
//             'Viết nhận xét của bạn:',
//             style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
//           ),
//           const SizedBox(height: 8),
//           TextField(
//             controller: _commentController,
//             maxLines: 4,
//             decoration: InputDecoration(
//               hintText: 'Nhập đánh giá của bạn...',
//               filled: true,
//               fillColor: theme.colorScheme.surface,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 24),
//
//           // ── Nút đăng ────────────────────────────────────────────────
//           Consumer<ReviewViewModel>(
//             builder: (context, vm, _) {
//               return SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed:(){},
//                   // onPressed: vm.isSubmitting
//                   //     ? null
//                   //     : () => context.read<ReviewViewModel>().handleReviewSubmit(
//                   //   reviewId: widget.reviewId,
//                   //   userId: widget.userId,
//                   //   doctorId: widget.doctorId,
//                   //   rating: _selectedStar,
//                   //   comment: _commentController.text,
//                   //   onSuccess: widget.onSubmitClick,
//                   // ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: theme.colorScheme.onBackground,
//                     foregroundColor: theme.colorScheme.background,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: vm.isSubmitting
//                       ? const SizedBox(
//                     width: 24,
//                     height: 24,
//                     child: CircularProgressIndicator(
//                         strokeWidth: 2, color: Colors.white),
//                   )
//                       : const Text('Đăng', style: TextStyle(fontSize: 20)),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

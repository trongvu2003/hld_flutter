import 'package:flutter/material.dart';

class CommentMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CommentMenu({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 22, color: Colors.black),
      onSelected: (val) => val == 'edit' ? onEdit() : onDelete(),
      itemBuilder:
          (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Sửa')),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
    );
  }
}

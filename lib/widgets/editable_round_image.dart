import 'package:flutter/material.dart';

class EditableRoundImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final VoidCallback onEdit;
  /// Shown as a coloured circle with text when [imageUrl] is empty.
  /// Pass the user's full name and this widget extracts up to 2 initials.
  final String? name;

  const EditableRoundImage({
    super.key,
    required this.imageUrl,
    required this.onEdit,
    this.size = 100,
    this.name,
  });

  /// Returns up to two uppercase initials from [name].
  String _initials() {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final showImage = imageUrl.isNotEmpty;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: showImage
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _initialsWidget(),
                  )
                : _initialsWidget(),
          ),
        ),

        /// Edit button
        // Positioned(
        //   bottom: -4,
        //   right: -4,
        //   child: InkWell(
        //     onTap: onEdit,
        //     borderRadius: BorderRadius.circular(999),
        //     child: Container(
        //       width: 42,
        //       height: 42,
        //       decoration: BoxDecoration(
        //         color: const Color(0xFF1F2937),
        //         shape: BoxShape.circle,
        //         boxShadow: const [
        //           BoxShadow(
        //             color: Color(0x33000000),
        //             blurRadius: 12,
        //             offset: Offset(0, 6),
        //           ),
        //         ],
        //       ),
        //       child: const Icon(
        //         Icons.edit,
        //         size: 18,
        //         color: Colors.white,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _initialsWidget() {
    return Container(
      color: const Color(0xFFFF9800),
      child: Center(
        child: Text(
          _initials(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.34,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

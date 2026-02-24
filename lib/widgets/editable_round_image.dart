import 'package:flutter/material.dart';

class EditableRoundImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final VoidCallback onEdit;

  const EditableRoundImage({
    super.key,
    required this.imageUrl,
    required this.onEdit,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
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
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFEFF1F6),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
            ),
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
}

import 'package:calorai/constants/constants.dart';
import 'package:flutter/material.dart';

enum ChallengeStatus { completed, progress }

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final items = [
    ChallengeCardData(
      title: "2L Water Daily",
      subtitle: "Completed",
      imageUrl:
          "https://images.pexels.com/photos/416528/pexels-photo-416528.jpeg?auto=compress&cs=tinysrgb&w=1200",
      status: ChallengeStatus.completed,
    ),
    ChallengeCardData(
      title: "No Sugar 3 Days",
      subtitle: "1/3",
      imageUrl:
          "https://cdn.pixabay.com/photo/2021/10/13/16/08/vegan-salad-6707015_1280.jpg",
      status: ChallengeStatus.progress,
      progressSteps: 3,
      currentStep: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          "Challenges",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) => ChallengeCard(data: items[i]),
      ),
    );
    // return Scaffold(
    //   body: SafeArea(
    //     child: SingleChildScrollView(
    //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    //       child: Column(
    //         children: [
    //           Row(
    //             children: [
    //               GestureDetector(
    //                 onTap: () => Navigator.pop(context),
    //                 child: Container(
    //                   padding: const EdgeInsets.all(8),
    //                   decoration: BoxDecoration(
    //                     borderRadius: BorderRadius.circular(12),
    //                     color: Colors.grey.shade200,
    //                   ),
    //                   child: const Icon(Icons.arrow_back_ios_new, size: 18),
    //                 ),
    //               ),
    //               const SizedBox(width: 12),
    //               const Text(
    //                 "Challenges",
    //                 style: TextStyle(
    //                   fontSize: 18,
    //                   fontWeight: FontWeight.w700,
    //                 ),
    //               ),
    //             ],
    //           ),
    //           SizedBox(height: 20),
    //           Container(
    //             decoration: BoxDecoration(
    //               color: Colors.white,
    //               borderRadius: BorderRadius.circular(15.0),
    //               border: Border.all(
    //                 color: Colors.white,
    //                 width: 1.0,
    //               ),
    //               boxShadow: [
    //                 BoxShadow(
    //                   color: Colors.black12,
    //                   offset: Offset(0, 2),
    //                   blurRadius: 6.0,
    //                 ),
    //               ],
    //             ),
    //             padding: EdgeInsets.all(15),
    //             child: Column(
    //               children: [
    //                 Container(
    //                   child: Image.network(
    //                       "https://cdn.pixabay.com/photo/2018/12/03/14/02/water-3853492_1280.jpg"),
    //                 ),
    //                 SizedBox(height: 20),
    //                 Row(
    //                   children: [
    //                     Column(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         Text(
    //                           "2L Water Daily",
    //                           style: TextStyle(
    //                               fontSize: 18, fontWeight: FontWeight.bold),
    //                         ),
    //                         Text("Completed")
    //                       ],
    //                     ),
    //                     Spacer(),
    //                     Icon(Icons.check_circle, color: Colors.green, size: 26)
    //                   ],
    //                 )
    //               ],
    //             ),
    //           )
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}

class ChallengeCardData {
  final String title;
  final String subtitle;
  final String imageUrl;
  final ChallengeStatus status;

  /// Only for progress type
  final int progressSteps;
  final int currentStep;

  ChallengeCardData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.status,
    this.progressSteps = 0,
    this.currentStep = 0,
  });
}

class ChallengeCard extends StatelessWidget {
  final ChallengeCardData data;
  const ChallengeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImageHeader(imageUrl: data.imageUrl),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _TitleArea(
                    title: data.title,
                    subtitle: data.subtitle,
                  ),
                ),
                const SizedBox(width: 10),
                _RightStatus(data: data),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageHeader extends StatelessWidget {
  final String imageUrl;
  const _ImageHeader({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: const Color(0xFFEFF1F6),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (_, __, ___) {
            return Container(
              color: const Color(0xFFEFF1F6),
              child: const Center(
                child: Icon(Icons.image_not_supported_outlined, size: 26),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TitleArea extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TitleArea({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: subtitle.toLowerCase() == "completed"
                ? const Color(0xFF6B7280)
                : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class _RightStatus extends StatelessWidget {
  final ChallengeCardData data;
  const _RightStatus({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.status == ChallengeStatus.completed) {
      return const _CheckBadge(filled: true);
    }

    // Progress style: one green filled + remaining grey outlined
    final steps = data.progressSteps.clamp(1, 10);
    final current = data.currentStep.clamp(0, steps);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(steps, (i) {
        final done = (i + 1) <= current;
        return Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
          child: _CheckBadge(filled: done),
        );
      }),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  final bool filled;
  const _CheckBadge({required this.filled});

  @override
  Widget build(BuildContext context) {
    final bg = filled ? const Color(0xFF22C55E) : const Color(0xFFF3F4F6);
    final border = filled ? Colors.transparent : const Color(0xFFD1D5DB);
    final iconColor = filled ? Colors.white : const Color(0xFF9CA3AF);

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2),
      ),
      child: Icon(Icons.check, size: 18, color: iconColor),
    );
  }
}

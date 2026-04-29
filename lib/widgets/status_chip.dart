import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isDelivered = status == 'จัดส่งสำเร็จ';
    final backgroundColor =
        isDelivered ? const Color(0xFFE7F7EC) : const Color(0xFFE8F0FE);
    final textColor =
        isDelivered ? const Color(0xFF157347) : const Color(0xFF0B63F6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

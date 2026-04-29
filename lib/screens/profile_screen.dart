import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 12),
          CircleAvatar(
            radius: 52,
            backgroundColor: Color(0xFFE8F0FE),
            child: Icon(
              Icons.person_rounded,
              size: 56,
              color: Color(0xFF0B63F6),
            ),
          ),
          SizedBox(height: 20),
          _ProfileField(
            label: 'ชื่อ',
            value: 'Garry Rider',
            icon: Icons.badge_outlined,
          ),
          SizedBox(height: 12),
          _ProfileField(
            label: 'เบอร์โทร',
            value: '081-234-9876',
            icon: Icons.call_outlined,
          ),
          SizedBox(height: 12),
          _ProfileField(
            label: 'Email',
            value: 'garry.rider@example.com',
            icon: Icons.email_outlined,
          ),
          SizedBox(height: 12),
          _ProfileField(
            label: 'Password',
            value: '********',
            icon: Icons.lock_outline_rounded,
          ),
          SizedBox(height: 20),
          _ReadOnlyNote(),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF0B63F6)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: Colors.black38,
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyNote extends StatelessWidget {
  const _ReadOnlyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF0B63F6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'ข้อมูลโปรไฟล์หน้านี้แสดงแบบอ่านอย่างเดียว ยังไม่สามารถแก้ไขได้',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF18417D),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

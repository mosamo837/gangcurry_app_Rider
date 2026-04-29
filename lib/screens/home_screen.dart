import 'package:flutter/material.dart';

import '../data/sample_parcels.dart';
import '../models/parcel.dart';
import '../widgets/parcel_card.dart';
import 'parcel_detail_screen.dart';
import 'profile_screen.dart';
import 'scan_qr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  List<Parcel> get _filteredParcels {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return sampleParcels;
    }

    return sampleParcels
        .where(
          (parcel) => parcel.trackingNumber.toLowerCase().contains(normalized),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  Future<void> _openScanner() async {
    final Parcel? parcel = await Navigator.of(context).push<Parcel>(
      MaterialPageRoute<Parcel>(
        builder: (context) => const ScanQrScreen(),
      ),
    );

    if (!mounted || parcel == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ParcelDetailScreen(parcel: parcel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredParcels = _filteredParcels;

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการพัสดุที่ต้องจัดส่ง'),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.large(
        onPressed: _openScanner,
        backgroundColor: const Color(0xFF0B63F6),
        foregroundColor: Colors.white,
        child: const Icon(Icons.qr_code_scanner_rounded, size: 34),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 74,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          children: [
            const Expanded(
              child: _BottomBarLabel(
                icon: Icons.inventory_2_outlined,
                label: 'พัสดุ',
                isActive: true,
              ),
            ),
            const SizedBox(width: 56),
            Expanded(
              child: InkWell(
                onTap: _openProfile,
                child: const _BottomBarLabel(
                  icon: Icons.person_outline_rounded,
                  label: 'โปรไฟล์',
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'ค้นหาจากเลขพัสดุ',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredParcels.isEmpty
                ? const Center(
                    child: Text('ไม่พบเลขพัสดุที่ค้นหา'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filteredParcels.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final Parcel parcel = filteredParcels[index];
                      return ParcelCard(
                        parcel: parcel,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  ParcelDetailScreen(parcel: parcel),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BottomBarLabel extends StatelessWidget {
  const _BottomBarLabel({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF0B63F6) : Colors.black54;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

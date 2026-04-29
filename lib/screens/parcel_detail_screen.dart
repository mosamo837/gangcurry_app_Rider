import 'package:flutter/material.dart';

import '../models/parcel.dart';
import '../services/delivery_store.dart';
import '../widgets/detail_tile.dart';
import '../widgets/status_chip.dart';
import 'confirm_delivery_screen.dart';
import 'map_screen.dart';

class ParcelDetailScreen extends StatelessWidget {
  const ParcelDetailScreen({super.key, required this.parcel});

  final Parcel parcel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DeliveryStore.instance,
      builder: (context, child) {
        final effectiveStatus = DeliveryStore.instance.statusFor(parcel);
        final isDelivered = DeliveryStore.instance.isDelivered(parcel);
        final confirmation = DeliveryStore.instance.confirmationFor(parcel);

        return Scaffold(
          appBar: AppBar(
            title: Text(parcel.trackingNumber),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.inventory_2_rounded,
                            color: Color(0xFF0B63F6),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                parcel.customerName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                parcel.trackingNumber,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        StatusChip(status: effectiveStatus),
                      ],
                    ),
                    const SizedBox(height: 20),
                    DetailTile(
                      icon: Icons.location_on_outlined,
                      label: 'ที่อยู่จัดส่ง',
                      value: parcel.address,
                    ),
                    const SizedBox(height: 12),
                    DetailTile(
                      icon: Icons.call_outlined,
                      label: 'เบอร์ติดต่อ',
                      value: parcel.phoneNumber,
                    ),
                    const SizedBox(height: 12),
                    DetailTile(
                      icon: Icons.schedule_outlined,
                      label: 'เวลานัดหมาย',
                      value: parcel.deliveryWindow,
                    ),
                    const SizedBox(height: 12),
                    DetailTile(
                      icon: Icons.note_alt_outlined,
                      label: 'หมายเหตุ',
                      value: parcel.note,
                    ),
                    if (confirmation != null) ...[
                      const SizedBox(height: 12),
                      DetailTile(
                        icon: Icons.photo_camera_back_outlined,
                        label: 'ยืนยันล่าสุด',
                        value: 'มีรูปยืนยันการจัดส่งแล้ว',
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => MapScreen(parcel: parcel),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('ดูแผนที่'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isDelivered
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) =>
                                        ConfirmDeliveryScreen(parcel: parcel),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: Text(
                          isDelivered
                              ? 'ยืนยันการจัดส่งแล้ว'
                              : 'ยืนยันการจัดส่ง',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

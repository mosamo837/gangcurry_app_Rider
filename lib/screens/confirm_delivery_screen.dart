import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/parcel.dart';
import '../services/delivery_store.dart';

class ConfirmDeliveryScreen extends StatefulWidget {
  const ConfirmDeliveryScreen({super.key, required this.parcel});

  final Parcel parcel;

  @override
  State<ConfirmDeliveryScreen> createState() => _ConfirmDeliveryScreenState();
}

class _ConfirmDeliveryScreenState extends State<ConfirmDeliveryScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  bool _isSubmitting = false;

  Future<void> _takePhoto() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null || !mounted) {
      return;
    }

    setState(() {
      _selectedImage = image;
    });
  }

  void _confirmDelivery() {
    final image = _selectedImage;
    if (image == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    DeliveryStore.instance.confirmDelivery(
      parcel: widget.parcel,
      imagePath: image.path,
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDelivered = DeliveryStore.instance.isDelivered(widget.parcel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ยืนยันการจัดส่ง'),
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
                Text(
                  widget.parcel.trackingNumber,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(widget.parcel.customerName),
                const SizedBox(height: 20),
                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(
                      File(_selectedImage!.path),
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F7FB),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFD9E2F2)),
                    ),
                    child: const Center(
                      child: Text('ยังไม่ได้เพิ่มรูปยืนยันการจัดส่ง'),
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(
                      _selectedImage == null ? 'ถ่ายรูปยืนยัน' : 'ถ่ายใหม่',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selectedImage == null || _isSubmitting || isDelivered
                        ? null
                        : _confirmDelivery,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: Text(
                      isDelivered ? 'ยืนยันแล้ว' : 'ยืนยันการจัดส่ง',
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
  }
}

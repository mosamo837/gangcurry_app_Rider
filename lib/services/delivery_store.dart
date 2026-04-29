import 'package:flutter/foundation.dart';

import '../models/parcel.dart';

class DeliveryConfirmation {
  const DeliveryConfirmation({
    required this.imagePath,
    required this.confirmedAt,
  });

  final String imagePath;
  final DateTime confirmedAt;
}

class DeliveryStore extends ChangeNotifier {
  DeliveryStore._();

  static final DeliveryStore instance = DeliveryStore._();

  final Map<String, DeliveryConfirmation> _confirmedByTracking = {};

  bool isDelivered(Parcel parcel) {
    return _confirmedByTracking.containsKey(parcel.trackingNumber);
  }

  String statusFor(Parcel parcel) {
    return isDelivered(parcel) ? 'จัดส่งสำเร็จ' : parcel.status;
  }

  DeliveryConfirmation? confirmationFor(Parcel parcel) {
    return _confirmedByTracking[parcel.trackingNumber];
  }

  void confirmDelivery({
    required Parcel parcel,
    required String imagePath,
  }) {
    _confirmedByTracking[parcel.trackingNumber] = DeliveryConfirmation(
      imagePath: imagePath,
      confirmedAt: DateTime.now(),
    );
    notifyListeners();
  }
}

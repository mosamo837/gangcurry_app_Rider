class Parcel {
  const Parcel({
    required this.trackingNumber,
    required this.customerName,
    required this.address,
    required this.phoneNumber,
    required this.deliveryWindow,
    required this.note,
    required this.status,
    required this.riderLatitude,
    required this.riderLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
  });

  final String trackingNumber;
  final String customerName;
  final String address;
  final String phoneNumber;
  final String deliveryWindow;
  final String note;
  final String status;
  final double riderLatitude;
  final double riderLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
}

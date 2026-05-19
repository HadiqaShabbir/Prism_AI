class BookingModel {
  final String id;
  final String service;
  final String providerName;
  final String location;
  final String slot;
  final int price;
  final String status;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.service,
    required this.providerName,
    required this.location,
    required this.slot,
    required this.price,
    required this.status,
    required this.createdAt,
  });
}

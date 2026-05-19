class AppState {
  static Map<String, dynamic>? currentBooking;

  static List<BookingItem> bookings = [];
}

class BookingItem {
  final String providerName;
  final String service;
  final String city;
  final DateTime time;
  final int price;
  final Map<String, dynamic> providerData;

  BookingItem({
    required this.providerName,
    required this.service,
    required this.city,
    required this.time,
    required this.price,
    required this.providerData,
  });
}

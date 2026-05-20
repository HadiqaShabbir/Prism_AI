class BookingModel {
  final String bookingId;
  final String providerName;
  final String service;
  final String city;
  final String slot;
  final int price;
  final String paymentMethod;
  String status;
  final DateTime timestamp;

  BookingModel({
    required this.bookingId,
    required this.providerName,
    required this.service,
    required this.city,
    required this.slot,
    required this.price,
    required this.paymentMethod,
    this.status = 'Confirmed',
    required this.timestamp,
  });
}

class BookingManager {
  static final BookingManager _instance = BookingManager._internal();
  factory BookingManager() => _instance;
  BookingManager._internal();

  final List<BookingModel> _bookings = [];

  List<BookingModel> get allBookings {
    final sorted = List<BookingModel>.from(_bookings);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  void addBooking(BookingModel booking) {
    _bookings.add(booking);
  }

  String generateBookingId() {
    final now = DateTime.now();
    final rand = (now.millisecondsSinceEpoch % 9000 + 1000).toString();
    return 'PRISM-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$rand';
  }

  void updateStatus(String bookingId, String status) {
    final idx = _bookings.indexWhere((b) => b.bookingId == bookingId);
    if (idx != -1) _bookings[idx].status = status;
  }
}

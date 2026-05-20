import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tracking_screen.dart';
import 'splash_screen.dart';
import '../services/booking_manager.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> provider;
  final Map<String, dynamic> extracted;
  final String userName;
  final String userCity;

  const BookingScreen({
    super.key,
    required this.provider,
    required this.extracted,
    required this.userName,
    required this.userCity,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  static const kNavy = Color(0xFF0A1628);
  static const kBlue = Color(0xFF185FA5);
  static const kCyan = Color(0xFF00C2D4);
  static const kPurple = Color(0xFF6C4FD6);
  static const kCard = Color(0xFFF5F9FF);
  static const kBorder = Color(0xFFD8E6F5);
  static const kText = Color(0xFF1A1A2E);
  static const kMuted = Color(0xFF6B7A8D);

  bool _confirming = false;
  bool _confirmed = false;
  String _selectedSlot = '10:00 AM';
  String _selectedPayment = 'Cash on Service';

  final List<String> _slots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '02:00 PM',
    '04:00 PM',
  ];
  final List<String> _paymentMethods = [
    'Cash on Service',
    'JazzCash',
    'EasyPaisa',
    'Bank Transfer',
  ];

  late AnimationController _confirmCtrl;
  late Animation<double> _confirmScale;

  final String _bookingId =
      '#PRZ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

  @override
  void initState() {
    super.initState();
    _confirmCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _confirmScale = CurvedAnimation(
      parent: _confirmCtrl,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    HapticFeedback.mediumImpact();

    setState(() => _confirming = true);

    await Future.delayed(const Duration(milliseconds: 2000));

    final manager = BookingManager();

    final booking = BookingModel(
      bookingId: manager.generateBookingId(),
      providerName: widget.provider['name'] ?? 'Provider',
      service: widget.extracted['service'] ?? 'Service',
      city: widget.extracted['location'] ?? widget.userCity,
      slot: _selectedSlot,
      price: 2200,
      paymentMethod: _selectedPayment,
      status: 'Confirmed',
      timestamp: DateTime.now(),
    );

    manager.addBooking(booking);

    setState(() {
      _confirming = false;
      _confirmed = true;
    });

    _confirmCtrl.forward();

    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: kText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            SizedBox(
              width: 24,
              height: 28,
              child: CustomPaint(painter: PrismLogoPainter()),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: kText,
                  ),
                ),
                Text(
                  'Confirm your appointment',
                  style: TextStyle(fontSize: 10, color: kMuted),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorder),
        ),
      ),
      body: _confirmed ? _buildConfirmedState() : _buildBookingForm(),
    );
  }

  Widget _buildBookingForm() {
    final p = widget.provider;
    final e = widget.extracted;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Provider summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kNavy,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: kBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFB347),
                            size: 13,
                          ),
                          Text(
                            ' ${p['rating']}  (${p['reviews']} reviews)',
                            style: const TextStyle(
                              color: Color(0xFF8BAACC),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Available',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Service details
          _sectionCard(
            title: 'Service Details',
            icon: Icons.build_rounded,
            child: Column(
              children: [
                _detailRow('Service', e['service'] ?? 'General'),
                _detailRow('Location', e['location'] ?? widget.userCity),
                _detailRow('Urgency', e['urgency'] ?? 'Medium'),
                _detailRow('Distance', p['distance'] as String),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Slot selection
          _sectionCard(
            title: 'Select Time Slot',
            icon: Icons.schedule_rounded,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _slots.map((slot) {
                final selected = slot == _selectedSlot;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSlot = slot),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? kBlue : kCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? kBlue : kBorder),
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : kText,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Payment
          _sectionCard(
            title: 'Payment Method',
            icon: Icons.payment_rounded,
            child: Column(
              children: _paymentMethods.map((method) {
                final selected = method == _selectedPayment;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPayment = method),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? kBlue.withOpacity(0.06) : kCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? kBlue : kBorder,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: selected ? kBlue : kMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          method,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: selected ? kBlue : kText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Price breakdown
          _sectionCard(
            title: 'Price Breakdown',
            icon: Icons.receipt_long_rounded,
            child: Column(
              children: [
                _priceRow('Base Fee', 'Rs 1,800'),
                _priceRow('Distance (${p['distance']})', 'Rs 300'),
                _priceRow('Urgency (${widget.extracted['urgency']})', 'Rs 200'),
                _priceRow('Loyalty Discount', '– Rs 100', isDiscount: true),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: kBorder),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kText,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kBlue, kPurple],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Rs 2,200',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (_confirming)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: kBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Simulating booking confirmation...',
                      style: TextStyle(
                        fontSize: 13,
                        color: kText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  foregroundColor: Colors.white,
                  elevation: 10,
                  shadowColor: kBlue.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flash_on_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Confirm Booking — Rs 2,200',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildConfirmedState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          ScaleTransition(
            scale: _confirmScale,
            child: Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Booking Confirmed',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: kText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your appointment has been successfully scheduled.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: kMuted, height: 1.5),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBorder),
              boxShadow: [
                BoxShadow(
                  color: kBlue.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _confirmRow(Icons.tag_rounded, 'Booking ID', _bookingId),
                const SizedBox(height: 12),
                _confirmRow(
                  Icons.person_rounded,
                  'Provider',
                  widget.provider['name'] as String,
                ),
                const SizedBox(height: 12),
                _confirmRow(Icons.access_time_rounded, 'Slot', _selectedSlot),
                const SizedBox(height: 12),
                _confirmRow(
                  Icons.location_on_rounded,
                  'Location',
                  widget.extracted['location'] ?? widget.userCity,
                ),
                const SizedBox(height: 12),
                _confirmRow(Icons.payment_rounded, 'Payment', _selectedPayment),
                const SizedBox(height: 12),
                _confirmRow(Icons.receipt_rounded, 'Amount', 'Rs 2,200'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                _agentLog('Booking Agent', 'Slot confirmed: $_selectedSlot'),
                _agentLog(
                  'Notification Agent',
                  'Provider notified (Simulated)',
                ),
                _agentLog(
                  'Reminder Agent',
                  'Reminder scheduled for 1hr before',
                ),
                _agentLog(
                  'Workflow Agent',
                  'Status: Awaiting technician dispatch',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrackingScreen(
                      bookingId: _bookingId,
                      provider: widget.provider,
                      slot: _selectedSlot,
                      service: widget.extracted['service'] ?? 'Service',
                      location: widget.extracted['location'] ?? widget.userCity,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: kBlue.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.track_changes_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Track Service',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              style: OutlinedButton.styleFrom(
                foregroundColor: kBlue,
                side: const BorderSide(color: kBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: kBlue.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kBlue, size: 16),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: kMuted)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: kMuted)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDiscount ? const Color(0xFF4CAF50) : kText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: kBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kBlue, size: 15),
        ),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(fontSize: 13, color: kMuted)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _agentLog(String agent, String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF4CAF50),
            size: 14,
          ),
          const SizedBox(width: 7),
          Text(
            '[$agent] ',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF4CAF50),
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(fontSize: 11, color: kText),
            ),
          ),
        ],
      ),
    );
  }
}

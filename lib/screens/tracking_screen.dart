import 'package:flutter/material.dart';
import 'dispute_screen.dart';
import 'splash_screen.dart';

class TrackingScreen extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> provider;
  final String slot;
  final String service;
  final String location;

  const TrackingScreen({
    super.key,
    required this.bookingId,
    required this.provider,
    required this.slot,
    required this.service,
    required this.location,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with SingleTickerProviderStateMixin {
  static const kNavy = Color(0xFF0A1628);
  static const kBlue = Color(0xFF185FA5);
  static const kCyan = Color(0xFF00C2D4);
  static const kPurple = Color(0xFF6C4FD6);
  static const kCard = Color(0xFFF5F9FF);
  static const kBorder = Color(0xFFD8E6F5);
  static const kText = Color(0xFF1A1A2E);
  static const kMuted = Color(0xFF6B7A8D);

  int _currentStep = 3;

  late AnimationController _pulseCtrl;

  final List<Map<String, dynamic>> _timeline = [
    {'label': 'Request Received', 'time': '10:42 AM', 'done': true},
    {'label': 'Request Reviewed', 'time': '10:42 AM', 'done': true},
    {'label': 'Provider Matched', 'time': '10:43 AM', 'done': true},
    {'label': 'Booking Confirmed', 'time': '10:44 AM', 'done': true},
    {'label': 'Technician Assigned', 'time': '10:45 AM', 'done': false},
    {'label': 'En Route to Location', 'time': 'Pending', 'done': false},
    {'label': 'Service In Progress', 'time': 'Pending', 'done': false},
    {'label': 'Completed', 'time': 'Pending', 'done': false},
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _simulateNextStep() {
    if (_currentStep < _timeline.length - 1) {
      setState(() {
        _timeline[_currentStep]['done'] = true;
        _timeline[_currentStep]['time'] = _currentTimeStr();
        _currentStep++;
      });
    }
  }

  String _currentTimeStr() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final doneCount = _timeline.where((s) => s['done'] == true).length;
    final progress = doneCount / _timeline.length;

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Tracking',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: kText,
                  ),
                ),
                Text(
                  widget.bookingId,
                  style: const TextStyle(fontSize: 10, color: kMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DisputeScreen(
                  bookingId: widget.bookingId,
                  provider: widget.provider,
                  service: widget.service,
                ),
              ),
            ),
            icon: const Icon(
              Icons.report_outlined,
              size: 16,
              color: Color(0xFFFF7043),
            ),
            label: const Text(
              'Dispute',
              style: TextStyle(color: Color(0xFFFF7043), fontSize: 12),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorder),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(progress),
            const SizedBox(height: 16),
            _buildProviderCard(),
            const SizedBox(height: 16),
            _buildTimelineCard(),
            const SizedBox(height: 16),
            if (_currentStep < _timeline.length - 1)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _simulateNextStep,
                  icon: const Icon(Icons.skip_next_rounded, size: 20),
                  label: const Text(
                    'Simulate Next Step',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              )
            else
              _buildCompletionCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(double progress) {
    final stepLabel =
        _timeline[_currentStep < _timeline.length
                ? _currentStep
                : _timeline.length - 1]['label']
            as String;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kNavy, Color(0xFF1A2E50)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, _) => Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFF4CAF50,
                    ).withOpacity(0.5 + 0.5 * _pulseCtrl.value),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Live Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                widget.service,
                style: const TextStyle(color: Color(0xFF8BAACC), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            stepLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.location} — ${widget.slot}',
            style: const TextStyle(color: Color(0xFF8BAACC), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(kCyan),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: kCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard() {
    final p = widget.provider;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: kBlue,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB347),
                      size: 12,
                    ),
                    Text(
                      ' ${p['rating']}',
                      style: const TextStyle(fontSize: 11, color: kMuted),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.location_on_rounded,
                      color: kMuted,
                      size: 12,
                    ),
                    Text(
                      ' ${p['distance']}',
                      style: const TextStyle(fontSize: 11, color: kMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.phone_rounded, color: kBlue, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'Contact',
                      style: TextStyle(
                        fontSize: 11,
                        color: kBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline_rounded, color: kPurple, size: 16),
              SizedBox(width: 7),
              Text(
                'Service Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._timeline.asMap().entries.map((e) {
            final i = e.key;
            final step = e.value;
            final isDone = step['done'] as bool;
            final isCurrent = i == _currentStep && !isDone;
            final isLast = i == _timeline.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, _) => Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDone
                              ? const Color(0xFF4CAF50)
                              : isCurrent
                              ? kBlue.withOpacity(0.5 + 0.5 * _pulseCtrl.value)
                              : kCard,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDone
                                ? const Color(0xFF4CAF50)
                                : isCurrent
                                ? kBlue
                                : kBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          isDone
                              ? Icons.check_rounded
                              : isCurrent
                              ? Icons.radio_button_checked_rounded
                              : Icons.circle_outlined,
                          size: 14,
                          color: isDone || isCurrent ? Colors.white : kMuted,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 32,
                        color: isDone
                            ? const Color(0xFF4CAF50).withOpacity(0.3)
                            : kBorder,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['label'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isDone || isCurrent
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isDone || isCurrent ? kText : kMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          step['time'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDone ? const Color(0xFF4CAF50) : kMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF4CAF50),
            size: 40,
          ),
          const SizedBox(height: 10),
          const Text(
            'Service Completed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: kText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Rate your experience and provide feedback.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: kMuted, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFB347),
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Submit Feedback',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

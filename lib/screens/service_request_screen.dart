import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'provider_screen.dart';
import 'splash_screen.dart';
import '../services/ai_engine.dart';

class ServiceRequestScreen extends StatefulWidget {
  final String userName;
  final String userCity;

  const ServiceRequestScreen({
    super.key,
    required this.userName,
    required this.userCity,
  });

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen>
    with TickerProviderStateMixin {
  static const kNavy = Color(0xFF0A1628);
  static const kBlue = Color(0xFF185FA5);
  static const kCyan = Color(0xFF00C2D4);
  static const kPurple = Color(0xFF6C4FD6);
  static const kCard = Color(0xFFF5F9FF);
  static const kBorder = Color(0xFFD8E6F5);
  static const kText = Color(0xFF1A1A2E);
  static const kMuted = Color(0xFF6B7A8D);

  final _controller = TextEditingController();
  bool _analyzing = false;
  bool _showResult = false;

  late AnimationController _pulseCtrl;
  late AnimationController _resultCtrl;
  late Animation<double> _resultFade;
  late Animation<Offset> _resultSlide;

  Map<String, dynamic> _extracted = {};
  ParsedRequest? parsedRequest;

  final List<String> _suggestions = [
    'Mujhe kal subah AC technician chahiye G-13 mein',
    'Need electrician in DHA tonight',
    'Plumber chahiye aaj Gulshan mein',
    'Beautician appointment Sunday ko',
    'Home tutor for maths in F-10',
  ];

  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.ac_unit_rounded,
      'label': 'AC Repair',
      'color': Color(0xFF00C2D4),
    },
    {
      'icon': Icons.electrical_services_rounded,
      'label': 'Electrician',
      'color': Color(0xFFFFB347),
    },
    {
      'icon': Icons.plumbing_rounded,
      'label': 'Plumbing',
      'color': Color(0xFF4FC3F7),
    },
    {
      'icon': Icons.face_retouching_natural_rounded,
      'label': 'Beautician',
      'color': Color(0xFFFF80AB),
    },
    {
      'icon': Icons.menu_book_rounded,
      'label': 'Tutor',
      'color': Color(0xFF6C4FD6),
    },
    {
      'icon': Icons.cleaning_services_rounded,
      'label': 'Cleaning',
      'color': Color(0xFF66BB6A),
    },
    {
      'icon': Icons.build_rounded,
      'label': 'Mechanic',
      'color': Color(0xFFFF7043),
    },
    {
      'icon': Icons.local_shipping_rounded,
      'label': 'Shifting',
      'color': Color(0xFF185FA5),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _resultCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _resultFade = CurvedAnimation(parent: _resultCtrl, curve: Curves.easeOut);
    _resultSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _resultCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _resultCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyzeRequest() async {
    if (_controller.text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _analyzing = true;
      _showResult = false;
    });
    _resultCtrl.reset();

    // Simulate processing delay for UX
    await Future.delayed(const Duration(milliseconds: 2400));

    // Use REAL AI engine
    final result = AiEngine.parseRequest(_controller.text, widget.userCity);

    setState(() {
      _analyzing = false;
      _showResult = true;
      parsedRequest = result;
      _extracted = result.toExtractedMap();
    });
    _resultCtrl.forward();
  }

  void _goToProviders() {
    if (parsedRequest == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderScreen(
          extracted: _extracted,
          parsedRequest: parsedRequest!,
          userName: widget.userName,
          userCity: widget.userCity,
        ),
      ),
    );
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
                  'New Request',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: kText,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'AI Intent Extraction',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputCard(),
            const SizedBox(height: 16),
            if (_analyzing) _buildAnalyzingCard(),
            if (_showResult && !_analyzing) _buildResultCard(),
            if (!_showResult && !_analyzing) _buildSuggestionsSection(),
            if (!_showResult && !_analyzing) _buildCategoriesSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kBlue, kPurple]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'AI Intent Engine',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Urdu · Roman Urdu · English',
                style: TextStyle(fontSize: 11, color: kMuted.withOpacity(0.7)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            maxLines: 4,
            minLines: 3,
            style: const TextStyle(fontSize: 15, color: kText, height: 1.55),
            decoration: InputDecoration(
              hintText:
                  'Describe what you need...\ne.g. "Mujhe kal subah AC technician chahiye DHA mein"',
              hintStyle: TextStyle(
                color: kMuted.withOpacity(0.5),
                fontSize: 13,
                height: 1.5,
              ),
              filled: true,
              fillColor: kCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kBlue, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: const Icon(Icons.mic_rounded, color: kBlue, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _analyzing ? null : _analyzeRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: kBlue.withOpacity(0.4),
                      elevation: 6,
                      shadowColor: kBlue.withOpacity(0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.psychology_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Analyze Request',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
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
                    color: kCyan.withOpacity(0.4 + 0.6 * _pulseCtrl.value),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, _) => Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kPurple.withOpacity(
                      0.4 + 0.6 * (1 - _pulseCtrl.value),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, _) => Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kBlue.withOpacity(0.4 + 0.6 * _pulseCtrl.value),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI is analyzing your request...',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: kText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _stepRow('Language Detection', true),
          _stepRow('Intent Extraction', true),
          _stepRow('Entity Recognition', false),
          _stepRow('Provider Matching', false),
        ],
      ),
    );
  }

  Widget _stepRow(String label, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, _) => Icon(
              done
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: done
                  ? const Color(0xFF4CAF50)
                  : kMuted.withOpacity(0.3 + 0.7 * _pulseCtrl.value),
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: done ? kText : kMuted,
              fontWeight: done ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final confidence = _extracted['confidence'] as int;
    return FadeTransition(
      opacity: _resultFade,
      child: SlideTransition(
        position: _resultSlide,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder),
                boxShadow: [
                  BoxShadow(
                    color: kBlue.withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kPurple, kCyan],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.psychology_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'AI Understanding',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF4CAF50),
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$confidence% Confidence',
                              style: const TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: confidence / 100,
                      backgroundColor: kBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50),
                      ),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Extracted entities
                  _entityRow(
                    Icons.build_circle_rounded,
                    'Service',
                    _extracted['service'] ?? '',
                    kBlue,
                  ),
                  const SizedBox(height: 10),
                  _entityRow(
                    Icons.location_on_rounded,
                    'Location',
                    _extracted['location'] ?? '',
                    kPurple,
                  ),
                  const SizedBox(height: 10),
                  _entityRow(
                    Icons.schedule_rounded,
                    'Time',
                    _extracted['time'] ?? '',
                    kCyan,
                  ),
                  const SizedBox(height: 10),
                  _entityRow(
                    Icons.warning_amber_rounded,
                    'Urgency',
                    _extracted['urgency'] ?? '',
                    const Color(0xFFFF7043),
                  ),
                  const SizedBox(height: 10),
                  _entityRow(
                    Icons.account_balance_wallet_rounded,
                    'Budget',
                    _extracted['budget'] ?? '',
                    const Color(0xFF66BB6A),
                  ),

                  const SizedBox(height: 18),

                  // REAL agent reasoning logs from AiEngine
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kNavy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Agent Reasoning Log',
                          style: TextStyle(
                            color: kCyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Real logs from parsedRequest
                        if (parsedRequest != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: parsedRequest!.agentLog
                                .map(
                                  (log) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      log,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10,
                                        color: Color(0xFF8BAACC),
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _goToProviders,
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
                    Icon(Icons.search_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Find Providers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _entityRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
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
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF4CAF50),
          size: 16,
        ),
      ],
    );
  }

  Widget _buildSuggestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Try These Examples',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: kText,
          ),
        ),
        const SizedBox(height: 10),
        ..._suggestions.map(
          (s) => GestureDetector(
            onTap: () {
              _controller.text = s;
              _analyzeRequest();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: kBlue,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s,
                      style: const TextStyle(fontSize: 13, color: kText),
                    ),
                  ),
                  const Icon(Icons.north_west_rounded, color: kMuted, size: 14),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Browse by Category',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: kText,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.85,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _categories.length,
          itemBuilder: (_, i) {
            final cat = _categories[i];
            return GestureDetector(
              onTap: () {
                _controller.text =
                    'I need a ${cat['label']} service in ${widget.userCity}';
                _analyzeRequest();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (cat['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        cat['icon'] as IconData,
                        color: cat['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat['label'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: kText,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

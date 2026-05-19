import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'splash_screen.dart';
import '../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _customCityController = TextEditingController();
  String _selectedCity = 'Karachi';
  bool _showCustomCity = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _customCityController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFD94040),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _goToHome() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final city = _showCustomCity
        ? _customCityController.text.trim()
        : _selectedCity;

    if (name.isEmpty) {
      _showError('Please enter your name.');
      return;
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      _showError('Name should contain letters only.');
      return;
    }

    final digitsOnly = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (phone.isEmpty) {
      _showError('Please enter your phone number.');
      return;
    }
    if (!RegExp(r'^03\d{9}$').hasMatch(digitsOnly) &&
        !RegExp(r'^\+92\d{10}$').hasMatch(phone) &&
        !RegExp(r'^92\d{10}$').hasMatch(digitsOnly)) {
      _showError(
          'Enter valid Pakistani number (03XX-XXXXXXX or +92XXXXXXXXXX).');
      return;
    }

    if (_showCustomCity && city.isEmpty) {
      _showError('Please enter your city name.');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(userName: name, userCity: city),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              top: -60,
              left: -40,
              right: -40,
              child: Container(
                height: 260,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF185FA5), Color(0xFF1A6BC4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(80),
                    bottomRight: Radius.circular(80),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 52,
                            height: 62,
                            child: CustomPaint(
                                painter: PrismLogoPainter()),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'PRISM AI',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Smart Services. Instantly.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF185FA5)
                                .withOpacity(0.12),
                            blurRadius: 40,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tell us a bit about yourself to get started.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF888780),
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 28),

                          const _FieldLabel('Your Name'),
                          const SizedBox(height: 8),
                          _PrismTextField(
                            controller: _nameController,
                            hint: 'e.g. Hadiqa',
                            icon: Icons.person_outline_rounded,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z\s]')),
                            ],
                          ),

                          const SizedBox(height: 20),

                          const _FieldLabel('Phone Number'),
                          const SizedBox(height: 8),
                          _PrismTextField(
                            controller: _phoneController,
                            hint: '03XX-XXXXXXX',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 20),

                          const _FieldLabel('Your City'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F9FF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: const Color(0xFFD3D1C7)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                    Icons.location_on_outlined,
                                    color: Color(0xFF185FA5),
                                    size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCity,
                                      isExpanded: true,
                                      icon: const Icon(
                                          Icons
                                              .keyboard_arrow_down_rounded,
                                          color: Color(0xFF888780)),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF2C2C2A),
                                      ),
                                      items: AppConstants.cities
                                          .map((city) {
                                        return DropdownMenuItem(
                                          value: city,
                                          child: Text(
                                            city,
                                            style: TextStyle(
                                              color: city == 'Other'
                                                  ? const Color(
                                                      0xFF185FA5)
                                                  : const Color(
                                                      0xFF2C2C2A),
                                              fontWeight:
                                                  city == 'Other'
                                                      ? FontWeight.w600
                                                      : FontWeight
                                                          .normal,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedCity = val!;
                                          _showCustomCity =
                                              val == 'Other';
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (_showCustomCity) ...[
                            const SizedBox(height: 12),
                            _PrismTextField(
                              controller: _customCityController,
                              hint: 'Enter your city name',
                              icon: Icons.edit_location_alt_outlined,
                            ),
                          ],

                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _goToHome,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF185FA5),
                                foregroundColor: Colors.white,
                                elevation: 10,
                                shadowColor: const Color(0xFF185FA5)
                                    .withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded,
                                      size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: Text(
                        'By continuing you agree to our Terms and Privacy Policy',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF444441),
        letterSpacing: 0.3,
      ),
    );
  }
}

class _PrismTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _PrismTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 15, color: Color(0xFF2C2C2A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB4B2A9)),
        prefixIcon:
            Icon(icon, color: const Color(0xFF185FA5), size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F9FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD3D1C7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD3D1C7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF185FA5), width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
      ),
    );
  }
}

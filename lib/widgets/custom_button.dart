import 'package:flutter/material.dart';
import '../utils/colors.dart';

class PrismButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isOutlined;
  final double height;
  final IconData? icon;

  const PrismButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isOutlined = false,
    this.height = 56,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : AppColors.blue,
          foregroundColor: isOutlined ? AppColors.blue : Colors.white,
          elevation: isOutlined ? 0 : 8,
          shadowColor: AppColors.blue.withOpacity(0.35),
          side: isOutlined ? const BorderSide(color: AppColors.blue, width: 1.5) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

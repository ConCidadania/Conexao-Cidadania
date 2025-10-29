import 'package:flutter/material.dart';
import 'package:con_cidadania/core/utils/colors.dart';

class BrandingPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? additionalContent;

  const BrandingPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.additionalContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mainGreen,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              if (additionalContent != null) ...[
                const SizedBox(height: 40),
                additionalContent!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

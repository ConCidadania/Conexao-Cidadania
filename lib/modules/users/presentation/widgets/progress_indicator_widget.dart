import 'package:flutter/material.dart';
import 'package:con_cidadania/core/utils/colors.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final bool isDesktop;

  const ProgressIndicatorWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDesktop ? Colors.white : Colors.white;
    final inactiveColor = isDesktop
        ? Colors.white.withOpacity(0.3)
        : Colors.white.withOpacity(0.3);
    final textColor = isDesktop ? Colors.white : Colors.white;

    return Container(
      padding: isDesktop ? EdgeInsets.zero : const EdgeInsets.all(16),
      decoration: isDesktop
          ? null
          : BoxDecoration(
              color: AppColors.mainGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(totalSteps, (index) {
              final isActive = index < currentStep;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
                  child: _buildProgressBarStep(
                    isActive: isActive,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            "Etapa $currentStep de $totalSteps",
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBarStep({required bool isActive, required Color color}) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

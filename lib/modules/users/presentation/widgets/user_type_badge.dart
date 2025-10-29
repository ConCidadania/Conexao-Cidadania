import 'package:flutter/material.dart';
import 'package:con_cidadania/core/utils/colors.dart';
import '../../domain/value_objects/user_type.dart';

class UserTypeBadge extends StatelessWidget {
  final UserType userType;
  final double? fontSize;

  const UserTypeBadge({
    super.key,
    required this.userType,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getUserTypeColor(userType).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getUserTypeIcon(userType),
            size: fontSize ?? 12,
            color: _getUserTypeColor(userType),
          ),
          const SizedBox(width: 4),
          Text(
            userType.displayName,
            style: TextStyle(
              fontSize: fontSize ?? 12,
              color: _getUserTypeColor(userType),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getUserTypeColor(UserType type) {
    switch (type) {
      case UserType.lawyer:
        return AppColors.yellowColor;
      case UserType.admin:
        return AppColors.redColor;
      case UserType.user:
        return AppColors.mainGreen;
    }
  }

  IconData _getUserTypeIcon(UserType type) {
    switch (type) {
      case UserType.lawyer:
        return Icons.gavel;
      case UserType.admin:
        return Icons.admin_panel_settings;
      case UserType.user:
        return Icons.person;
    }
  }
}

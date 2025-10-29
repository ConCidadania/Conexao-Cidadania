import 'package:flutter/material.dart';
import 'package:con_cidadania/core/utils/colors.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final T? value;
  final String labelText;
  final IconData? prefixIcon;
  final List<DropdownMenuItem<T>> items;
  final String? Function(T?)? validator;
  final void Function(T?)? onChanged;
  final bool enabled;

  const CustomDropdownField({
    super.key,
    this.value,
    required this.labelText,
    this.prefixIcon,
    required this.items,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        style: TextStyle(
          fontSize: 16,
          color: enabled ? AppColors.blackColor : AppColors.mediumGrey,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppColors.mainGreen)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppColors.mainGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppColors.redColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: items,
        validator: validator,
        onChanged: enabled ? onChanged : null,
        dropdownColor: Colors.white,
        icon: Icon(
          Icons.arrow_drop_down,
          color: AppColors.mediumGrey,
        ),
      ),
    );
  }
}

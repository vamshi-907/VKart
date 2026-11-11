import 'package:flutter/material.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';

class VKartButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isDisabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final BorderRadius? borderRadius;

  const VKartButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = !isDisabled && !isLoading;
    final Color bgColor =
        backgroundColor ??
        (isOutlined
            ? Colors.transparent
            : isEnabled
            ? VKartColors.primary
            : VKartColors.disabled);
    final Color txtColor =
        textColor ?? (isEnabled ? VKartColors.surface : VKartColors.disabled);
    final Color borderColor = isOutlined
        ? (isEnabled ? VKartColors.primary : VKartColors.disabled)
        : Colors.transparent;
    final double elevation = isOutlined ? 0 : (isEnabled ? 2 : 0);

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: txtColor,
          elevation: elevation,
          shadowColor: VKartColors.primary.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            side: BorderSide(color: borderColor, width: isOutlined ? 1 : 0),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    VKartColors.surface,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(suffixIcon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

// Convenience constructors for different button types
class VKartPrimaryButton extends VKartButton {
  const VKartPrimaryButton({
    super.key,
    required super.text,
    required super.onPressed,
    super.isLoading,
    super.prefixIcon,
    super.suffixIcon,
    super.width,
    super.height,
  });
}

class VKartOutlinedButton extends VKartButton {
  const VKartOutlinedButton({
    super.key,
    required super.text,
    required super.onPressed,
    super.isLoading,
    super.prefixIcon,
    super.suffixIcon,
    super.width,
    super.height,
  }) : super(
         isOutlined: true,
       );
}

class VKartDangerButton extends VKartButton {
  const VKartDangerButton({
    super.key,
    required super.text,
    required super.onPressed,
    super.isLoading,
    super.prefixIcon,
    super.suffixIcon,
    super.width,
    super.height,
  }) : super(
         backgroundColor: VKartColors.error,
       );
}

class VKartSuccessButton extends VKartButton {
  const VKartSuccessButton({
    super.key,
    required super.text,
    required super.onPressed,
    super.isLoading,
    super.prefixIcon,
    super.suffixIcon,
    super.width,
    super.height,
  }) : super(
         backgroundColor: VKartColors.success,
       );
}

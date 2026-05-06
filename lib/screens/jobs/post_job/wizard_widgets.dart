import 'package:flutter/material.dart';

const Color kPrimary = Color(0xFF5B4DFF);
const Color kPrimaryLight = Color(0xFF7C6FFF);
const Color kBg = Color(0xFFF5F7FB);
const Color kSurface = Colors.white;
const Color kBorder = Color(0xFFE8ECF4);
const Color kText = Color(0xFF1A1D2E);
const Color kTextSub = Color(0xFF6B7280);
const Color kTextHint = Color(0xFFB0B7C3);

/// ─────────────────────────────────────────────
///  Gradient primary button
/// ─────────────────────────────────────────────
class WizardPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;

  const WizardPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kPrimary, kPrimaryLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, color: Colors.white, size: 18),
                  ],
                ],
              ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
///  Outlined back button
/// ─────────────────────────────────────────────
class WizardBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const WizardBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder, width: 1.5),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: kText),
            SizedBox(width: 6),
            Text(
              'Back',
              style: TextStyle(
                color: kText,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
///  Section label
/// ─────────────────────────────────────────────
class WizardLabel extends StatelessWidget {
  final String text;
  final bool required;

  const WizardLabel(this.text, {super.key, this.required = true});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: kText,
          letterSpacing: 0.1,
        ),
        children: required
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFEF4444)),
                )
              ]
            : [],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
///  Modern text field
/// ─────────────────────────────────────────────
class WizardTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final int maxLines;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const WizardTextField({
    super.key,
    required this.hint,
    this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        color: kText,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kTextHint, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18, color: kTextSub)
            : null,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
///  Modern dropdown
/// ─────────────────────────────────────────────
class WizardDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hint;

  const WizardDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint = 'Select',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isEmpty ? null : value,
          hint: Text(
            hint,
            style: const TextStyle(color: kTextHint, fontSize: 14),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: kTextSub, size: 22),
          items: items
              .map((e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontSize: 14,
                        color: kText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
///  Selectable chip
/// ─────────────────────────────────────────────
class WizardChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const WizardChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? kPrimary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected ? kPrimary : kBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? kPrimary : kTextSub),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? kPrimary : kTextSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
///  White card container
/// ─────────────────────────────────────────────
class WizardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const WizardCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

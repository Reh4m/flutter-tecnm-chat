import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/utils/form_validator.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class CustomPhoneNumberField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final List<String> countries;
  final PhoneNumber initialValue;
  final bool enabled;
  final void Function(PhoneNumber)? onInputChanged;

  const CustomPhoneNumberField({
    super.key,
    required this.label,
    required this.controller,
    required this.initialValue,
    this.hint,
    this.countries = const ['MX', 'CO'],
    this.enabled = true,
    this.onInputChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        InternationalPhoneNumberInput(
          countries: countries,
          initialValue: initialValue,
          textFieldController: controller,
          validator: FormValidators.validatePhoneNumber,
          selectorConfig: const SelectorConfig(
            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            showFlags: false,
            trailingSpace: false,
            setSelectorButtonAsPrefixIcon: true,
          ),
          onInputChanged: onInputChanged,
          isEnabled: enabled,
          inputDecoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(50),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withAlpha(20),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withAlpha(20),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

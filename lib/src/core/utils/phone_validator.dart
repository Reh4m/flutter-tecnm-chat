class PhoneValidators {
  static String formatPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleaned.startsWith('+52')) {
      return cleaned;
    }

    if (cleaned.startsWith('52')) {
      return '+$cleaned';
    }

    if (cleaned.length == 10) {
      return '+52$cleaned';
    }

    if (cleaned.length == 11 && cleaned.startsWith('1')) {
      return '+52${cleaned.substring(1)}';
    }

    return cleaned;
  }

  static String formatPhoneNumberForDisplay(String phoneNumber) {
    final cleaned = formatPhoneNumber(phoneNumber);

    if (cleaned.length == 13 && cleaned.startsWith('+52')) {
      return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9)}';
    }

    return phoneNumber;
  }
}

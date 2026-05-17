import '../constants/app_strings.dart';

class Validators {
  Validators._();

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 100) return AppStrings.nameTooLong;
    return null;
  }

  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.addressRequired;
    if (value.trim().length > 255) return AppStrings.addressTooLong;
    return null;
  }

  static String? sessionCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.sessionCodeRequired;
    }
    return null;
  }
}

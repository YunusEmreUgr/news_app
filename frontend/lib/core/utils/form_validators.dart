class FormValidators {
  FormValidators._();

  static String? required(String? value, {String message = 'Bu alan zorunludur'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value, {String message = 'Geçerli bir e-posta adresi giriniz'}) {
    final requiredCheck = required(value);
    if (requiredCheck != null) return requiredCheck;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    if (!emailRegex.hasMatch(value!.trim())) {
      return message;
    }
    return null;
  }

  static String? minLength(String? value, int min, {String? message}) {
    final requiredCheck = required(value);
    if (requiredCheck != null) return requiredCheck;

    if (value!.length < min) {
      return message ?? 'En az $min karakter girmelisiniz';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    final lengthCheck = FormValidators.minLength(value, minLength);
    if (lengthCheck != null) return lengthCheck;

    return null;
  }

  static String? confirmPassword(String? value, String? originalPassword, {String message = 'Şifreler eşleşmiyor'}) {
    final requiredCheck = required(value);
    if (requiredCheck != null) return requiredCheck;

    if (value != originalPassword) {
      return message;
    }
    return null;
  }
}

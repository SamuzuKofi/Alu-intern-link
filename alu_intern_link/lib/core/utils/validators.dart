/// Only students/founders with an ALU-issued email may create an account.
/// This is the first gate in a two-stage trust model: email domain proves
/// ALU affiliation, and startup verification (handled separately by an
/// admin) proves the venture itself is a recognized one.
const String aluEmailDomain = 'alustudent.com';

class Validators {
  Validators._();

  static String? aluEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    final emailPattern = RegExp(r'^[\w\.\-\+]+@[\w\-]+\.[\w\-\.]+$');
    if (!emailPattern.hasMatch(email)) return 'Enter a valid email address';
    if (!email.toLowerCase().endsWith('@$aluEmailDomain')) {
      return 'Use your ALU student email (@$aluEmailDomain)';
    }
    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }
}

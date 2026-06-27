class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  static String? required(String? value, [String field = 'Field']) {
    if (value == null || value.trim().isEmpty) return '$field tidak boleh kosong';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Nomor telepon tidak boleh kosong';
    final regex = RegExp(r'^[0-9]{10,13}$');
    if (!regex.hasMatch(value)) return 'Format nomor telepon tidak valid';
    return null;
  }
}

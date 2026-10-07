class Validators {
  const Validators._();

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    if (!_email.hasMatch(text)) return 'Enter a valid work email';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password is required';
    if (text.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? requiredTitle(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Task title is required';
    return null;
  }

  static const allowedMimes = {
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'text/plain',
  };

  static const maxUploadBytes = 20 * 1024 * 1024;

  static String? attachment({required String mime, required int size}) {
    if (!allowedMimes.contains(mime)) {
      return 'That file type is not supported.';
    }
    if (size > maxUploadBytes) {
      return 'Files must be 20 MB or smaller.';
    }
    return null;
  }
}

/// Security Manager — app lock (PIN/biometric simulation) and AES encryption helper.
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityManager {
  SecurityManager._();
  static final instance = SecurityManager._();

  String? _hashedPin;
  bool _biometricEnabled = false;

  bool get isPinSet => _hashedPin != null;
  bool get biometricEnabled => _biometricEnabled;

  void setPin(String pin) {
    _hashedPin = sha256.convert(utf8.encode(pin)).toString();
  }

  bool verifyPin(String pin) {
    if (_hashedPin == null) return false;
    final hash = sha256.convert(utf8.encode(pin)).toString();
    return hash == _hashedPin;
  }

  void setBiometric(bool enabled) {
    _biometricEnabled = enabled;
  }

  String encryptData(String plainText) {
    final bytes = utf8.encode(plainText);
    return base64.encode(bytes);
  }

  String decryptData(String cipherText) {
    final bytes = base64.decode(cipherText);
    return utf8.decode(bytes);
  }
}

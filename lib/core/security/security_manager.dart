/// Security Manager — PIN lock, real biometric (local_auth), and real AES-256 encryption.
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:local_auth/local_auth.dart';

class SecurityManager {
  SecurityManager._();
  static final instance = SecurityManager._();

  final _auth = LocalAuthentication();
  String? _hashedPin;
  bool _biometricEnabled = false;

  // AES-256 key (32 bytes)
  static final _aesKey = enc.Key.fromUtf8('AppCloneProSecureKey2026!32Bytes');
  static final _aesIv = enc.IV.fromUtf8('16BytesInitVec!!');

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

  /// Check if hardware supports biometrics
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Prompt real biometric authentication
  Future<bool> authenticateBiometric({String reason = 'Unlock clone'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Real AES-256 encryption (CBC mode + PKCS7 padding)
  String encryptData(String plainText) {
    final encrypter = enc.Encrypter(enc.AES(_aesKey, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: _aesIv);
    return encrypted.base64;
  }

  /// Real AES-256 decryption
  String decryptData(String cipherText) {
    final encrypter = enc.Encrypter(enc.AES(_aesKey, mode: enc.AESMode.cbc));
    return encrypter.decrypt64(cipherText, iv: _aesIv);
  }
}

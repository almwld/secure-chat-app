import 'package:encrypt/encrypt.dart';

class SecureChat {
  // مفتاح ثابت (للتجربة) - يجب أن يكون 32 حرفاً
  static final _key = Key.fromUtf8('my_super_secret_key_32_chars_!!');
  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key));

  static String encrypt(String text) {
    return _encrypter.encrypt(text, iv: _iv).base64;
  }

  static String decrypt(String encryptedBase64) {
    return _encrypter.decrypt64(encryptedBase64, iv: _iv);
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_template/core/utils/form_validators.dart';

void main() {
  group('FormValidators Unit Tests', () {
    test('required - boş değer için hata dönmeli', () {
      expect(FormValidators.required(null), isNotNull);
      expect(FormValidators.required(''), isNotNull);
      expect(FormValidators.required('   '), isNotNull);
      expect(FormValidators.required('Dolu'), isNull);
    });

    test('email - geçerli ve geçersiz e-postaları doğrulamalı', () {
      expect(FormValidators.email('test@example.com'), isNull);
      expect(FormValidators.email('user.name@domain.co'), isNull);

      expect(FormValidators.email('invalid-email'), isNotNull);
      expect(FormValidators.email('test@domain'), isNotNull);
    });

    test('password - uzunluk kontrolü yapmalı', () {
      expect(FormValidators.password('12345'), isNotNull);
      expect(FormValidators.password('123456'), isNull);
    });

    test('confirmPassword - eşleşme kontrolü yapmalı', () {
      expect(FormValidators.confirmPassword('pass123', 'pass123'), isNull);
      expect(FormValidators.confirmPassword('pass123', 'pass456'), isNotNull);
    });
  });
}

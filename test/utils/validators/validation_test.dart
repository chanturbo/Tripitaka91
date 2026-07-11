import 'package:flutter_test/flutter_test.dart';
import 'package:tripitaka91/utils/validators/validation.dart';

void main() {
  group('TValidator.validateDob', () {
    test('rejects null and empty', () {
      expect(TValidator.validateDob(null), isNotNull);
      expect(TValidator.validateDob(''), isNotNull);
    });

    test('accepts any non-empty value', () {
      expect(TValidator.validateDob('1990-01-01'), isNull);
    });
  });

  group('TValidator.validateFirstId', () {
    test('rejects null and empty', () {
      expect(TValidator.validateFirstId(null), isNotNull);
      expect(TValidator.validateFirstId(''), isNotNull);
    });

    test('accepts any non-empty value', () {
      expect(TValidator.validateFirstId('นาย'), isNull);
    });
  });

  group('TValidator.validateFirstName', () {
    test('rejects null and empty', () {
      expect(TValidator.validateFirstName(null), isNotNull);
      expect(TValidator.validateFirstName(''), isNotNull);
    });

    test('accepts any non-empty value', () {
      expect(TValidator.validateFirstName('สมชาย'), isNull);
    });
  });

  group('TValidator.validateLastName', () {
    test('rejects null and empty', () {
      expect(TValidator.validateLastName(null), isNotNull);
      expect(TValidator.validateLastName(''), isNotNull);
    });

    test('accepts any non-empty value', () {
      expect(TValidator.validateLastName('ใจดี'), isNull);
    });
  });

  group('TValidator.validateUserName', () {
    test('rejects null and empty', () {
      expect(TValidator.validateUserName(null), isNotNull);
      expect(TValidator.validateUserName(''), isNotNull);
    });

    test('rejects non-alphanumeric characters', () {
      expect(TValidator.validateUserName('user_name'), isNotNull);
      expect(TValidator.validateUserName('ผู้ใช้'), isNotNull);
      expect(TValidator.validateUserName('user name'), isNotNull);
    });

    test('accepts letters and digits only', () {
      expect(TValidator.validateUserName('user123'), isNull);
      expect(TValidator.validateUserName('ABC'), isNull);
    });
  });

  group('TValidator.validateEmail', () {
    test('rejects null and empty', () {
      expect(TValidator.validateEmail(null), isNotNull);
      expect(TValidator.validateEmail(''), isNotNull);
    });

    test('rejects malformed addresses', () {
      expect(TValidator.validateEmail('not-an-email'), isNotNull);
      expect(TValidator.validateEmail('@nolocalpart.com'), isNotNull);
      expect(TValidator.validateEmail('user@.com'), isNotNull);
    });

    test('accepts well-formed addresses', () {
      expect(TValidator.validateEmail('user@example.com'), isNull);
      expect(TValidator.validateEmail('first.last+tag@sub.example.co.th'),
          isNull);
    });

    test('accepts a domain with no TLD — the regex does not require one',
        () {
      // Pinning actual (lenient) behavior, not necessarily ideal behavior.
      expect(TValidator.validateEmail('user@localhost'), isNull);
    });
  });

  group('TValidator.validatePassword', () {
    test('rejects null and empty', () {
      expect(TValidator.validatePassword(null), isNotNull);
      expect(TValidator.validatePassword(''), isNotNull);
    });

    test('rejects passwords shorter than 6 characters', () {
      expect(TValidator.validatePassword('ab1'), isNotNull);
    });

    test('rejects passwords with no lowercase English letter', () {
      expect(TValidator.validatePassword('123456'), isNotNull);
      expect(TValidator.validatePassword('ABCDEF'), isNotNull);
    });

    test('accepts a 6+ character password containing a lowercase letter',
        () {
      expect(TValidator.validatePassword('abc123'), isNull);
      expect(TValidator.validatePassword('password'), isNull);
    });
  });

  group('TValidator.validatePasswordMatch', () {
    test('rejects mismatched passwords', () {
      expect(TValidator.validatePasswordMatch('abc123', 'abc124'), isNotNull);
    });

    test('accepts matching passwords', () {
      expect(TValidator.validatePasswordMatch('abc123', 'abc123'), isNull);
    });
  });

  group('TValidator.validatePhoneNumber', () {
    test('rejects null and empty', () {
      expect(TValidator.validatePhoneNumber(null), isNotNull);
      expect(TValidator.validatePhoneNumber(''), isNotNull);
    });

    test('rejects anything other than exactly 10 digits', () {
      expect(TValidator.validatePhoneNumber('123456789'), isNotNull); // 9
      expect(TValidator.validatePhoneNumber('12345678901'), isNotNull); // 11
      expect(TValidator.validatePhoneNumber('081-234-5678'), isNotNull);
    });

    test('accepts exactly 10 digits', () {
      expect(TValidator.validatePhoneNumber('0812345678'), isNull);
    });
  });
}

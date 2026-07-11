import 'package:flutter_test/flutter_test.dart';
import 'package:tripitaka91/utils/db_helper/db_helper.dart';

// arabicToThaiNumbers is pure string manipulation and doesn't touch the
// database, so it's safe to call directly on DatabaseHelper() without any
// sqflite setup.
void main() {
  final dbHelper = DatabaseHelper();

  test('converts every Arabic digit to its Thai equivalent', () {
    expect(dbHelper.arabicToThaiNumbers('0123456789'), '๐๑๒๓๔๕๖๗๘๙');
  });

  test('leaves non-digit characters untouched', () {
    expect(dbHelper.arabicToThaiNumbers('book12page3'), 'book๑๒page๓');
  });

  test('returns an empty string unchanged', () {
    expect(dbHelper.arabicToThaiNumbers(''), '');
  });

  test('leaves a string with no digits unchanged', () {
    expect(dbHelper.arabicToThaiNumbers('พระไตรปิฎก'), 'พระไตรปิฎก');
  });
}

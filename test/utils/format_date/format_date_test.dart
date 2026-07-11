import 'package:flutter_test/flutter_test.dart';
import 'package:tripitaka91/utils/format_date/format_date.dart';

void main() {
  test('formats a date as "d MMMM yyyy"', () {
    final result = FormatDate().formatDate(DateTime(2026, 7, 11));
    expect(result, '11 July 2026');
  });

  test('pads single-digit days the same way DateFormat does', () {
    final result = FormatDate().formatDate(DateTime(2026, 1, 5));
    expect(result, '05 January 2026');
  });
}

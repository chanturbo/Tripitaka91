import 'package:flutter_test/flutter_test.dart';
import 'package:tripitaka91/utils/text_title_replace/text_title_replace.dart';

void main() {
  final replacer = TextTitleReplace();

  group('replaceText', () {
    test('removes the given bookBlue substring', () {
      expect(replacer.replaceText('prefix-BOOKBLUE-suffix', 'BOOKBLUE'),
          'prefix--suffix');
    });

    test('expands "(อ." into "(อรรถกถา"', () {
      expect(replacer.replaceText('text(อ.more', 'NOTPRESENT'),
          'text(อรรถกถาmore');
    });

    test('replaces remaining "." with a space', () {
      expect(replacer.replaceText('hello.world', 'NOTPRESENT'),
          'hello world');
    });
  });

  // The tri91 line-detail format used throughout the app is a "|"-delimited
  // record: text|book|page|line|bookRed|cate|no|mark|group|category|detail
  const record =
      'TEXT|BOOK|PAGE|LINE|RED|CATE|NO|MARK|GROUP|CATEGORY|DETAIL';

  test('extractText returns the first field', () {
    expect(replacer.extractText(record), 'TEXT');
  });

  test('extractText returns the whole string when there is no delimiter',
      () {
    expect(replacer.extractText('NoDelimiter'), 'NoDelimiter');
  });

  test('extractRemainingText formats the book/page/line summary', () {
    expect(replacer.extractRemainingText(record),
        'เล่ม BOOK หน้า PAGE บรรทัด LINE');
  });

  test('extractRemainingText returns empty string with no delimiter', () {
    expect(replacer.extractRemainingText('NoDelimiter'), '');
  });

  test('getBookId / getPageId / getLineId read fields 1-3', () {
    expect(replacer.getBookId(record), 'BOOK');
    expect(replacer.getPageId(record), 'PAGE');
    expect(replacer.getLineId(record), 'LINE');
  });

  test('getBookId / getPageId / getLineId are empty with no delimiter', () {
    expect(replacer.getBookId('NoDelimiter'), '');
    expect(replacer.getPageId('NoDelimiter'), '');
    expect(replacer.getLineId('NoDelimiter'), '');
  });

  test('getBookBlue joins fields 1-3 with "/"', () {
    expect(replacer.getBookBlue(record), 'BOOK/PAGE/LINE');
  });

  test('getBookRed / getCate / getNo / getMark / getGroup / getCategory / '
      'getDetail read the remaining fields in order', () {
    expect(replacer.getBookRed(record), 'RED');
    expect(replacer.getCate(record), 'CATE');
    expect(replacer.getNo(record), 'NO');
    expect(replacer.getMark(record), 'MARK');
    expect(replacer.getGroup(record), 'GROUP');
    expect(replacer.getCategory(record), 'CATEGORY');
    expect(replacer.getDetail(record), 'DETAIL');
  });

  // Dictionary entries use a simpler two-field "word|detail" format.
  group('dictionary word|detail fields', () {
    const dictEntry = 'คำศัพท์|ความหมาย';

    test('getWordDict returns the word (field 0)', () {
      expect(replacer.getWordDict(dictEntry), 'คำศัพท์');
    });

    test('getWordDictDetail returns the definition (field 1)', () {
      expect(replacer.getWordDictDetail(dictEntry), 'ความหมาย');
    });

    test(
        'getWordDictDetail returns an empty string on a value with no '
        'delimiter, matching every other getter in this class '
        '(previously threw RangeError — fixed to guard on parts.length > 1 '
        'instead of the always-true parts.isNotEmpty)', () {
      expect(replacer.getWordDictDetail('NoDelimiter'), '');
    });
  });
}

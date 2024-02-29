class TextTitleReplace {
  String replaceText(String originalText, String bookBlue) {
    // ทำการแทนที่ข้อความและส่งค่าออก    อีกคำ 
    String txtTitle = originalText.replaceAll(bookBlue, '');
    txtTitle = txtTitle.replaceAll('(อ.', '(อรรถกถา');
    txtTitle = txtTitle.replaceAll('.', ' ');
    return txtTitle;
  }

  String extractText(String fullText) {
    // แยกข้อความโดยใช้ตัวแบ่ง "|"
    List<String> parts = fullText.split('|');

    // เรียกใช้ค่าที่ต้องการ (ในที่นี้คือ index 0)
    String extractedText = parts.isNotEmpty ? parts[0] : '';

    return extractedText;
  }

  String getWordDict(String fullText) {
    // แยกข้อความโดยใช้ตัวแบ่ง "|"
    List<String> parts = fullText.split('|');

    // เรียกใช้ค่าที่ต้องการ (ในที่นี้คือ index 0)
    String extractedText = parts.isNotEmpty ? parts[0] : '';

    return extractedText;
  }

  String getWordDictDetail(String fullText) {
    // แยกข้อความโดยใช้ตัวแบ่ง "|"
    List<String> parts = fullText.split('|');

    // เรียกใช้ค่าที่ต้องการ (ในที่นี้คือ index 1)
    String extractedText = parts.isNotEmpty ? parts[1] : '';

    return extractedText;
  }

  String extractRemainingText(String fullText) {
    // แยกข้อความโดยใช้ตัวแบ่ง "|"
    List<String> parts = fullText.split('|');

    // ตรวจสอบว่ามีส่วนหลังจากการแยกหรือไม่
    String remainingText = parts.length > 1 ? parts.sublist(1).join('|') : '';

    // เพิ่มข้อความ "เล่ม หน้า บรรทัด" ท้ายข้อความที่แยกได้
    if (remainingText.isNotEmpty) {
      remainingText = 'เล่ม ${parts[1]} หน้า ${parts[2]} บรรทัด ${parts[3]}';
    }

    return remainingText;
  }

  String getBookId(String fullText) {
    // แยกข้อความโดยใช้ตัวแบ่ง "|"
    List<String> parts = fullText.split('|');

    // ตรวจสอบว่ามีส่วนหลังจากการแยกหรือไม่
    String remainingText = parts.length > 1 ? parts.sublist(1).join('|') : '';

    // เพิ่มข้อความ "เล่ม หน้า บรรทัด" ท้ายข้อความที่แยกได้
    if (remainingText.isNotEmpty) {
      remainingText = parts[1];
    }

    return remainingText;
  }

  String getPageId(String fullText) {
    // แยกข้อความโดยใช้ตัวแบ่ง "|"
    List<String> parts = fullText.split('|');

    // ตรวจสอบว่ามีส่วนหลังจากการแยกหรือไม่
    String remainingText = parts.length > 1 ? parts.sublist(1).join('|') : '';

    // เพิ่มข้อความ "เล่ม หน้า บรรทัด" ท้ายข้อความที่แยกได้
    if (remainingText.isNotEmpty) {
      remainingText = parts[2];
    }

    return remainingText;
  }

  String getLineId(String fullText) {
    // แยกข้อความโดยใช้ตัวแบ่ง "|"
    List<String> parts = fullText.split('|');

    // ตรวจสอบว่ามีส่วนหลังจากการแยกหรือไม่
    String remainingText = parts.length > 1 ? parts.sublist(1).join('|') : '';

    // เพิ่มข้อความ "เล่ม หน้า บรรทัด" ท้ายข้อความที่แยกได้
    if (remainingText.isNotEmpty) {
      remainingText = parts[3];
    }

    return remainingText;
  }

  String getBookBlue(String fullText) {
    // แยกข้อความโดยใช้ตัวแบ่ง "|"
    List<String> parts = fullText.split('|');

    // ตรวจสอบว่ามีส่วนหลังจากการแยกหรือไม่
    String remainingText = parts.length > 1 ? parts.sublist(1).join('|') : '';

    // เพิ่มข้อความ "เล่ม หน้า บรรทัด" ท้ายข้อความที่แยกได้
    if (remainingText.isNotEmpty) {
      // remainingText = 'เล่ม ${parts[1]} หน้า ${parts[2]} บรรทัด ${parts[3]}';
      remainingText = '${parts[1]}/${parts[2]}/${parts[3]}';
    }

    return remainingText;
  }

  String getBookRed(String fullText) {
    // แยกข้อความโดยใช้ตัวแบ่ง "|"
    List<String> parts = fullText.split('|');

    // ตรวจสอบว่ามีส่วนหลังจากการแยกหรือไม่
    String remainingText = parts.length > 1 ? parts.sublist(1).join('|') : '';

    // เพิ่มข้อความ "เล่ม หน้า บรรทัด" ท้ายข้อความที่แยกได้
    if (remainingText.isNotEmpty) {
      remainingText = parts[4];
    }

    return remainingText;
  }

  String getCate(String fullText) {
    // แยกข้อความโดยใช้ตัวแบ่ง "|"
    List<String> parts = fullText.split('|');

    // ตรวจสอบว่ามีส่วนหลังจากการแยกหรือไม่
    String remainingText = parts.length > 1 ? parts.sublist(1).join('|') : '';

    // เพิ่มข้อความ "เล่ม หน้า บรรทัด" ท้ายข้อความที่แยกได้
    if (remainingText.isNotEmpty) {
      remainingText = parts[5];
    }

    return remainingText;
  }

  String getNo(String fullText) {
    // แยกข้อความโดยใช้ตัวแบ่ง "|"
    List<String> parts = fullText.split('|');

    // ตรวจสอบว่ามีส่วนหลังจากการแยกหรือไม่
    String remainingText = parts.length > 1 ? parts.sublist(1).join('|') : '';

    // เพิ่มข้อความ "เล่ม หน้า บรรทัด" ท้ายข้อความที่แยกได้
    if (remainingText.isNotEmpty) {
      remainingText = parts[6];
    }

    return remainingText;
  }

  String getMark(String fullText) {
    // แยกข้อความโดยใช้ตัวแบ่ง "|"
    List<String> parts = fullText.split('|');

    // ตรวจสอบว่ามีส่วนหลังจากการแยกหรือไม่
    String remainingText = parts.length > 1 ? parts.sublist(1).join('|') : '';

    // เพิ่มข้อความ "เล่ม หน้า บรรทัด" ท้ายข้อความที่แยกได้
    if (remainingText.isNotEmpty) {
      remainingText = parts[7];
    }

    return remainingText;
  }
}

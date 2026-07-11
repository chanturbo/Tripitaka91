class TValidator {
  static String? validateDob(String? value) {
    // Check for English letters only
    if (value == null || value.isEmpty) {
      return 'กรุณาเลือกวันเดือนปีเกิด';
    }
    return null; // Validation passed
  }

  static String? validateFirstId(String? value) {
    // Check for English letters only
    if (value == null || value.isEmpty) {
      return 'กรุณากรอก คำนำหน้าชื่อ';
    }
    return null; // Validation passed
  }

  static String? validateFirstName(String? value) {
    // Check for English letters only
    if (value == null || value.isEmpty) {
      return 'กรุณากรอก ชื่อ';
    }
    return null; // Validation passed
  }

  static String? validateLastName(String? value) {
    // Check for English letters only
    if (value == null || value.isEmpty) {
      return 'กรุณากรอก นามสกุล';
    }
    return null; // Validation passed
  }

  static String? validateUserName(String? value) {
    // Check for English letters and numbers only
    if (value == null || value.isEmpty) {
      return 'กรุณากรอก UserName';
    } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'UserName ต้องเป็นภาษาอังกฤษและตัวเลขเท่านั้น';
    }
    return null; // Validation passed
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอก email';
    }
    // ใช้ regex เพื่อตรวจสอบรูปแบบ email ที่ถูกต้อง
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (!emailRegex.hasMatch(value)) {
      return 'รูปแบบ email ไม่ถูกต้อง';
    }
    return null; // กลับ null ถ้า email ถูกต้อง
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณาป้อนรหัสผ่านให้ถูกต้อง';
    }

    // Check for minimum password length
    if (value.length < 6) {
      return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร.';
    }

    // Check for at least one lowercase English letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'รหัสผ่านต้องเป็นภาษาอังกฤษเท่านั้น';
    }
/*
    // Check for numbers
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }

    // Check for special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }
*/
    return null;
  }

  static String? validatePasswordMatch(
      String? password, String? confirmPassword) {
    // Check if passwords match
    if (password != confirmPassword) {
      return 'รหัสผ่านป้อนไม่ตรงกัน';
    }
    return null; // Validation passed
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required.';
    }

    // Regular expression for phone number validation (assuming a 10-digit US phone number format)
    final phoneRegExp = RegExp(r'^\d{10}$');

    if (!phoneRegExp.hasMatch(value)) {
      return 'Invalid phone number format (10 digits required).';
    }

    return null;
  }

// Add more custom validators as needed for your specific requirements.
}

import 'package:intl/intl.dart';

class FormatDate {
  String formatDate(DateTime date) {
    final formatter = DateFormat('dd MMMM yyyy');
    return formatter.format(date);
  }
}

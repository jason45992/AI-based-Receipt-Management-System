import 'package:intl/intl.dart';

RegExp amount = RegExp('^[0-9]+(?:\.[0-9]{2})?\$');

bool isValidDate(String value, [String? format]) {
  try {
    DateTime d;
    if (format == null) {
      d = DateFormat.yMd().parseStrict(value);
    } else {
      d = DateFormat(format).parseStrict(value);
    }
    //print('Validated $value using the locale of ${Intl.getCurrentLocale()} - result $d');
    return d != null;
  } catch (e) {
    return false;
  }
}

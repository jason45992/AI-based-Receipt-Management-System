import 'package:intl/intl.dart';

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

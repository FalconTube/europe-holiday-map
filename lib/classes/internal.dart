import 'package:holiday_map/classes/entry.dart';

class CodeAndHoliday {
  final String nutsCode;
  final String division;
  final Holiday holiday;
  final List<DateTime> dayList;
  final int days;

  CodeAndHoliday({
    required this.nutsCode,
    required this.division,
    required this.holiday,
    required this.dayList,
    required this.days,
  });
}

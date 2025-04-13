import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/classes/entry.dart';
import 'package:holiday_map/classes/internal.dart';
import 'package:holiday_map/main.dart';
import 'package:holiday_map/providers/all_countries_provider.dart';
import 'package:holiday_map/providers/rebuild_picker_provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class MyDatePicker extends ConsumerStatefulWidget {
  const MyDatePicker({super.key});

  @override
  MyDatePickerState createState() => MyDatePickerState();
}

class MyDatePickerState extends ConsumerState<MyDatePicker> {
  final isWebMobile = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  Widget build(BuildContext context) {
    final key = ref.watch(keyProvider);
    final selectedCountryData = ref.watch(selectedCountryDataProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: SfDateRangePicker(
        key: key,
        allowViewNavigation: false,
        headerHeight: 50,
        showNavigationArrow: true,
        monthViewSettings: DateRangePickerMonthViewSettings(
            enableSwipeSelection: isWebMobile ? false : true,
            blackoutDates: selectedCountryData?.days,
            showTrailingAndLeadingDates: true),
        toggleDaySelection: true,
        selectionMode: DateRangePickerSelectionMode.extendableRange,
        initialSelectedDate: DateTime.now(),
        minDate: DateTime(2025),
        maxDate: DateTime(2028),
        extendableRangeSelectionDirection:
            ExtendableRangeSelectionDirection.both,
        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) async {
          final PickerDateRange selectedRange = args.value;
          final startDate = selectedRange.startDate;
          final endDate = selectedRange.endDate;
          if (startDate == null || endDate == null) return;
          final days =
              DateTimeRange(start: startDate, end: endDate).duration.inDays;
          final out = findHolidaysForDate(startDate, endDate);

          // Update
          await ref
              .read(nutsDataProvider.notifier)
              .updateMultipleIDs(out, days);
        },
        monthCellStyle: DateRangePickerMonthCellStyle(
            blackoutDateTextStyle: TextStyle(),
            blackoutDatesDecoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent, width: 1),
                shape: BoxShape.circle)),
      ),
    );
  }
}

List<List<CodeAndHoliday>> findHolidaysForDate(
  // Map<String, String?> findHolidaysForDate(
  DateTime firstSelectedDate,
  DateTime lastSelectedDate,
) {
  final allCountryEntries = holdata;
  List<List<CodeAndHoliday>> results = [];

  // Sometimes you just have to do a long for loop...
  // Find all holidays in all subdivisions in all countries
  for (final countryEntry in allCountryEntries) {
    for (final regionEntry in countryEntry.stateHolidays) {
      final nutsCodes = nutsFromCode(countryEntry.country, regionEntry);
      if (nutsCodes == null) {
        // Log.log(
        //     "Could not obtain nuts code for: Country: ${countryEntry.country}, Region: ${regionEntry.code}");
        continue;
      }
      final divisionName = regionEntry.name;
      for (final nutsCode in nutsCodes) {
        List<CodeAndHoliday> regionResults = [];
        List<String> foundHolidayNames = [];
        for (final holiday in regionEntry.holidays) {
          // Check if found this holiday already
          if (foundHolidayNames.contains(holiday.name)) {
            continue;
          }
          final startDateHol = holiday.start;
          final endDateHol = holiday.end;
          final cleanFirstSelectedDate = firstSelectedDate.subtract(
            Duration(seconds: 1),
          );
          final cleanLastSelectedDate = lastSelectedDate.add(
            Duration(seconds: 1),
          );
          final startIsInRange = startDateHol.isAfter(cleanFirstSelectedDate) &&
              startDateHol.isBefore(cleanLastSelectedDate);
          final endIsInRange = endDateHol.isAfter(cleanFirstSelectedDate) &&
              endDateHol.isBefore(cleanLastSelectedDate);
          if (startIsInRange || endIsInRange) {
            // Found a matching holiday
            // Now get amount of days
            final inRangeDates = daysInSelection(
              holiday,
              firstSelectedDate,
              lastSelectedDate,
            );
            regionResults.add(
              CodeAndHoliday(
                nutsCode: nutsCode,
                division: divisionName,
                holiday: holiday, // Fall back to non-english name, if not exist
                dayList: inRangeDates,
                days: inRangeDates.length,
              ),
            );
            // Helper function for found holidays
            foundHolidayNames.add(holiday.name);
          }
          results.add(regionResults);
        }
      }
    }
  }

  return results;
}

List<DateTime> daysInSelection(
  Holiday holiday,
  DateTime selectStart,
  DateTime selectEnd, {
  bool includeOutOfRange = false,
}) {
  final holDays = datesList(holiday.start, holiday.end);
  final selectDays = datesList(selectStart, selectEnd);
  final iteratorDates = includeOutOfRange ? holDays : selectDays;
  final compareDates = includeOutOfRange ? selectDays : holDays;
  List<DateTime> matchingDates = [];
  for (final i in iteratorDates) {
    if (compareDates.contains(i)) matchingDates.add(i);
  }

  return matchingDates;
}

List<DateTime> datesList(DateTime start, DateTime end) {
  var i = start;
  List<DateTime> allDates = [];
  final cleanEnd = end.add(Duration(seconds: 1));
  for (i; i.isBefore(cleanEnd); i = i.add(Duration(days: 1))) {
    allDates.add(i);
  }
  return allDates;
}

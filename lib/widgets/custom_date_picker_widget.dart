import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/classes/entry.dart';
import 'package:holiday_map/classes/internal.dart';
import 'package:holiday_map/main.dart';
import 'package:holiday_map/providers/all_countries_provider.dart';
import 'package:holiday_map/providers/rebuild_picker_provider.dart';
import 'package:holiday_map/providers/selected_map_index_provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class MyDatePicker extends ConsumerStatefulWidget {
  const MyDatePicker({super.key});

  @override
  MyDatePickerState createState() => MyDatePickerState();
}

class MyDatePickerState extends ConsumerState<MyDatePicker> {
  // final isWebMobile = kIsWeb &&
  //     (defaultTargetPlatform == TargetPlatform.iOS ||
  //         defaultTargetPlatform == TargetPlatform.android);

  @override
  Widget build(BuildContext context) {
    final key = ref.watch(keyProvider);
    final controller = ref.watch(controllerProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: SfDateRangePicker(
        key: key,
        controller: controller,
        backgroundColor: Theme.of(context).colorScheme.surface,
        headerStyle: DateRangePickerHeaderStyle(
            backgroundColor: Theme.of(context).colorScheme.surface),
        allowViewNavigation: false,
        headerHeight: 50,
        showNavigationArrow: true,
        monthViewSettings: DateRangePickerMonthViewSettings(
            dayFormat: "EEE",
            // enableSwipeSelection: isWebMobile ? false : true,
            enableSwipeSelection: true,
            firstDayOfWeek: 1,
            showTrailingAndLeadingDates: true),
        toggleDaySelection: true,
        selectionMode: DateRangePickerSelectionMode.extendableRange,
        initialSelectedDate: DateTime.now(),
        minDate: DateTime(2025),
        maxDate: DateTime(2028),
        extendableRangeSelectionDirection:
            ExtendableRangeSelectionDirection.both,
        onViewChanged: (DateRangePickerViewChangedArgs dargs) async {
          SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
            setState(() {});
          });
        },
        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) async {
          final PickerDateRange selectedRange = args.value;
          final startDate = selectedRange.startDate;
          final endDate = selectedRange.endDate;
          if (startDate == null || endDate == null) return;
          final days = DateTimeRange(start: startDate, end: endDate);
          final numDays = days.duration.inDays;
          final out = findHolidaysForDate(startDate, endDate);

          // Update
          await ref
              .read(nutsDataProvider.notifier)
              .updateMultipleIDs(out, numDays);

          // Check if a country is selected
          final selectedNuts = ref.read(selectedMapIndexProvider);
          if (selectedNuts == null) return;

          // If selected, update selected country data
          final data = ref.read(nutsDataProvider);

          final selectionData =
              getSelectedDataFromNuts(data.data, selectedNuts);
          // If we can't find data, remove banner
          if (selectionData == null) {
            ref.read(selectedCountryDataProvider.notifier).resetData();
          } else {
            // If we have data, then update it
            ref
                .read(selectedCountryDataProvider.notifier)
                .setData(selectionData);
          }
          ref.read(keyProvider.notifier).reset();
        },
        cellBuilder: (context, details) {
          final selectedCountryData = ref.watch(selectedCountryDataProvider);

          return customCells(context, details, controller.selectedRange,
              selectedCountryData?.days, controller.displayDate);
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

MapCountryData? getSelectedDataFromNuts(
    List<MapCountryData> data, String nuts) {
  for (final mapCountryData in data) {
    final thisNuts = mapCountryData.nuts;
    if (thisNuts == nuts) {
      return mapCountryData;
    }
  }
  // We can move outside a holiday range of selected country
  // In this case, return null
  return null;
}

List<DateTime>? pickerRangeToDateTimes(PickerDateRange? pRange) {
  if (pRange == null) return null;
  // Check if start and end defined
  final startDate = pRange.startDate;
  final endDate = pRange.endDate;
  if (startDate == null || endDate == null) return null;

  // If both defined, then return range
  List<DateTime> days = [];
  for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
    days.add(startDate.add(Duration(days: i)));
  }
  return days;
}

Widget customCells(
    BuildContext context,
    DateRangePickerCellDetails details,
    PickerDateRange? selectedRange,
    List<DateTime>? overlapDates,
    DateTime? monthDate) {
  // Check if date is today
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final isToday =
      DateTime(details.date.year, details.date.month, details.date.day) ==
          today;

  // Check start, end and range
  final isInSelectedRange =
      pickerRangeToDateTimes(selectedRange)?.contains(details.date) ?? false;
  final isOverlapping = overlapDates?.contains(details.date) ?? false;
  final isOverlappingAndInRange = isInSelectedRange && isOverlapping;

  // Check if same month
  bool dateInMonth = monthDate?.month == details.date.month;

  return Container(
    key: UniqueKey(),
    margin: EdgeInsets.all(2),
    decoration: BoxDecoration(
        color: isOverlappingAndInRange
            ? Theme.of(context).colorScheme.errorContainer
            : isInSelectedRange
                ? Theme.of(context).colorScheme.secondaryContainer
                : Theme.of(context).colorScheme.surface,
        border: isToday
            ? Border.all(
                color: Theme.of(context).colorScheme.onSurfaceVariant, width: 2)
            : null),
    child: Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text(
          details.date.day.toString(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: dateInMonth
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
          ),
        ),
      ],
    ),
  );
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
          final selectionBetweenHolDates =
              cleanFirstSelectedDate.isAfter(startDateHol) &&
                      cleanFirstSelectedDate.isBefore(endDateHol) ||
                  cleanLastSelectedDate.isAfter(startDateHol) &&
                      cleanLastSelectedDate.isBefore(endDateHol);
          if (startIsInRange || endIsInRange || selectionBetweenHolDates) {
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

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/classes/entry.dart';
import 'package:holiday_map/logging/logger.dart';
import 'package:holiday_map/widgets/all_countries_widget.dart';

// Declare globally
// late AllStateHolidays holdata;
late List<AllStateHolidays> holdata;
late Map<String, dynamic> codesMap;

// Load data at start
Future<List<AllStateHolidays>> _loadData() async {
  final String response = await rootBundle.loadString("assets/data.json");
  List<AllStateHolidays> outList = [];
  final jsonData = json.decode(response);
  for (final entry in jsonData) {
    final countryHolidays = AllStateHolidays.fromJson(entry);
    outList.add(countryHolidays);
  }
  return outList;
}

class CodeAndHoliday {
  final String nutsCode;
  final String holiday;
  final List<DateTime> dayList;
  final int days;

  CodeAndHoliday({
    required this.nutsCode,
    required this.holiday,
    required this.dayList,
    required this.days,
  });
}

List<CodeAndHoliday> findHolidaysForDate(
// Map<String, String?> findHolidaysForDate(
    DateTime firstSelectedDate,
    DateTime lastSelectedDate) {
  final allCountryEntries = holdata;

  List<CodeAndHoliday> results = [];

  // Sometimes you just have to do a long for loop...
  // Find all holidays in all subdivisions in all countries
  for (final countryEntry in allCountryEntries) {
    for (final regionEntry in countryEntry.stateHolidays) {
      final nutsCode = nutsFromCode(countryEntry.country, regionEntry);
      if (nutsCode == null) {
        Log.log(
            "Could not obtain nuts code for: Country: ${countryEntry.country}, Region: ${regionEntry.code}");
        continue;
      }
      for (final holiday in regionEntry.holidays) {
        final startDateHol = holiday.start;
        final endDateHol = holiday.end;
        final cleanFirstSelectedDate =
            firstSelectedDate.subtract(Duration(seconds: 1));
        final cleanLastSelectedDate =
            lastSelectedDate.add(Duration(seconds: 1));
        final startIsInRange = startDateHol.isAfter(cleanFirstSelectedDate) &&
            startDateHol.isBefore(cleanLastSelectedDate);
        final endIsInRange = endDateHol.isAfter(cleanFirstSelectedDate) &&
            endDateHol.isBefore(cleanLastSelectedDate);
        if (startIsInRange || endIsInRange) {
          // Found a matching holiday
          // Now get amount of days
          final dates =
              daysInSelection(holiday, firstSelectedDate, lastSelectedDate);
          results.add(CodeAndHoliday(
              nutsCode: nutsCode,
              holiday: holiday.name,
              dayList: dates,
              days: dates.length));
          break; // Exit inner loop once a holiday is found for the region.
        }
      }
    }
  }

  return results;
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

List<DateTime> daysInSelection(
    Holiday holiday, DateTime selectStart, DateTime selectEnd) {
  final holDays = datesList(holiday.start, holiday.end);
  final selectDays = datesList(selectStart, selectEnd);
  List<DateTime> matchingDates = [];
  for (final i in holDays) {
    if (selectDays.contains(i)) matchingDates.add(i);
  }

  return matchingDates;
}

String? nutsFromCode(String country, StateHolidays regionEntry) {
  final List<dynamic> subCodes = codesMap[country.toUpperCase()];
  for (final codeMap in subCodes) {
    final thisIso = codeMap["iso"];
    final thisCode = codeMap["code"];
    if (thisIso == regionEntry.iso || thisCode == regionEntry.code) {
      return codeMap["nuts"];
    }
  }
  return null;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load data at start
  holdata = await _loadData();
  final String response =
      await rootBundle.loadString("assets/geo/codes-map.json");
  codesMap = json.decode(response);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: Durations.short3,
      title: 'Holiday Map',
      theme: ThemeData(
          fontFamily: "Roboto",
          colorScheme: ColorScheme.fromSeed(
            dynamicSchemeVariant: DynamicSchemeVariant.rainbow,
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true),
      home: AllCountriesWidget(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends ConsumerState<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    controller = TabController(length: 1, initialIndex: 0, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

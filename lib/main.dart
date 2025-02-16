import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:countries_world_map/countries_world_map.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/classes/entry.dart';
import 'package:holiday_map/logging/logger.dart';
import 'package:holiday_map/providers/single_country_provider.dart';
import 'package:holiday_map/widgets/my_country_widget.dart';

// Declare globally
// late AllStateHolidays holdata;
late List<AllStateHolidays> holdata;

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

Map<String, String?> findHolidaysForDate(
    DateTime selectedDate, String country) {
  final allCountryEntries = holdata;

  Map<String, String?> result = {};

  // Sometimes you just have to do a long for loop...
  // Find all holidays in all subdivisions in all countries
  for (final countryEntry in allCountryEntries) {
    if (countryEntry.country != country) continue;
    for (final regionEntry in countryEntry.stateHolidays) {
      Log.log(regionEntry.iso);
      for (final holiday in regionEntry.holidays) {
        final startDate = holiday.start;
        final endDate = holiday.end;

        if (selectedDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            selectedDate.isBefore(endDate.add(const Duration(days: 1)))) {
          result[regionEntry.iso] = holiday.nameEN;
          break; // Exit inner loop once a holiday is found for the region.
        }
      }
    }
  }

  return result;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load data at start
  holdata = await _loadData();
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
          colorScheme: ColorScheme.fromSeed(
            dynamicSchemeVariant: DynamicSchemeVariant.rainbow,
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true),
      home: MyHomePage(),
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Holiday Map'),
          elevation: 8,
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: MyCountryPage(country: "world", isWorld: true),
        ));
  }
}

class GermanyMap extends StatelessWidget {
  const GermanyMap({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleMap(
      instructions: SMapGermany.instructions,
    );
  }
}

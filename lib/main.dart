import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/classes/entry.dart';
import 'package:holiday_map/providers/brightness_provider.dart';
import 'package:holiday_map/widgets/all_countries_widget.dart';
import 'package:intl/intl_browser.dart';
import 'package:intl/date_symbol_data_local.dart';

// Declare globally
late List<AllStateHolidays> holdata;
late List<BorderCountry> borderdat;
late Map<String, dynamic> codesMap;

// Load data at start
Future<List<AllStateHolidays>> _loadHolData() async {
  final String response = await rootBundle.loadString("assets/data.json");
  List<AllStateHolidays> outList = [];
  final jsonData = json.decode(response);
  for (final entry in jsonData) {
    final countryHolidays = AllStateHolidays.fromJson(entry);
    outList.add(countryHolidays);
  }
  return outList;
}

Future<List<BorderCountry>> _loadBorderData() async {
  final String response = await rootBundle.loadString(
    "assets/geo/eu-borders.geojson",
  );
  List<BorderCountry> outList = [];
  final jsonData = json.decode(response);
  for (final entry in jsonData["features"]) {
    final borderData = BorderCountry.fromJson(entry["properties"]);
    outList.add(borderData);
  }
  return outList;
}

//TODO: Map this into a proper class, instead of just casting stuff around
List<String>? nutsFromCode(String country, StateHolidays regionEntry) {
  final List<dynamic> subCodes = codesMap[country.toUpperCase()];
  for (final codeMap in subCodes) {
    final thisIso = codeMap["iso"];
    final thisCode = codeMap["code"];
    if (thisIso == regionEntry.iso || thisCode == regionEntry.code) {
      final dynamicList = codeMap["nuts"];
      return dynamicList.cast<String>();
    }
  }
  return null;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load in parallel data at start
  final holdataFut = _loadHolData();
  final borderdatFut = _loadBorderData();
  String response = "";
  final responseFut = rootBundle.loadString("assets/geo/codes-map.json");
  final nutsFut = rootBundle.loadString("assets/geo/eu-nuts.geojson");
  await Future.wait([holdataFut, borderdatFut, responseFut, nutsFut]).then((
    results,
  ) {
    holdata = results[0] as List<AllStateHolidays>;
    borderdat = results[1] as List<BorderCountry>;
    response = results[2] as String;
    // nuts result not needed here, but want to load parallel
    final _ = results[3];
  });

  codesMap = json.decode(response);
  // Get locale
  final locale = await findSystemLocale();
  initializeDateFormatting(locale, null)
      .then((_) => runApp(ProviderScope(child: MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = ref.watch(brightnessProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Holiday Map',
      theme: ThemeData(
        fontFamily: "Roboto",
        colorScheme: ColorScheme.fromSeed(
          dynamicSchemeVariant: DynamicSchemeVariant.rainbow,
          seedColor: Colors.blueAccent,
          brightness: brightness,
        ),
        useMaterial3: true,
      ),
      home: AllCountriesWidget(),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:countries_world_map/countries_world_map.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/classes/entry.dart';
import 'package:holiday_map/logging/logger.dart';
import 'package:holiday_map/providers/single_country_provider.dart';
import 'package:holiday_map/widgets/my_country_widget.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

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

class IsoAndCodeResults {
  Map<String, String?> iso = {};
  Map<String, String?> code = {};
}

IsoAndCodeResults findHolidaysForDate(
// Map<String, String?> findHolidaysForDate(
    DateTime selectedDate,
    String country) {
  final allCountryEntries = holdata;

  var iacResults = IsoAndCodeResults();

  // Sometimes you just have to do a long for loop...
  // Find all holidays in all subdivisions in all countries
  for (final countryEntry in allCountryEntries) {
    if (countryEntry.country != country) continue;
    for (final regionEntry in countryEntry.stateHolidays) {
      for (final holiday in regionEntry.holidays) {
        final startDate = holiday.start;
        final endDate = holiday.end;

        if (selectedDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            selectedDate.isBefore(endDate.add(const Duration(days: 1)))) {
          if (regionEntry.iso != "") {
            iacResults.iso[regionEntry.iso!] = holiday.name;
          }
          if (regionEntry.code != "") {
            iacResults.code[regionEntry.code!] = holiday.name;
          }
          break; // Exit inner loop once a holiday is found for the region.
        }
      }
    }
  }

  return iacResults;
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
  late MapShapeSource _shapeSource;
  late MapShapeSource _nutsSource;
  late MapZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    controller = TabController(length: 1, initialIndex: 0, vsync: this);
    _shapeSource = MapShapeSource.asset('assets/geo/eu-borders.geojson',
        shapeDataField: 'CNTR_ID');
    _nutsSource = MapShapeSource.asset('assets/geo/eu-nuts.geojson',
        shapeDataField: 'NUTS_ID');
    _zoomPanBehavior = MapZoomPanBehavior(
      zoomLevel: 2,
      focalLatLng: const MapLatLng(50.935173, 6.953101),
      minZoomLevel: 2,
      maxZoomLevel: 10,
      enableDoubleTapZooming: true,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.all(20),
      child: SfMaps(
        layers: <MapLayer>[
          MapShapeLayer(
            source: _nutsSource,
            strokeWidth: 0.3,
            color: Colors.grey.withValues(alpha: 0.2),
            strokeColor: Colors.grey,
            sublayers: <MapSublayer>[
              MapShapeSublayer(
                  source: _shapeSource,
                  strokeWidth: 1.5,
                  color: Colors.grey.withValues(alpha: 0.5),
                  strokeColor: Colors.indigoAccent)
            ],
            zoomPanBehavior: _zoomPanBehavior,
          ),
        ],
      ),
    ));
  }
}

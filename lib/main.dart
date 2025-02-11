import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:countries_world_map/countries_world_map.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/classes/entry.dart';
import 'package:holiday_map/logging/logger.dart';
import 'package:holiday_map/widgets/my_country_widget.dart';

// Declare globally
late SubdivisionHolidays holdata;

// Load data at start
Future<SubdivisionHolidays> _loadData() async {
  final String response = await rootBundle.loadString("assets/data.json");
  final jsonData = json.decode(response);
  return SubdivisionHolidays.fromJson(jsonData["subdivionHolidays"][0]);
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
    controller = TabController(length: 2, initialIndex: 0, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Holiday Map'),
            elevation: 8,
            bottom: TabBar(controller: controller, tabs: [
              ListTile(title: Center(child: Text('Germany'))),
              ListTile(title: Center(child: Text('Austria'))),
            ])),
        floatingActionButton: FloatingActionButton(onPressed: () async {
          Log.log(holdata);
        }),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: controller,
              children: [
                MyCountryPage(country: "de"),
                MyCountryPage(country: "at")
              ]),
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

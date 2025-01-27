import 'package:flutter/material.dart';

import 'package:countries_world_map/countries_world_map.dart';
import 'package:holiday_map/widgets/country_widget.dart';

void main() {
  runApp(const MyApp());
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>
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
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: controller,
              children: [
                CountryPage(country: "de"),
                CountryPage(country: "at")
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

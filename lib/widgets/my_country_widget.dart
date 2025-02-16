import 'dart:convert';

import 'package:countries_world_map/countries_world_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/logging/logger.dart';
import 'package:holiday_map/main.dart';
import 'package:holiday_map/providers/single_country_provider.dart';

class MyCountryPage extends ConsumerWidget {
  final String country;
  final bool isWorld;

  const MyCountryPage(
      {super.key, required this.country, required this.isWorld});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(singleCountryProvider(country));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          country.toUpperCase(),
          style: TextStyle(color: Colors.blue),
        ),
      ),
      body: data.instruction == "NOT SUPPORTED"
          ? Center(child: Text("This country is not supported"))
          : Column(
              children: [
                Expanded(
                  child: Row(children: [
                    Expanded(
                        child: Center(
                            child: InteractiveViewer(
                      // alignment: Alignment.topCenter,
                      maxScale: 10,
                      child: SimpleMap(
                        countryBorder:
                            CountryBorder(color: Colors.grey, width: 1),
                        defaultColor: Colors.grey.shade300,
                        key: Key(data.properties.toString()),
                        colors: data.keyValuesPaires,
                        instructions: data.instruction,
                        callback: (id, name, tapDetails) {
                          if (country != "world") return;
                          if (id == "") return;
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MyCountryPage(country: id, isWorld: false);
                          }));
                        },
                      ),
                    ))),
                    if (MediaQuery.of(context).size.width > 800 &&
                        isWorld == false)
                      SizedBox(
                          width: 320,
                          height: MediaQuery.of(context).size.height,
                          child: Card(
                            margin: EdgeInsets.all(16),
                            elevation: 8,
                            child: ListView(
                              children: [
                                for (int i = 0; i < data.properties.length; i++)
                                  ListTile(
                                    title: Text(data.properties[i]['name']),
                                    leading: Container(
                                      margin: EdgeInsets.only(top: 8),
                                      width: 20,
                                      height: 20,
                                      color: data.properties[i]['color'] ??
                                          Colors.grey.shade300,
                                    ),
                                    subtitle: Text(data.properties[i]['id']),
                                    onTap: () {},
                                  )
                              ],
                            ),
                          )),
                  ]),
                ),
                CalendarDatePicker(
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2025), // Set appropriate first date
                    lastDate: DateTime(2028), // Set appropriate last date
                    onDateChanged: (DateTime pickedDate) async {
                      // Log.log(pickedDate.toString());
                      final out = findHolidaysForDate(pickedDate, country);
                      Log.log(out);
                      // Reset
                      await ref
                          .read(singleCountryProvider(country).notifier)
                          .resetData();

                      // Update
                      await ref
                          .read(singleCountryProvider(country).notifier)
                          .updateMultipleIDs(out.keys.toList());
                    }),
              ],
            ),
    );
  }
}

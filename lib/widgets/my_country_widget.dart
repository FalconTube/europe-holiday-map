import 'dart:convert';

import 'package:countries_world_map/countries_world_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/logging/logger.dart';
import 'package:holiday_map/providers/germany_provider.dart';

class MyCountryPage extends ConsumerStatefulWidget {
  final String country;

  const MyCountryPage({required this.country, super.key});

  @override
  ConsumerState<MyCountryPage> createState() => CountryPageState();
}

class CountryPageState extends ConsumerState<MyCountryPage> {
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(germanyProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.country.toUpperCase(),
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
                            child: SimpleMap(
                      defaultColor: Colors.grey.shade300,
                      key: Key(data.properties.toString()),
                      colors: data.keyValuesPaires,
                      instructions: data.instruction,
                      callback: (id, name, tapDetails) {
                        Log.log(id);
                      },
                    ))),
                    if (MediaQuery.of(context).size.width > 800)
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
                if (MediaQuery.of(context).size.width < 800)
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
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
              ],
            ),
    );
  }
}

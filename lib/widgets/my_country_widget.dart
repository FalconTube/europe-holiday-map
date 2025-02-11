import 'dart:convert';

import 'package:countries_world_map/countries_world_map.dart';
import 'package:flutter/material.dart';
import 'package:holiday_map/logging/logger.dart';

class MyCountryPage extends StatefulWidget {
  final String country;

  const MyCountryPage({required this.country, super.key});

  @override
  _CountryPageState createState() => _CountryPageState();
}

class _CountryPageState extends State<MyCountryPage> {
  late String state;
  late String instruction;

  late List<Map<String, dynamic>> properties;

  late Map<String, Color?> keyValuesPaires;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '${widget.country.toUpperCase()} - $state',
          style: TextStyle(color: Colors.blue),
        ),
      ),
      body: instruction == "NOT SUPPORTED"
          ? Center(child: Text("This country is not supported"))
          : Column(
              children: [
                Expanded(
                  child: Row(children: [
                    Expanded(
                        child: Center(
                            child: SimpleMap(
                      defaultColor: Colors.grey.shade300,
                      key: Key(properties.toString()),
                      colors: keyValuesPaires,
                      instructions: instruction,
                      callback: (id, name, tapDetails) {
                        Log.log(id);
                        setState(() {
                          state = name;

                          int i = properties
                              .indexWhere((element) => element['id'] == id);

                          properties[i]['color'] =
                              properties[i]['color'] == Colors.green
                                  ? null
                                  : Colors.green;
                          keyValuesPaires[properties[i]['id']] =
                              properties[i]['color'];
                        });
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
                                for (int i = 0; i < properties.length; i++)
                                  ListTile(
                                    title: Text(properties[i]['name']),
                                    leading: Container(
                                      margin: EdgeInsets.only(top: 8),
                                      width: 20,
                                      height: 20,
                                      color: properties[i]['color'] ??
                                          Colors.grey.shade300,
                                    ),
                                    subtitle: Text(properties[i]['id']),
                                    onTap: () {
                                      setState(() {
                                        properties[i]['color'] = properties[i]
                                                    ['color'] ==
                                                Colors.green
                                            ? null
                                            : Colors.green;
                                        keyValuesPaires[properties[i]['id']] =
                                            properties[i]['color'];
                                      });
                                    },
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
                            for (int i = 0; i < properties.length; i++)
                              ListTile(
                                title: Text(properties[i]['name']),
                                leading: Container(
                                  margin: EdgeInsets.only(top: 8),
                                  width: 20,
                                  height: 20,
                                  color: properties[i]['color'] ??
                                      Colors.grey.shade300,
                                ),
                                subtitle: Text(properties[i]['id']),
                                onTap: () {
                                  setState(() {
                                    properties[i]['color'] =
                                        properties[i]['color'] == Colors.green
                                            ? null
                                            : Colors.green;
                                    keyValuesPaires[properties[i]['id']] =
                                        properties[i]['color'];
                                  });
                                },
                              )
                          ],
                        ),
                      )),
              ],
            ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/classes/entry.dart';
import 'package:holiday_map/logging/logger.dart';
import 'package:holiday_map/main.dart';
import 'package:collection/collection.dart';

/// Every holiday has a number of days attached to it
class MapCountryData {
  final String division;
  final List<Holiday> holidays;
  // final List<int> days;
  final int totalDays;

  MapCountryData(
      {required this.division,
      required this.holidays,
      // required this.days,
      required this.totalDays});
}

class MapCountryDataAndDays {
  List<MapCountryData> data;
  int numSelectedDays;

  MapCountryDataAndDays({required this.data, required this.numSelectedDays});
}

// Provider for consumption
final nutsDataProvider =
    StateNotifierProvider<NutsDataProvider, MapCountryDataAndDays>(
        (ref) => NutsDataProvider());

// State
class NutsDataProvider extends StateNotifier<MapCountryDataAndDays> {
  NutsDataProvider()
      : super(MapCountryDataAndDays(data: [], numSelectedDays: 1));

  Future<void> resetData() async {
    state = (MapCountryDataAndDays(data: [], numSelectedDays: 1));
  }

  // Future<void> updateSingleID(String id) async {
  //   if (id == "") return;
  //   int i = state.properties.indexWhere((element) => element['id'] == id);
  //
  //
  //   state.properties[i]['color'] = Colors.deepPurple;
  //   state.keyValuesPaires[state.properties[i]['id']] =
  //       state.properties[i]['color'];
  //   state = MapCountryData(
  //       country: state.country,
  //       instruction: state.instruction,
  //       properties: state.properties,
  //       keyValuesPaires: state.keyValuesPaires);
  // }

  // Future<void> updateMultipleIDs(List<String> ids) async {
  Future<void> updateMultipleIDs(
      List<List<CodeAndHoliday>> entries, int days) async {
    List<MapCountryData> data = [];
    for (final nutsEntry in entries) {
      List<Holiday> foundHolidays = [];
      List<DateTime> foundDays = [];
      String nutsCode = '';
      for (final n in nutsEntry) {
        foundHolidays.add(n.holiday);
        foundDays = foundDays + n.dayList;
        nutsCode = n.nutsCode;
      }
      // Remove duplicate dates and get total amount
      int totalDays = foundDays.toSet().length;

      data.add(MapCountryData(
          division: nutsCode,
          holidays: foundHolidays,
          // days: foundDays,
          totalDays: totalDays));
    }
    state = MapCountryDataAndDays(data: data, numSelectedDays: days);
  }
}

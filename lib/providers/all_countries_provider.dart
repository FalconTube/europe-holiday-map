import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/main.dart';

class MapCountryData {
  final String division;
  final String holiday;
  final int days;

  MapCountryData(
      {required this.division, required this.holiday, required this.days});
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
  Future<void> updateMultipleIDs(List<CodeAndHoliday> entries, int days) async {
    List<MapCountryData> data = [];
    for (final e in entries) {
      data.add(MapCountryData(
          division: e.nutsCode, holiday: e.holiday, days: e.days));
    }
    state = MapCountryDataAndDays(data: data, numSelectedDays: days);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/classes/entry.dart';
import 'package:holiday_map/classes/internal.dart';

/// Every holiday has a number of days attached to it
class MapCountryData {
  final String nuts;
  final String division;
  final List<Holiday> holidays;
  final List<DateTime> days;
  final int totalDays;

  MapCountryData(
      {required this.nuts,
      required this.division,
      required this.holidays,
      required this.days,
      required this.totalDays});
}

class MapCountryDataAndDays {
  List<MapCountryData> data;
  int numSelectedDays;

  MapCountryDataAndDays({required this.data, required this.numSelectedDays});
}

// Provider for consumption
final selectedCountryDataProvider =
    StateNotifierProvider<SelectedCountryDataProvider, MapCountryData?>(
        (ref) => SelectedCountryDataProvider());

class SelectedCountryDataProvider extends StateNotifier<MapCountryData?> {
  SelectedCountryDataProvider() : super(null);

  Future<void> resetData() async {
    state = (null);
  }

  Future<void> setData(MapCountryData data) async {
    state = data;
  }
}

// Provider for consumption
final nutsDataProvider =
    StateNotifierProvider<NutsDataProvider, MapCountryDataAndDays>(
        (ref) => NutsDataProvider());

// State
class NutsDataProvider extends StateNotifier<MapCountryDataAndDays> {
  NutsDataProvider()
      : super(MapCountryDataAndDays(data: [], numSelectedDays: 0));

  Future<void> resetData() async {
    state = (MapCountryDataAndDays(data: [], numSelectedDays: 0));
  }

  Future<void> updateMultipleIDs(
      List<List<CodeAndHoliday>> entries, int days) async {
    List<MapCountryData> data = [];
    for (final nutsEntry in entries) {
      List<Holiday> foundHolidays = [];
      List<DateTime> foundDays = [];
      String nutsCode = '';
      String division = '';
      for (final n in nutsEntry) {
        foundHolidays.add(n.holiday);
        foundDays = foundDays + n.dayList;
        nutsCode = n.nutsCode;
        division = n.division;
      }
      // Remove duplicate dates and get total amount
      final foundDaysUnique = foundDays.toSet().toList();
      int totalDays = foundDaysUnique.length;

      data.add(MapCountryData(
          division: division,
          nuts: nutsCode,
          holidays: foundHolidays,
          days: foundDaysUnique,
          totalDays: totalDays));
    }
    state = MapCountryDataAndDays(data: data, numSelectedDays: days);
  }
}

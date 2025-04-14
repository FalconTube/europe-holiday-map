import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';

final selectedDatesProvider =
    StateNotifierProvider<SelectedDatesProvider, DateTimeRange?>(
        (ref) => SelectedDatesProvider());

// State
class SelectedDatesProvider extends StateNotifier<DateTimeRange?> {
  SelectedDatesProvider() : super(null);

  Future<void> update(DateTimeRange dates) async {
    state = dates;
  }
}

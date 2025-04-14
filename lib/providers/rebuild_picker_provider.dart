import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

final keyProvider =
    StateNotifierProvider<KeyProvider, Key>((ref) => KeyProvider());

// State
class KeyProvider extends StateNotifier<Key> {
  KeyProvider() : super(UniqueKey());

  Future<void> reset() async {
    state = UniqueKey();
  }
}

final controllerProvider =
    StateNotifierProvider<ControllerProvider, DateRangePickerController>(
        (ref) => ControllerProvider());

// State
class ControllerProvider extends StateNotifier<DateRangePickerController> {
  ControllerProvider() : super(DateRangePickerController());

  Future<void> reset() async {
    state = DateRangePickerController();
  }
}

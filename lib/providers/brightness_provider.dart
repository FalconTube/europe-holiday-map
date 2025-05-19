import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';

final brightnessProvider =
    StateNotifierProvider<BrightnessProvider, Brightness>(
        (ref) => BrightnessProvider());

// State
class BrightnessProvider extends StateNotifier<Brightness> {
  BrightnessProvider() : super(Brightness.light);

  Future<void> switchBrightness() async {
    if (state == Brightness.light) {
      state = Brightness.dark;
    } else {
      state = Brightness.light;
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_map/main.dart';

import 'package:flutter/material.dart';

final keyProvider =
    StateNotifierProvider<KeyProvider, Key>((ref) => KeyProvider());

// State
class KeyProvider extends StateNotifier<Key> {
  KeyProvider() : super(UniqueKey());

  Future<void> updateKey() async {
    state = UniqueKey();
  }
}

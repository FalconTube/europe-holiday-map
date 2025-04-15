import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedMapIndexProvider =
    StateNotifierProvider<SelectedMapNutsProvider, String?>(
        (ref) => SelectedMapNutsProvider());

// State
class SelectedMapNutsProvider extends StateNotifier<String?> {
  SelectedMapNutsProvider() : super(null);

  Future<void> update(String code) async {
    state = code;
  }

  Future<void> reset() async {
    state = null;
  }
}

import 'package:adminshahrayar/models/driver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DriversNotifier extends StateNotifier<List<Driver>> {
  DriversNotifier() : super([]) {
    _fetchDrivers();
  }

  void _fetchDrivers() {
    state = mockDrivers;
  }
}

final driversProvider =
    StateNotifierProvider<DriversNotifier, List<Driver>>((ref) {
  return DriversNotifier();
});

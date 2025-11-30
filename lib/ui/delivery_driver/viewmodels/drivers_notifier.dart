import 'package:adminshahrayar_stores/data/models/driver.dart';
import 'package:adminshahrayar_stores/data/repositories/driver_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DriversNotifier extends AsyncNotifier<List<Driver>> {
  final DriverRepository _driverRepository = DriverRepository();

  @override
  Future<List<Driver>> build() async {
    try {
      final drivers = await _driverRepository.getAllDrivers();
      return drivers;
    } catch (_) {
      return mockDrivers;
    }
  }

  Future<void> refreshDrivers() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await build());
  }

  Future<void> updateDriverStatus(String driverId, DriverStatus status) async {
    try {
      await _driverRepository.updateDriverStatus(driverId, status);
      await refreshDrivers(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }

  Future<void> assignDriverToDelivery(String driverId) async {
    try {
      await _driverRepository.assignDriverToDelivery(driverId);
      await refreshDrivers(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }

  Future<void> completeDelivery(String driverId) async {
    try {
      await _driverRepository.completeDelivery(driverId);
      await refreshDrivers(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }
}

final driversProvider =
    AsyncNotifierProvider<DriversNotifier, List<Driver>>(() {
  return DriversNotifier();
});

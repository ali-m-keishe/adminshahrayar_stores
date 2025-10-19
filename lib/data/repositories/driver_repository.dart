import '../models/driver.dart';

class DriverRepository {
  // Get all drivers
  Future<List<Driver>> getAllDrivers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockDrivers;
  }

  // Get driver by ID
  Future<Driver?> getDriverById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return mockDrivers.firstWhere((driver) => driver.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get drivers by status
  Future<List<Driver>> getDriversByStatus(DriverStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockDrivers.where((driver) => driver.status == status).toList();
  }

  // Get available drivers
  Future<List<Driver>> getAvailableDrivers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockDrivers
        .where((driver) => driver.status == DriverStatus.Available)
        .toList();
  }

  // Get drivers on delivery
  Future<List<Driver>> getDriversOnDelivery() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockDrivers
        .where((driver) => driver.status == DriverStatus.OnDelivery)
        .toList();
  }

  // Search drivers by name
  Future<List<Driver>> searchDrivers(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockDrivers
        .where(
            (driver) => driver.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Add new driver
  Future<Driver> addDriver(Driver driver) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // In a real app, this would make an API call to add the driver
    return driver;
  }

  // Update driver
  Future<Driver> updateDriver(Driver driver) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In a real app, this would make an API call to update the driver
    return driver;
  }

  // Update driver status
  Future<Driver> updateDriverStatus(
      String driverId, DriverStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final driver = await getDriverById(driverId);
    if (driver == null) {
      throw Exception('Driver not found');
    }

    final updatedDriver = Driver(
      id: driver.id,
      name: driver.name,
      status: status,
    );

    // In a real app, this would make an API call to update the driver status
    return updatedDriver;
  }

  // Delete driver
  Future<void> deleteDriver(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, this would make an API call to delete the driver
  }

  // Get driver statistics
  Future<Map<DriverStatus, int>> getDriverStatistics() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final statistics = <DriverStatus, int>{};

    for (final driver in mockDrivers) {
      statistics[driver.status] = (statistics[driver.status] ?? 0) + 1;
    }

    return statistics;
  }

  // Assign driver to delivery
  Future<Driver> assignDriverToDelivery(String driverId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return await updateDriverStatus(driverId, DriverStatus.OnDelivery);
  }

  // Complete delivery and make driver available
  Future<Driver> completeDelivery(String driverId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return await updateDriverStatus(driverId, DriverStatus.Available);
  }
}

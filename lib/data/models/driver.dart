enum DriverStatus { Available, OnDelivery, Offline }

class Driver {
  final String id;
  final String name;
  final DriverStatus status;

  Driver({
    required this.id,
    required this.name,
    required this.status,
  });
}

final List<Driver> mockDrivers = [
  Driver(id: 'd1', name: 'David Chen', status: DriverStatus.Available),
  Driver(id: 'd2', name: 'Sarah Kim', status: DriverStatus.OnDelivery),
  Driver(id: 'd3', name: 'Mike Ross', status: DriverStatus.Offline),
];

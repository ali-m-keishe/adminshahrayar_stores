// Using enums makes our code safer and more readable
enum StaffRole { Admin, Chef, Delivery, Cashier }

enum StaffStatus { Active, Inactive }

class StaffMember {
  final String id;
  final String name;
  final StaffRole role;
  final StaffStatus status;

  StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
  });
}

// Mock data to populate our UI
final List<StaffMember> mockStaff = [
  StaffMember(
      id: 's1',
      name: 'Alex Morgan',
      role: StaffRole.Admin,
      status: StaffStatus.Active),
  StaffMember(
      id: 's2',
      name: 'Ben Carter',
      role: StaffRole.Cashier,
      status: StaffStatus.Active),
  StaffMember(
      id: 's3',
      name: 'David Chen',
      role: StaffRole.Delivery,
      status: StaffStatus.Active),
  StaffMember(
      id: 's4',
      name: 'Sarah Kim',
      role: StaffRole.Chef,
      status: StaffStatus.Inactive),
];

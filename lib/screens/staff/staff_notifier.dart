import 'package:adminshahrayar/models/staff_member.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart'; // We'll use a package to generate unique IDs

// You may need to add the uuid package to your pubspec.yaml
// dependencies:
//   uuid: ^4.4.0
// Then run `flutter pub get`

class StaffNotifier extends StateNotifier<List<StaffMember>> {
  StaffNotifier() : super([]) {
    _fetchStaff();
  }

  void _fetchStaff() {
    state = mockStaff;
  }

  void addStaffMember(StaffMember member) {
    state = [...state, member];
  }

  void updateStaffMember(StaffMember updatedMember) {
    state = [
      for (final member in state)
        if (member.id == updatedMember.id) updatedMember else member,
    ];
  }

  void deleteStaffMember(String id) {
    state = state.where((member) => member.id != id).toList();
  }
}

final staffProvider =
    StateNotifierProvider<StaffNotifier, List<StaffMember>>((ref) {
  return StaffNotifier();
});

// A simple provider for the uuid package
final uuidProvider = Provider((ref) => const Uuid());

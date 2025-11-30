import 'package:adminshahrayar_stores/data/models/staff_member.dart';
import 'package:adminshahrayar_stores/data/repositories/staff_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart'; // We'll use a package to generate unique IDs

// You may need to add the uuid package to your pubspec.yaml
// dependencies:
//   uuid: ^4.4.0
// Then run `flutter pub get`

class StaffNotifier extends StateNotifier<List<StaffMember>> {
  final StaffRepository _staffRepository = StaffRepository();

  StaffNotifier() : super([]) {
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    try {
      final staff = await _staffRepository.getAllStaff();
      state = staff;
    } catch (e) {
      // Fallback to mock data if repository fails
      state = mockStaff;
    }
  }

  Future<void> refreshStaff() async {
    await _fetchStaff();
  }

  Future<void> addStaffMember(StaffMember member) async {
    try {
      await _staffRepository.addStaff(member);
      await _fetchStaff(); // Refresh the data
    } catch (e) {
      // Handle error - could show a snackbar or error message
    }
  }

  Future<void> updateStaffMember(StaffMember updatedMember) async {
    try {
      await _staffRepository.updateStaff(updatedMember);
      await _fetchStaff(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteStaffMember(String id) async {
    try {
      await _staffRepository.deleteStaff(id);
      await _fetchStaff(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateStaffRole(String staffId, StaffRole role) async {
    try {
      await _staffRepository.updateStaffRole(staffId, role);
      await _fetchStaff(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }

  Future<void> toggleStaffStatus(String staffId) async {
    try {
      await _staffRepository.toggleStaffStatus(staffId);
      await _fetchStaff(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }
}

final staffProvider =
    StateNotifierProvider<StaffNotifier, List<StaffMember>>((ref) {
  return StaffNotifier();
});

// A simple provider for the uuid package
final uuidProvider = Provider((ref) => const Uuid());

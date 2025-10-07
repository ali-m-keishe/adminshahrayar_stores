import '../models/staff_member.dart';

class StaffRepository {
  // Get all staff members
  Future<List<StaffMember>> getAllStaff() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockStaff;
  }

  // Get staff member by ID
  Future<StaffMember?> getStaffById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return mockStaff.firstWhere((staff) => staff.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get staff by role
  Future<List<StaffMember>> getStaffByRole(StaffRole role) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockStaff.where((staff) => staff.role == role).toList();
  }

  // Get staff by status
  Future<List<StaffMember>> getStaffByStatus(StaffStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockStaff.where((staff) => staff.status == status).toList();
  }

  // Get active staff
  Future<List<StaffMember>> getActiveStaff() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockStaff.where((staff) => staff.status == StaffStatus.Active).toList();
  }

  // Get inactive staff
  Future<List<StaffMember>> getInactiveStaff() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockStaff.where((staff) => staff.status == StaffStatus.Inactive).toList();
  }

  // Get admins
  Future<List<StaffMember>> getAdmins() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockStaff.where((staff) => staff.role == StaffRole.Admin).toList();
  }

  // Get chefs
  Future<List<StaffMember>> getChefs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockStaff.where((staff) => staff.role == StaffRole.Chef).toList();
  }

  // Get delivery staff
  Future<List<StaffMember>> getDeliveryStaff() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockStaff.where((staff) => staff.role == StaffRole.Delivery).toList();
  }

  // Get cashiers
  Future<List<StaffMember>> getCashiers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockStaff.where((staff) => staff.role == StaffRole.Cashier).toList();
  }

  // Search staff by name
  Future<List<StaffMember>> searchStaff(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockStaff
        .where((staff) =>
            staff.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Add new staff member
  Future<StaffMember> addStaff(StaffMember staff) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // In a real app, this would make an API call to add the staff member
    return staff;
  }

  // Update staff member
  Future<StaffMember> updateStaff(StaffMember staff) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In a real app, this would make an API call to update the staff member
    return staff;
  }

  // Update staff role
  Future<StaffMember> updateStaffRole(String staffId, StaffRole role) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final staff = await getStaffById(staffId);
    if (staff == null) {
      throw Exception('Staff member not found');
    }
    
    final updatedStaff = StaffMember(
      id: staff.id,
      name: staff.name,
      role: role,
      status: staff.status,
    );
    
    // In a real app, this would make an API call to update the staff role
    return updatedStaff;
  }

  // Update staff status
  Future<StaffMember> updateStaffStatus(String staffId, StaffStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final staff = await getStaffById(staffId);
    if (staff == null) {
      throw Exception('Staff member not found');
    }
    
    final updatedStaff = StaffMember(
      id: staff.id,
      name: staff.name,
      role: staff.role,
      status: status,
    );
    
    // In a real app, this would make an API call to update the staff status
    return updatedStaff;
  }

  // Activate staff member
  Future<StaffMember> activateStaff(String staffId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return await updateStaffStatus(staffId, StaffStatus.Active);
  }

  // Deactivate staff member
  Future<StaffMember> deactivateStaff(String staffId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return await updateStaffStatus(staffId, StaffStatus.Inactive);
  }

  // Delete staff member
  Future<void> deleteStaff(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, this would make an API call to delete the staff member
  }

  // Get staff by multiple roles
  Future<List<StaffMember>> getStaffByRoles(List<StaffRole> roles) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return mockStaff.where((staff) => roles.contains(staff.role)).toList();
  }

  // Get staff statistics
  Future<Map<String, dynamic>> getStaffStatistics() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final totalStaff = mockStaff.length;
    final activeStaff = mockStaff.where((s) => s.status == StaffStatus.Active).length;
    final inactiveStaff = totalStaff - activeStaff;
    
    final roleCounts = <StaffRole, int>{};
    final statusCounts = <StaffStatus, int>{};
    
    for (final staff in mockStaff) {
      roleCounts[staff.role] = (roleCounts[staff.role] ?? 0) + 1;
      statusCounts[staff.status] = (statusCounts[staff.status] ?? 0) + 1;
    }
    
    return {
      'totalStaff': totalStaff,
      'activeStaff': activeStaff,
      'inactiveStaff': inactiveStaff,
      'roleCounts': roleCounts,
      'statusCounts': statusCounts,
    };
  }

  // Get staff by role and status
  Future<List<StaffMember>> getStaffByRoleAndStatus({
    required StaffRole role,
    required StaffStatus status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockStaff
        .where((staff) => staff.role == role && staff.status == status)
        .toList();
  }

  // Toggle staff status
  Future<StaffMember> toggleStaffStatus(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final staff = await getStaffById(id);
    if (staff == null) {
      throw Exception('Staff member not found');
    }
    
    return staff.status == StaffStatus.Active
        ? await deactivateStaff(id)
        : await activateStaff(id);
  }

  // Get available staff for a specific role
  Future<List<StaffMember>> getAvailableStaffForRole(StaffRole role) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockStaff
        .where((staff) => 
            staff.role == role && staff.status == StaffStatus.Active)
        .toList();
  }
}

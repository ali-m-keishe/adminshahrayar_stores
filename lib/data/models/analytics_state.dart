class AnalyticsState {
  final double totalRevenue;
  final int totalOrders;
  final double avgOrderValue;
  final int customerNumber;
  final List<Map<String, dynamic>> monthlyRevenueData; // Changed from weeklyRevenueData
  
  AnalyticsState({
    required this.totalRevenue,
    required this.totalOrders,
    required this.avgOrderValue,
    required this.customerNumber,
    required this.monthlyRevenueData, // Changed from weeklyRevenueData
  });
  
  AnalyticsState copyWith({
    double? totalRevenue,
    int? totalOrders,
    double? avgOrderValue,
    int? customerNumber,
    List<Map<String, dynamic>>? monthlyRevenueData, // Changed from weeklyRevenueData
  }) {
    return AnalyticsState(
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalOrders: totalOrders ?? this.totalOrders,
      avgOrderValue: avgOrderValue ?? this.avgOrderValue,
      customerNumber: customerNumber ?? this.customerNumber,
      monthlyRevenueData: monthlyRevenueData ?? this.monthlyRevenueData, // Changed from weeklyRevenueData
    );
  }
}
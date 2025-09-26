// A simple helper class to hold the data for our stat cards
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatData {
  final String title;
  final String value;
  final double changePercent;
  final bool isPositive;

  StatData({
    required this.title,
    required this.value,
    required this.changePercent,
    this.isPositive = true,
  });
}

// Defines the state for our Analytics page
class AnalyticsState {
  final List<StatData> stats;
  final Map<String, double> orderTypeData;
  final List<double> weeklyRevenueData;

  AnalyticsState({
    this.stats = const [],
    this.orderTypeData = const {},
    this.weeklyRevenueData = const [],
  });

  AnalyticsState copyWith({
    List<StatData>? stats,
    Map<String, double>? orderTypeData,
    List<double>? weeklyRevenueData,
  }) {
    return AnalyticsState(
      stats: stats ?? this.stats,
      orderTypeData: orderTypeData ?? this.orderTypeData,
      weeklyRevenueData: weeklyRevenueData ?? this.weeklyRevenueData,
    );
  }
}

// The Notifier (ViewModel) that manages the state
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(AnalyticsState()) {
    _fetchData();
  }

  void _fetchData() {
    // In a real application, this data would be fetched from your backend API
    state = state.copyWith(
      stats: [
        StatData(
            title: "Today's Revenue",
            value: "\$1,250",
            changePercent: 15,
            isPositive: true),
        StatData(
            title: "Today's Orders",
            value: "84",
            changePercent: 5,
            isPositive: false),
        StatData(
            title: "Avg. Order Value",
            value: "\$14.89",
            changePercent: 20,
            isPositive: true),
        StatData(title: "Food Cost %", value: "28%", changePercent: 0),
      ],
      orderTypeData: {
        'Delivery': 55,
        'Pickup': 29,
      },
      weeklyRevenueData: [800, 1200, 950, 1500, 1400, 1800, 1250],
    );
  }
}

// The Provider that allows the UI to access the Notifier
final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});

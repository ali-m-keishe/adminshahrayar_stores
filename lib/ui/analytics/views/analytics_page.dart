import 'package:adminshahrayar/ui/analytics/viewmodels/analytics_notifier.dart';
import 'package:adminshahrayar/ui/dashboard/views/stat_card.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get the current state.
    // The UI will automatically update if this data ever changes.
    final state = ref.watch(analyticsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // We are re-using the StatCard widget from the Dashboard.
          const Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              StatCard(
                  title: 'Total Revenue',
                  value: '\$12,450',
                  icon: Icons.monetization_on,
                  color: Colors.green),
              StatCard(
                  title: 'Total Orders',
                  value: '789',
                  icon: Icons.shopping_cart,
                  color: Colors.blue),
              StatCard(
                  title: 'Avg. Order Value',
                  value: '\$14.89',
                  icon: Icons.price_check,
                  color: Colors.orange),
              StatCard(
                  title: 'Customers',
                  value: '450',
                  icon: Icons.people,
                  color: Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          // For responsive layout on different screen sizes.
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                // On smaller screens, stack the charts vertically.
                return Column(
                  children: [
                    _RevenueChart(revenueData: state.weeklyRevenueData),
                    const SizedBox(height: 24),
                    _OrderTypesChart(orderTypeData: state.orderTypeData),
                  ],
                );
              }
              // On larger screens, display them side-by-side.
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _RevenueChart(revenueData: state.weeklyRevenueData),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: _OrderTypesChart(orderTypeData: state.orderTypeData),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// A dedicated widget for the Revenue Line Chart
class _RevenueChart extends StatelessWidget {
  final List<double> revenueData;
  const _RevenueChart({required this.revenueData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenue (Last 7 Days)', style: theme.textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: _bottomTitleWidgets,
                            reservedSize: 30)),
                    leftTitles: const AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: true, reservedSize: 40)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: revenueData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      gradient: LinearGradient(colors: [
                        theme.primaryColor,
                        theme.primaryColor.withOpacity(0.3)
                      ]),
                      barWidth: 5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                              colors: [
                                theme.primaryColor.withOpacity(0.3),
                                Colors.transparent
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
    const dayMap = {
      0: 'Mon',
      1: 'Tue',
      2: 'Wed',
      3: 'Thu',
      4: 'Fri',
      5: 'Sat',
      6: 'Sun'
    };
    return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(dayMap[value.toInt()] ?? '', style: style));
  }
}

// A dedicated widget for the Order Types Pie Chart
class _OrderTypesChart extends StatelessWidget {
  final Map<String, double> orderTypeData;
  const _OrderTypesChart({required this.orderTypeData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = [
      Colors.purple.shade400,
      theme.colorScheme.secondary,
      Colors.orange.shade400
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Types', style: theme.textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: orderTypeData.entries.map((entry) {
                    final index =
                        orderTypeData.keys.toList().indexOf(entry.key);
                    return PieChartSectionData(
                      color: colors[index % colors.length],
                      value: entry.value,
                      title: '${entry.value.toInt()}%',
                      radius: 80,
                      titleStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            ...orderTypeData.entries.map((entry) {
              final index = orderTypeData.keys.toList().indexOf(entry.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(children: [
                  Container(
                      width: 16,
                      height: 16,
                      color: colors[index % colors.length]),
                  const SizedBox(width: 8),
                  Text(entry.key)
                ]),
              );
            }),
          ],
        ),
      ),
    );
  }
}

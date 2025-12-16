import 'package:adminshahrayar_stores/ui/analytics/viewmodels/analytics_viewmodel.dart';
import 'package:adminshahrayar_stores/ui/dashboard/views/stat_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// Test widget to debug revenue data
class RevenueDebugWidget extends ConsumerWidget {
  const RevenueDebugWidget({super.key});

  Future<Map<String, dynamic>> _fetchDebugData() async {
    final supabase = Supabase.instance.client;
    
    try {
      // Fetch all carts with orders
      final cartsResponse = await supabase
          .from('cart')
          .select('''
            cart_id,
            created_at,
            total_price,
            status,
            orders!inner(
              id,
              created_at,
              status
            )
          ''')
          .order('created_at', ascending: false);
      
      final carts = cartsResponse as List<dynamic>;
      
      // Analyze the data
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      double totalRevenue = 0;
      double last30DaysRevenue = 0;
      int totalOrders = carts.length;
      int last30DaysOrders = 0;
      List<Map<String, dynamic>> orderDetails = [];
      Map<String, double> dailyRevenue = {};
      
      for (final cart in carts) {
        final createdAt = DateTime.parse(cart['created_at']);
        final price = (cart['total_price'] as num).toDouble();
        
        totalRevenue += price;
        
        if (createdAt.isAfter(thirtyDaysAgo)) {
          last30DaysRevenue += price;
          last30DaysOrders++;
          
          final dateKey = DateFormat('MM/dd').format(createdAt);
          dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + price;
        }
        
        orderDetails.add({
          'cart_id': cart['cart_id'],
          'date': DateFormat('yyyy-MM-dd HH:mm').format(createdAt),
          'price': price,
          'days_ago': now.difference(createdAt).inDays,
          'in_30_days': createdAt.isAfter(thirtyDaysAgo),
        });
      }
      
      return {
        'total_revenue': totalRevenue,
        'last_30_days_revenue': last30DaysRevenue,
        'total_orders': totalOrders,
        'last_30_days_orders': last30DaysOrders,
        'order_details': orderDetails,
        'daily_revenue': dailyRevenue,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue Debug Information'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchDebugData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError || (snapshot.data?.containsKey('error') ?? false)) {
            return Center(
              child: Text('Error: ${snapshot.error ?? snapshot.data!['error']}'),
            );
          }
          
          final data = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Revenue Summary',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildRow('Total Revenue (All Time)', 
                          '\$${data['total_revenue'].toStringAsFixed(2)}',
                          Colors.green),
                        _buildRow('Last 30 Days Revenue', 
                          '\$${data['last_30_days_revenue'].toStringAsFixed(2)}',
                          Colors.blue),
                        const SizedBox(height: 8),
                        _buildRow('Total Orders', 
                          '${data['total_orders']}',
                          Colors.orange),
                        _buildRow('Last 30 Days Orders', 
                          '${data['last_30_days_orders']}',
                          Colors.purple),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Daily Revenue in Last 30 Days
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daily Revenue (Last 30 Days)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        if ((data['daily_revenue'] as Map).isEmpty)
                          const Text('No revenue in the last 30 days')
                        else
                          ...(data['daily_revenue'] as Map<String, double>)
                              .entries
                              .map((entry) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(entry.key),
                                        Text(
                                          '\$${entry.value.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Order Details
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'All Orders (Newest First)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        ...(data['order_details'] as List<Map<String, dynamic>>)
                            .take(20)  // Show first 20 orders
                            .map((order) => Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Cart #${order['cart_id']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              order['date'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '\$${order['price'].toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: order['in_30_days'] 
                                                ? Colors.green 
                                                : Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            '${order['days_ago']} days ago',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: order['in_30_days']
                                                ? Colors.green[700]
                                                : Colors.red[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add this to a route in your app to test
// Example usage:
// Navigator.push(
//   context,
//   MaterialPageRoute(builder: (context) => const RevenueDebugWidget()),
// );

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  // Slider range: view last 30-day window ending from -365 to +30
  double _offset = 0; // days offset, double to fit Slider API

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsViewmodelProvider);

    return analyticsAsync.when(
      data: (state) {
        final revenueValues = state.monthlyRevenueData
            .map((e) => (e['revenue'] as num).toDouble())
            .toList();

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

              // Stats Cards
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  StatCard(
                      title: 'Total Revenue',
                      value: '\$${state.totalRevenue.toStringAsFixed(2)}',
                      icon: Icons.monetization_on,
                      color: Colors.green),
                  StatCard(
                      title: 'Total Orders',
                      value: '${state.totalOrders}',
                      icon: Icons.shopping_cart,
                      color: Colors.blue),
                  StatCard(
                      title: 'Avg. Order Value',
                      value: '\$${state.avgOrderValue.toStringAsFixed(2)}',
                      icon: Icons.price_check,
                      color: Colors.orange),
                  StatCard(
                      title: 'Customers',
                      value: '${state.customerNumber}',
                      icon: Icons.people,
                      color: Colors.purple),
                ],
              ),

              const SizedBox(height: 24),

              // Revenue Chart
              _RevenueChart(
                revenueData: revenueValues,
                dayLabels: state.monthlyRevenueData
                    .map((e) => e['day'] as String)
                    .toList(),
              ),

              const SizedBox(height: 8),

              // Date window slider
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Move 30-day window'),
                          Text('${_offset.toInt()} days'),
                        ],
                      ),
                      Slider(
                        value: _offset,
                        min: -365,
                        max: 30,
                        divisions: 395,
                        label: _offset.toInt().toString(),
                        onChanged: (v) async {
                          setState(() => _offset = v);
                          await ref.read(analyticsViewmodelProvider.notifier).setDayOffset(_offset.toInt());
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error loading analytics: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

// 📈 Revenue Chart Widget
class _RevenueChart extends StatelessWidget {
  final List<double> revenueData;
  final List<String> dayLabels;

  const _RevenueChart({
    required this.revenueData,
    required this.dayLabels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Find the maximum value for better Y-axis scaling
    // Ensure maxY is never 0 to avoid horizontalInterval being 0
    final maxY = revenueData.isEmpty
        ? 100.0
        : (revenueData.reduce((a, b) => a > b ? a : b) * 1.2).clamp(1.0, double.infinity);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenue (Last 30 Days)', style: theme.textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 29,
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY / 5).clamp(1.0, double.infinity),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (value, meta) =>
                            _bottomTitleWidgets(value, meta, dayLabels),
                        reservedSize: 35,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (maxY / 5).clamp(1.0, double.infinity),
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
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
                      curveSmoothness: 0.3,
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.3),
                        ],
                      ),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor.withOpacity(0.15),
                            theme.primaryColor.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((barSpot) {
                          final xIndex = barSpot.x.toInt().clamp(0, dayLabels.length - 1);
                          final day = (xIndex >= 0 && xIndex < dayLabels.length) ? dayLabels[xIndex] : '';
                          final value = barSpot.y;
                          return LineTooltipItem(
                            '$day\n\$${value.toStringAsFixed(2)}',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomTitleWidgets(
      double value, TitleMeta meta, List<String> dayLabels) {
    const style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 10,
      color: Colors.grey,
    );

    if (value.toInt() != value || value < 0 || value >= dayLabels.length) {
      return const SizedBox.shrink();
    }
    
    if (value.toInt() % 5 != 0 && value != dayLabels.length - 1) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        dayLabels[value.toInt()],
        style: style,
      ),
    );
  }
}


// Helper widget for quick stats
class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for legend items
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
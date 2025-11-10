import 'package:flutter/material.dart';
import '../data/local_storage.dart';
import '../data/intent_model.dart';
import '../utils/app_colors.dart';
import '../utils/insight_rules.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<IntentItem> _items = [];
  bool _loading = true;
  Map<String, double> _categoryTotals = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// ✅ Includes desireLevel multiplier and updates spend totals
  Future<void> _loadData() async {
    final userId = await LocalStorage.getActiveUserId();
    if (userId != null) {
      final intents = await LocalStorage.getIntentsForUser(userId);
      final Map<String, double> totals = {};

      for (var i in intents.where((e) => e.bought)) {
        final amount = i.expectedPrice * i.desireLevel;
        totals[i.priority] = (totals[i.priority] ?? 0) + amount;
      }

      setState(() {
        _items = intents;
        _categoryTotals = totals;
        _loading = false;
      });
    } else {
      setState(() {
        _items = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final persona = InsightRules.personaTag(_items);
    final total = _items
        .where((e) => e.bought)
        .fold(0.0, (sum, e) => sum + (e.expectedPrice * e.desireLevel));
    final insight = InsightRules.quickSummary(_items);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.brightness == Brightness.dark
                  ? [const Color(0xFF0F111C), const Color(0xFF1C1E2A)]
                  : [AppColors.backgroundTop, AppColors.backgroundBottom],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                persona,
                style: theme.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total spent: ₹${total.toStringAsFixed(0)}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 20),

              // 📊 Enhanced Expense Pie Chart
              if (_categoryTotals.isEmpty)
                Center(
                  child: Text(
                    "No purchases yet 🛒",
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: Colors.grey),
                  ),
                )
              else
                SizedBox(
                  height: 280,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                      borderData: FlBorderData(show: false),
                      sections: _categoryTotals.entries
                          .map(
                            (entry) => PieChartSectionData(
                          value: entry.value,
                          title:
                          '₹${entry.value.toStringAsFixed(0)}\n${entry.key}',
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          radius: 100,
                          color: _getCategoryColor(entry.key),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),

              const SizedBox(height: 25),
              Text(
                "Mind Insights 💡",
                style: theme.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.header,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                insight,
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎨 Assign fixed colors to categories for visual distinction
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
        return Colors.greenAccent;
      case 'luxury':
        return Colors.purpleAccent;
      case 'essential':
        return Colors.blueAccent;
      default:
        return Colors.tealAccent;
    }
  }
}

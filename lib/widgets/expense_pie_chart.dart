import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_colors.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> expenses;
  const ExpensePieChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(
          child: Text("No expenses yet 🛍️", style: TextStyle(color: Colors.grey)));
    }

    final total = expenses.values.fold(0.0, (a, b) => a + b);
    final List<PieChartSectionData> sections = [];
    int colorIndex = 0;
    final List<Color> palette = [
      AppColors.accent,
      Colors.orangeAccent,
      Colors.teal,
      Colors.purpleAccent,
      Colors.lightBlueAccent,
      Colors.greenAccent,
    ];

    expenses.forEach((category, value) {
      final percentage = (value / total) * 100;
      sections.add(
        PieChartSectionData(
          color: palette[colorIndex % palette.length],
          value: value,
          title: "${percentage.toStringAsFixed(1)}%",
          radius: 70,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PieChart(PieChartData(
            sections: sections,
            borderData: FlBorderData(show: false),
            centerSpaceRadius: 50,
          )),
        ),
        const SizedBox(height: 12),
        ...expenses.entries.map((e) => Text(
          "• ${e.key}: ₹${e.value.toStringAsFixed(0)}",
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        )),
      ],
    );
  }
}

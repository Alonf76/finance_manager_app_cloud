import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:family_biz_finance/services/analysis_service.dart';

class AnalysisView extends StatelessWidget {
  final List<MonthlyData> monthlyHistory;

  const AnalysisView({super.key, required this.monthlyHistory});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("מגמות פיננסיות",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Line Chart: Income vs Expenses
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: monthlyHistory
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.income))
                        .toList(),
                    color: Colors.green,
                    isCurved: true,
                  ),
                  LineChartBarData(
                    spots: monthlyHistory
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.expenses))
                        .toList(),
                    color: Colors.red,
                    isCurved: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          const Text("הוצאות לפי קטגוריה (חודש נוכחי)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Pie Chart for categories of the most recent month
          if (monthlyHistory.isNotEmpty)
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections:
                      monthlyHistory.last.categoryBreakdown.entries.map((e) {
                    return PieChartSectionData(
                      value: e.value,
                      title: e.key,
                      radius: 60,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      color: Colors.primaries[monthlyHistory
                              .last.categoryBreakdown.keys
                              .toList()
                              .indexOf(e.key) %
                          Colors.primaries.length],
                    );
                  }).toList(),
                ),
              ),
            )
          else
            const Center(child: Text("אין נתונים זמינים לניתוח")),
        ],
      ),
    );
  }
}

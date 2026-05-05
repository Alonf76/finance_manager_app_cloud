// This file should be located in lib/services/analysis_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlyData {
  final DateTime month;
  double income = 0;
  double expenses = 0;
  Map<String, double> categoryBreakdown = {};

  MonthlyData(this.month);
  double get balance => income - expenses;
}

class AnalysisService {
  /// Groups transactions into buckets by Month/Year.
  static List<MonthlyData> groupTransactionsByMonth(
      List<QueryDocumentSnapshot> docs) {
    Map<String, MonthlyData> map = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final DateTime date = (data['date'] as Timestamp).toDate();
      final String key =
          "${date.year}-${date.month.toString().padLeft(2, '0')}";
      final double amount = (data['amount'] as num).toDouble();
      final bool isExpense = data['isExpense'] ?? true;
      final String category = data['category'] ?? 'Other';

      if (!map.containsKey(key)) {
        map[key] = MonthlyData(DateTime(date.year, date.month));
      }

      final monthly = map[key]!;
      if (isExpense) {
        monthly.expenses += amount;
        monthly.categoryBreakdown[category] =
            (monthly.categoryBreakdown[category] ?? 0) + amount;
      } else {
        monthly.income += amount;
      }
    }

    // Return sorted by date
    var sortedList = map.values.toList();
    sortedList.sort((a, b) => a.month.compareTo(b.month));
    return sortedList;
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:family_biz_finance/models/transaction.dart';

class DashboardView extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;
  final List<TransactionModel> transactions;
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;

  const DashboardView({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.transactions,
    required this.onAddIncome,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    final balance = totalIncome - totalExpenses;
    final currencyFormat = NumberFormat.simpleCurrency(name: 'ILS');

    return Column(
      children: [
        // 1. Balance Summary Card
        Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  "Current Balance",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(balance),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Action Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAddIncome,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("Income"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAddExpense,
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text("Expense"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. Detailed Expense List
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Recent Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: t.isExpense
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  child: Icon(
                    t.isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                    color: t.isExpense ? Colors.red : Colors.green,
                  ),
                ),
                title: Text(t.title),
                subtitle: Text(t.category),
                trailing: Text(
                  currencyFormat.format(t.amount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

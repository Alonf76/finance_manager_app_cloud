import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:family_biz_finance/widgets/dashboard_view.dart';
import 'package:family_biz_finance/widgets/analysis_view.dart';
import 'package:family_biz_finance/services/analysis_service.dart';
import 'package:family_biz_finance/widgets/add_transaction_dialog.dart';
import 'package:family_biz_finance/models/transaction.dart';
import 'package:intl/intl.dart';

class FinanceRoot extends StatelessWidget {
  const FinanceRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Biz Finance',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // Support for Hebrew RTL and English
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('he', 'IL'),
        Locale('en', 'US'),
      ],
      home: const FinanceHome(),
    );
  }
}

class FinanceHome extends StatefulWidget {
  const FinanceHome({super.key});

  @override
  State<FinanceHome> createState() => _FinanceHomeState();
}

class _FinanceHomeState extends State<FinanceHome> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ניהול פיננסי משפחתי'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "ראשי"),
              Tab(text: "הוצאות"),
              Tab(text: "הכנסות"),
              Tab(text: "תשלומים"),
              Tab(text: "יעדים"),
              Tab(text: "אנליזה"),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          // Fetching transactions from Firestore
          stream: FirebaseFirestore.instance
              .collection('transactions')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));

            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty &&
                snapshot.connectionState == ConnectionState.active) {
              return _buildEmptyState(context);
            }

            final transactions =
                docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();

            // 1. Calculate Dashboard Totals using functional logic
            final totalIncome = transactions
                .where((t) => !t.isExpense)
                .fold(0.0, (sum, t) => sum + t.amount);
            final totalExpenses = transactions
                .where((t) => t.isExpense)
                .fold(0.0, (sum, t) => sum + t.amount);

            // 2. Process Data for Analysis
            final monthlyHistory = AnalysisService.groupTransactionsByMonth(
              docs,
            );

            return TabBarView(
              children: [
                DashboardView(
                  totalIncome: totalIncome,
                  totalExpenses: totalExpenses,
                  onAddIncome: () => _openTransactionDialog(context, false),
                  onAddExpense: () => _openTransactionDialog(context, true),
                ),
                _buildDetailedList(context,
                    transactions.where((t) => t.isExpense).toList(), true),
                _buildDetailedList(context,
                    transactions.where((t) => !t.isExpense).toList(), false),
                const Center(child: Text("תשלומים (כפי שהיה)")),
                const Center(child: Text("יעדים (כפי שהיה)")),
                AnalysisView(monthlyHistory: monthlyHistory),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailedList(
      BuildContext context, List<TransactionModel> list, bool isExpense) {
    final currencyFormat = NumberFormat.simpleCurrency(name: 'ILS');
    if (list.isEmpty) return const Center(child: Text("אין נתונים להצגה"));

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final t = list[index];
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
          subtitle: Text(
              DateFormat('dd/MM/yyyy').format(t.date) + " - " + t.category),
          trailing: Text(
            currencyFormat.format(t.amount),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("No transactions yet",
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () => _openTransactionDialog(context, false),
                  child: const Text("Add Income")),
              const SizedBox(width: 12),
              ElevatedButton(
                  onPressed: () => _openTransactionDialog(context, true),
                  child: const Text("Add Expense")),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _openTransactionDialog(
    BuildContext context,
    bool isExpense,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddTransactionDialog(isExpense: isExpense),
    );

    if (result != null) {
      try {
        await FirebaseFirestore.instance.collection('transactions').add({
          'title': result['title'],
          'amount': result['amount'],
          'date': Timestamp.fromDate(result['date']),
          'category': result['category'],
          'isExpense': result['isExpense'],
          // Add any other fields like userId, workspaceId if applicable
          // For now, we're assuming a single workspace/user context.
          'timestamp':
              FieldValue.serverTimestamp(), // Good practice for creation time
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${isExpense ? 'Expense' : 'Income'} added successfully!',
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add transaction: $e')),
        );
      }
    }
  }
}

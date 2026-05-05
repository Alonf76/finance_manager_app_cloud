import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'widgets/dashboard_view.dart';
import 'widgets/analysis_view.dart';
import 'services/analysis_service.dart';
import 'widgets/add_transaction_dialog.dart'; // Import the new dialog
import 'models/transaction.dart';

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
      supportedLocales: const [Locale('he', 'IL'), Locale('en', 'US')],
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
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Family Biz Finance'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.account_balance_wallet), text: "Balance"),
              Tab(icon: Icon(Icons.analytics), text: "Analysis"),
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
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
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
                  transactions: transactions,
                  onAddIncome: () => _openTransactionDialog(context, false),
                  onAddExpense: () => _openTransactionDialog(context, true),
                ),
                AnalysisView(monthlyHistory: monthlyHistory),
              ],
            );
          },
        ),
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

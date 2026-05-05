import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'widgets/dashboard_view.dart';
import 'widgets/analysis_view.dart';
import 'services/analysis_service.dart';

class FinanceRoot extends StatelessWidget {
  const FinanceRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Biz Finance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
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

            // 1. Calculate Dashboard Totals
            double totalIncome = 0;
            double totalExpenses = 0;
            List<Map<String, dynamic>> transactionList = [];

            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final amount = (data['amount'] as num).toDouble();
              final isExpense = data['isExpense'] ?? true;

              if (isExpense) {
                totalExpenses += amount;
              } else {
                totalIncome += amount;
              }
              transactionList.add({...data, 'id': doc.id});
            }

            // 2. Process Data for Analysis
            final monthlyHistory =
                AnalysisService.groupTransactionsByMonth(docs);

            return TabBarView(
              children: [
                DashboardView(
                  totalIncome: totalIncome,
                  totalExpenses: totalExpenses,
                  transactions: transactionList,
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

  void _openTransactionDialog(BuildContext context, bool isExpense) {
    // Placeholder for your transaction entry logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Opening Add ${isExpense ? 'Expense' : 'Income'} Dialog...')),
    );
  }
}

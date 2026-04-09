import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const FinanceApp());

enum WorkspaceType { family, business }

// --- מודל הנתונים ---
class TransactionRecord {
  final String title;
  final double totalAmount;
  final String category;
  final WorkspaceType workspace;
  final DateTime date;
  final int installments;

  TransactionRecord({
    required this.title,
    required this.totalAmount,
    required this.category,
    required this.workspace,
    required this.date,
    this.installments = 1,
  });

  // המרה ל-JSON לצורך שמירה בזיכרון
  Map<String, dynamic> toJson() => {
    'title': title,
    'totalAmount': totalAmount,
    'category': category,
    'workspace': workspace.index,
    'date': date.toIso8601String(),
    'installments': installments,
  };

  // יצירה מתוך JSON בטעינה
  factory TransactionRecord.fromJson(Map<String, dynamic> json) =>
      TransactionRecord(
        title: json['title'],
        totalAmount: json['totalAmount'],
        category: json['category'],
        workspace: WorkspaceType.values[json['workspace']],
        date: DateTime.parse(json['date']),
        installments: json['installments'] ?? 1,
      );

  // חישוב מספר התשלום הנוכחי ביחס למחזור ה-10 לחודש
  int getCurrentInstallmentNumber(DateTime cycleStart) {
    if (installments <= 1) return 1;
    int monthsSinceStart =
        ((cycleStart.year - date.year) * 12) + cycleStart.month - date.month;
    if (date.day < 10) monthsSinceStart++;
    return monthsSinceStart + 1;
  }

  // חישוב הסכום שיורד במחזור ספציפי
  double getAmountForMonth(DateTime cycleStart) {
    if (installments <= 1) {
      DateTime cycleEnd = DateTime(
        cycleStart.year,
        cycleStart.month + 1,
        cycleStart.day,
      ).subtract(const Duration(seconds: 1));
      if (date.isAfter(cycleStart.subtract(const Duration(seconds: 1))) &&
          date.isBefore(cycleEnd.add(const Duration(seconds: 1)))) {
        return totalAmount;
      }
      return 0;
    }
    int instNumber = getCurrentInstallmentNumber(cycleStart);
    if (instNumber >= 1 && instNumber <= installments)
      return totalAmount / installments;
    return 0;
  }
}

// --- האפליקציה הראשית ---
class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('he', 'IL')],
      locale: const Locale('he', 'IL'),
      theme: ThemeData(useMaterial3: true),
      home: const MainWrapper(),
    );
  }
}

// --- המעטפת הלוגית (ניהול מצב) ---
class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  WorkspaceType _currentWorkspace = WorkspaceType.family;
  List<TransactionRecord> _allTransactions = [];

  // רשימות קטגוריות התחלתיות (יוחלפו במידע מה-SharedPrefs)
  List<String> _familyCats = [
    "מזון ומכולת",
    "רכב",
    "ביטוחים",
    "חשמל/מים/גז",
    "תקשורת",
    "חינוך ופנאי",
    "קוסמטיקה",
  ];
  List<String> _businessCats = ["שיווק", "ספקים", "משרד"];

  @override
  void initState() {
    super.initState();
    _loadData(); // טעינה אוטומטית בפתיחה
  }

  // שמירה לדיסק
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String txJson = jsonEncode(
      _allTransactions.map((tx) => tx.toJson()).toList(),
    );
    await prefs.setString('tx_store', txJson);
    await prefs.setStringList('f_cats_store', _familyCats);
    await prefs.setStringList('b_cats_store', _businessCats);
  }

  // טעינה מהדיסק
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? txJson = prefs.getString('tx_store');
    if (txJson != null) {
      final List<dynamic> decoded = jsonDecode(txJson);
      setState(() {
        _allTransactions = decoded
            .map((item) => TransactionRecord.fromJson(item))
            .toList();
      });
    }
    final List<String>? fCats = prefs.getStringList('f_cats_store');
    final List<String>? bCats = prefs.getStringList('b_cats_store');
    if (fCats != null) setState(() => _familyCats = fCats);
    if (bCats != null) setState(() => _businessCats = bCats);
  }

  DateTime _getStartOfCurrentCycle() {
    DateTime now = DateTime.now();
    return now.day >= 10
        ? DateTime(now.year, now.month, 10)
        : DateTime(now.year, now.month - 1, 10);
  }

  @override
  Widget build(BuildContext context) {
    final startOfCycle = _getStartOfCurrentCycle();
    final isFamily = _currentWorkspace == WorkspaceType.family;
    final primaryColor = isFamily ? Colors.teal : Colors.indigo.shade900;

    double totalSpent = 0;
    List<Map<String, dynamic>> displayList = [];

    for (var tx in _allTransactions.where(
      (t) => t.workspace == _currentWorkspace,
    )) {
      double amountThisMonth = tx.getAmountForMonth(startOfCycle);
      if (amountThisMonth > 0) {
        totalSpent += amountThisMonth;
        displayList.add({
          'tx': tx,
          'amount': amountThisMonth,
          'instIdx': tx.getCurrentInstallmentNumber(startOfCycle),
        });
      }
    }

    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
        ),
      ),
      child: HomeScreen(
        currentWorkspace: _currentWorkspace,
        familyCats: _familyCats,
        businessCats: _businessCats,
        onWorkspaceChanged: (v) => setState(
          () => _currentWorkspace = v
              ? WorkspaceType.business
              : WorkspaceType.family,
        ),
        displayList: displayList,
        onAddTransaction: (tx) {
          setState(() => _allTransactions.add(tx));
          _saveData();
        },
        onAddCategory: (newCat) {
          setState(() {
            if (isFamily) {
              if (!_familyCats.contains(newCat)) _familyCats.add(newCat);
            } else {
              if (!_businessCats.contains(newCat)) _businessCats.add(newCat);
            }
          });
          _saveData();
        },
        totalSpent: totalSpent,
        cycleName: DateFormat('MMMM yyyy', 'he_IL').format(startOfCycle),
      ),
    );
  }
}

// --- ממשק המשתמש ---
class HomeScreen extends StatelessWidget {
  final WorkspaceType currentWorkspace;
  final List<String> familyCats;
  final List<String> businessCats;
  final Function(bool) onWorkspaceChanged;
  final List<Map<String, dynamic>> displayList;
  final Function(TransactionRecord) onAddTransaction;
  final Function(String) onAddCategory;
  final double totalSpent;
  final String cycleName;

  const HomeScreen({
    super.key,
    required this.currentWorkspace,
    required this.familyCats,
    required this.businessCats,
    required this.onWorkspaceChanged,
    required this.displayList,
    required this.onAddTransaction,
    required this.onAddCategory,
    required this.totalSpent,
    required this.cycleName,
  });

  void _showAddSheet(BuildContext context) {
    final amountCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final instCtrl = TextEditingController(text: "1");
    final customCatCtrl = TextEditingController();
    String? selectedCat;
    bool isCustomCat = false;

    final List<String> currentCats = [
      ...(currentWorkspace == WorkspaceType.family ? familyCats : businessCats),
      "אחר...",
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "הוצאה חדשה",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: amountCtrl,
                decoration: const InputDecoration(
                  labelText: "סכום כולל",
                  prefixText: "₪ ",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: "תיאור (למשל: מקרר)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                items: currentCats
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setModalState(() {
                  selectedCat = v;
                  isCustomCat = (v == "אחר...");
                }),
                decoration: const InputDecoration(
                  labelText: "קטגוריה",
                  border: OutlineInputBorder(),
                ),
              ),
              if (isCustomCat) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: customCatCtrl,
                  decoration: const InputDecoration(
                    labelText: "שם קטגוריה חדשה",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: instCtrl,
                decoration: const InputDecoration(
                  labelText: "מספר תשלומים",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentWorkspace == WorkspaceType.family
                        ? Colors.teal
                        : Colors.indigo.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    if (amountCtrl.text.isEmpty || selectedCat == null) return;
                    String finalCat = isCustomCat
                        ? customCatCtrl.text
                        : selectedCat!;
                    if (isCustomCat) onAddCategory(finalCat);

                    onAddTransaction(
                      TransactionRecord(
                        title: titleCtrl.text,
                        totalAmount: double.parse(amountCtrl.text),
                        category: finalCat,
                        workspace: currentWorkspace,
                        date: DateTime.now(),
                        installments: int.tryParse(instCtrl.text) ?? 1,
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text("שמור תנועה"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFamily = currentWorkspace == WorkspaceType.family;
    final color = isFamily ? Colors.teal : Colors.indigo.shade900;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Text(isFamily ? 'כלכלת משפחה' : 'ניהול עסק'),
        actions: [
          const Text("עסק", style: TextStyle(fontSize: 12)),
          Switch(
            value: isFamily,
            onChanged: (v) => onWorkspaceChanged(!v),
            activeColor: Colors.white,
          ),
          const Text("משפחה", style: TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  "סיכום $cycleName",
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "₪${totalSpent.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: color,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "(מחזור ה-10 לחודש)",
                  style: TextStyle(color: color.withOpacity(0.5), fontSize: 11),
                ),
              ],
            ),
          ),
          Expanded(
            child: displayList.isEmpty
                ? const Center(
                    child: Text(
                      "אין תנועות במחזור זה",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: displayList.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (ctx, i) {
                      final tx = displayList[i]['tx'] as TransactionRecord;
                      final amount = displayList[i]['amount'] as double;
                      final instIdx = displayList[i]['instIdx'] as int;
                      return Card(
                        elevation: 0,
                        color: Colors.grey[100],
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.1),
                            child: Icon(Icons.payment, color: color, size: 20),
                          ),
                          title: Text(
                            tx.title.isEmpty ? tx.category : tx.title,
                          ),
                          subtitle: Text(
                            "${tx.category} ${tx.installments > 1 ? '($instIdx/${tx.installments})' : ''}",
                          ),
                          trailing: Text(
                            "₪${amount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        backgroundColor: color,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

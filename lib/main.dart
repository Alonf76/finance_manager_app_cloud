import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FinanceApp());
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Family Finance',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('he', 'IL')],
      locale: const Locale('he', 'IL'),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        fontFamily: 'Roboto',
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        if (snapshot.hasData) return const WorkspaceSelector();
        return const LoginScreen();
      },
    );
  }
}

// --- מסכי כניסה ובחירה ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLogin = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: Colors.teal,
              ),
              const SizedBox(height: 20),
              Text(
                _isLogin ? "כניסה" : "הרשמה",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: "אימייל",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "סיסמה",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      if (_isLogin) {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: _email.text.trim(),
                          password: _pass.text.trim(),
                        );
                      } else {
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                              email: _email.text.trim(),
                              password: _pass.text.trim(),
                            );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("שגיאה: ${e.toString()}")),
                      );
                    }
                  },
                  child: Text(_isLogin ? "כניסה" : "הרשמה"),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? "צור חשבון" : "התחבר"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkspaceSelector extends StatelessWidget {
  const WorkspaceSelector({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("החשבונות שלי"),
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('workspaces')
            .where('members', arrayContains: user.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          return Column(
            children: [
              if (docs.isEmpty)
                const Expanded(
                  child: Center(child: Text("אין חשבונות פעילים")),
                ),
              if (docs.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) => Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const Icon(Icons.group, color: Colors.teal),
                        title: Text(docs[i]['name']),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => MainFinanceScreen(
                              wsId: docs[i].id,
                              wsName: docs[i]['name'],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: ElevatedButton.icon(
                  onPressed: () => _showCreate(context),
                  icon: const Icon(Icons.add),
                  label: const Text("צור חשבון משפחתי חדש"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCreate(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("שם החשבון"),
        content: TextField(controller: ctrl),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('workspaces').add({
                'name': ctrl.text,
                'members': [FirebaseAuth.instance.currentUser!.email],
                'billingDay': 10,
                'customCategories': [
                  'מכולת ומזון',
                  'דיור',
                  'רכב',
                  'בריאות',
                  'פנאי',
                  'אחר',
                ],
                'targets': {},
              });
              Navigator.pop(ctx);
            },
            child: const Text("צור"),
          ),
        ],
      ),
    );
  }
}

// --- מסך ראשי 5.2 ---
class MainFinanceScreen extends StatefulWidget {
  final String wsId;
  final String wsName;
  const MainFinanceScreen({
    super.key,
    required this.wsId,
    required this.wsName,
  });

  @override
  State<MainFinanceScreen> createState() => _MainFinanceScreenState();
}

class _MainFinanceScreenState extends State<MainFinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  dynamic getSafeField(
    DocumentSnapshot doc,
    String field,
    dynamic defaultValue,
  ) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey(field)) return defaultValue;
      return data[field];
    } catch (e) {
      return defaultValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('workspaces')
          .doc(widget.wsId)
          .snapshots(),
      builder: (context, wsSnap) {
        if (!wsSnap.hasData)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );

        const defaultCats = [
          'מכולת ומזון',
          'דיור',
          'רכב',
          'בריאות',
          'פנאי',
          'אחר',
        ];

        int billingDay = getSafeField(wsSnap.data!, 'billingDay', 10);
        List<String> cats = List<String>.from(
          getSafeField(wsSnap.data!, 'customCategories', []),
        );
        if (cats.isEmpty) {
          cats = List<String>.from(defaultCats);
        } else {
          // Ensure the initial category set always exists in UI (incl. 'אחר').
          for (final c in defaultCats) {
            if (!cats.contains(c)) cats.add(c);
          }
        }

        Map<String, dynamic> targets = {};
        try {
          var raw = wsSnap.data!.get('targets');
          if (raw is Map) targets = Map<String, dynamic>.from(raw);
        } catch (e) {}

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.wsName),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: "הוצאות"),
                Tab(text: "הכנסות"),
                Tab(text: "תשלומים"),
                Tab(text: "יעדים"),
              ],
            ),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('workspaces')
                .doc(widget.wsId)
                .collection('transactions')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              DateTime now = DateTime.now();
              DateTime cycleStart = now.day >= billingDay
                  ? DateTime(now.year, now.month, billingDay)
                  : DateTime(now.year, now.month - 1, billingDay);
              DateTime cycleEnd = DateTime(
                cycleStart.year,
                cycleStart.month + 1,
                billingDay,
              );

              final allDocs = snapshot.data!.docs;
              final currentDocs = allDocs.where((d) {
                DateTime dDate = (d['date'] as Timestamp).toDate();
                return dDate.isAfter(
                      cycleStart.subtract(const Duration(seconds: 1)),
                    ) &&
                    dDate.isBefore(cycleEnd);
              }).toList();

              double totalExp = 0, totalInc = 0;
              Map<String, List<DocumentSnapshot>> expByCat = {};
              List<DocumentSnapshot> incDocs = [];

              for (var d in currentDocs) {
                double a = (d['amount'] ?? 0).toDouble();
                if (getSafeField(d, 'isExpense', true)) {
                  totalExp += a;
                  String c = getSafeField(d, 'category', 'אחר');
                  expByCat.putIfAbsent(c, () => []).add(d);
                } else {
                  totalInc += a;
                  incDocs.add(d);
                }
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  // 1. הוצאות עם סנכרון יעדים חי
                  Column(
                    children: [
                      _buildBalanceHeader(
                        totalInc,
                        totalExp,
                        cycleStart,
                        cycleEnd,
                      ),
                      Expanded(
                        child: ListView(
                          children: cats.map((cat) {
                            final catDocs = expByCat[cat] ?? <DocumentSnapshot>[];
                            final catTarget = (targets[cat] ?? 0).toDouble();
                            final catSpent = catDocs.fold<double>(
                              0.0,
                              (sum, doc) =>
                                  sum + ((doc['amount'] ?? 0) as num).toDouble(),
                            );
                            final remaining = catTarget - catSpent;
                            final labelColor =
                                remaining >= 0 ? Colors.teal : Colors.red;
                            final statusText = remaining >= 0
                                ? "נשאר: ₪${remaining.toStringAsFixed(0)}"
                                : "חריגה: ₪${remaining.abs().toStringAsFixed(0)}";

                            return Column(
                              key: ValueKey(cat + catTarget.toString()),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  color: Colors.teal.withOpacity(0.05),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$cat ($statusText)',
                                        style: TextStyle(
                                          color: labelColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "₪${catSpent.toStringAsFixed(0)} / ₪${catTarget.toStringAsFixed(0)}",
                                            style: TextStyle(
                                              color: labelColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                ...catDocs.map((d) => _buildTxTile(d)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  // 2. הכנסות
                  ListView(
                    children: incDocs.map((d) => _buildTxTile(d)).toList(),
                  ),
                  // 3. תשלומים
                  _buildInstallmentsTab(allDocs),
                  // 4. יעדים - מתעדכן אוטומטית מקטגוריות
                  _buildTargetsTab(targets, cats),
                ],
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAdd(context, cats),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildTargetsTab(Map<String, dynamic> targets, List<String> cats) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: cats.map((cat) {
        final ctrl = TextEditingController(
          text: (targets[cat] ?? "").toString(),
        );
        return ListTile(
          key: ValueKey("target_$cat"),
          title: Text(cat),
          trailing: SizedBox(
            width: 100,
            child: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "0", prefixText: "₪"),
              onChanged: (val) {
                FirebaseFirestore.instance
                    .collection('workspaces')
                    .doc(widget.wsId)
                    .update({'targets.$cat': double.tryParse(val) ?? 0});
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInstallmentsTab(List<DocumentSnapshot> allDocs) {
    Map<String, List<DocumentSnapshot>> groups = {};
    for (var d in allDocs) {
      String? gId = getSafeField(d, 'groupId', null);
      if (gId != null) groups.putIfAbsent(gId, () => []).add(d);
    }
    return ListView(
      children: groups.keys.map((gId) {
        var group = groups[gId]!;
        group.sort(
          (a, b) => (a['date'] as Timestamp).compareTo(b['date'] as Timestamp),
        );
        int total = group.length;
        int current = group
            .where(
              (d) => (d['date'] as Timestamp).toDate().isBefore(DateTime.now()),
            )
            .length;
        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            title: Text(group.first['title'].toString().split('(')[0]),
            subtitle: Text("תשלום $current מתוך $total"),
            trailing: IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: () => _deleteSeries(group),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _deleteSeries(List<DocumentSnapshot> group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("מחיקת סדרה"),
        content: const Text("האם למחוק את כל התשלומים?"),
        actions: [
          ElevatedButton(
            onPressed: () async {
              for (var d in group) await d.reference.delete();
              Navigator.pop(ctx);
            },
            child: const Text("מחק הכל"),
          ),
        ],
      ),
    );
  }

  Widget _buildTxTile(DocumentSnapshot d) {
    bool isExp = getSafeField(d, 'isExpense', true);
    return ListTile(
      leading: Icon(
        isExp ? Icons.remove_circle : Icons.add_circle,
        color: isExp ? Colors.red : Colors.green,
      ),
      title: Text(d['title']),
      trailing: Text(
        "₪${d['amount'].toStringAsFixed(0)}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isExp ? Colors.red : Colors.green,
        ),
      ),
      onLongPress: () => _editSingle(d),
    );
  }

  void _editSingle(DocumentSnapshot doc) {
    final title = TextEditingController(text: doc['title']);
    final amt = TextEditingController(text: doc['amount'].toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("עריכה"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: title),
            TextField(controller: amt, keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => doc.reference
                .update({'title': title.text, 'amount': double.parse(amt.text)})
                .then((_) => Navigator.pop(ctx)),
            child: const Text("עדכן"),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceHeader(
    double inc,
    double exp,
    DateTime start,
    DateTime end,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.teal.shade50,
      child: Column(
        children: [
          Text(
            "סבב: ${DateFormat('dd/MM').format(start)} - ${DateFormat('dd/MM').format(end)}",
            style: const TextStyle(fontSize: 12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "הכנסות: ₪${inc.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "הוצאות: ₪${exp.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (inc + exp) == 0 ? 0.5 : inc / (inc + exp),
            minHeight: 6,
            color: Colors.green,
            backgroundColor: Colors.red.shade200,
          ),
          const SizedBox(height: 5),
          Text(
            "יתרה: ₪${(inc - exp).toStringAsFixed(0)}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showAdd(BuildContext context, List<String> cats) {
    final List<String> workingCats = List<String>.from(cats);
    final title = TextEditingController();
    final amt = TextEditingController();
    final inst = TextEditingController(text: "1");
    final newCatCtrl = TextEditingController();
    String cat = workingCats.contains("מכולת ומזון")
        ? "מכולת ומזון"
        : workingCats.first;
    bool isExp = true;
    bool isAddingNewCat = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("הכנסה"),
                  Switch(
                    value: isExp,
                    onChanged: (v) => setS(() => isExp = v),
                    activeColor: Colors.red,
                    inactiveThumbColor: Colors.green,
                  ),
                  const Text("הוצאה"),
                ],
              ),
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: "תיאור"),
              ),
              TextField(
                controller: amt,
                decoration: const InputDecoration(labelText: "סכום כולל"),
                keyboardType: TextInputType.number,
              ),
              if (isExp)
                TextField(
                  controller: inst,
                  decoration: const InputDecoration(labelText: "תשלומים"),
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: 10),
              if (!isAddingNewCat)
                DropdownButtonFormField<String>(
                  value: cat,
                  items: workingCats
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    if (v == "אחר")
                      setS(() => isAddingNewCat = true);
                    else
                      setS(() => cat = v!);
                  },
                  decoration: const InputDecoration(labelText: "קטגוריה"),
                )
              else
                TextField(
                  controller: newCatCtrl,
                  decoration: InputDecoration(
                    labelText: "שם קטגוריה חדשה",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () async {
                        final trimmed = newCatCtrl.text.trim();
                        if (trimmed.isEmpty || trimmed == "אחר") return;

                        // Optimistic UI update so the new category appears immediately.
                        setS(() {
                          if (!workingCats.contains(trimmed)) {
                            final otherIndex = workingCats.indexOf('אחר');
                            if (otherIndex >= 0) {
                              workingCats.insert(otherIndex, trimmed);
                            } else {
                              workingCats.add(trimmed);
                            }
                          }
                          cat = trimmed;
                          isAddingNewCat = false;
                        });

                        try {
                          await FirebaseFirestore.instance
                              .collection('workspaces')
                              .doc(widget.wsId)
                              .update({
                            'customCategories':
                                FieldValue.arrayUnion([trimmed]),
                            // Ensure the Targets tab immediately has a row to edit.
                            'targets.$trimmed': 0,
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('שגיאה בשמירת קטגוריה: ${e.toString()}'),
                            ),
                          );
                        }

                        newCatCtrl.clear();
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isExp ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    int count = int.tryParse(inst.text) ?? 1;
                    double total = double.tryParse(amt.text) ?? 0;
                    String gId = DateTime.now().millisecondsSinceEpoch
                        .toString();
                    for (int i = 0; i < count; i++) {
                      DateTime d = DateTime.now();
                      await FirebaseFirestore.instance
                          .collection('workspaces')
                          .doc(widget.wsId)
                          .collection('transactions')
                          .add({
                            'title': count > 1
                                ? "${title.text} (${i + 1}/$count)"
                                : title.text,
                            'amount': total / count,
                            'isExpense': isExp,
                            'category': cat,
                            'date': DateTime(d.year, d.month + i, d.day),
                            'groupId': gId,
                          });
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text("שמור"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

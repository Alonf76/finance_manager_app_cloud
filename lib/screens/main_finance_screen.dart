import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:family_biz_finance/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app_formatters.dart';
import '../default_categories.dart';
import '../user_profile_repository.dart';
import '../workspace_membership.dart';
import '../workspace_role.dart';
import '../widgets/app_version_display.dart';

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

    // Update Browser Tab Title with version info
    PackageInfo.fromPlatform().then((info) {
      SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
          label: 'Family Biz Finance v${info.version}+${info.buildNumber}',
          primaryColor: Colors.teal.value,
        ),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  dynamic getSafeField(
    DocumentSnapshot<Object?> doc,
    String field,
    dynamic defaultValue,
  ) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey(field)) return defaultValue;
      return data[field];
    } catch (_) {
      return defaultValue;
    }
  }

  Future<void> _openWorkspaceAdminSheet(
    BuildContext context,
    Map<String, dynamic> workspace,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final invite = workspace['inviteCode']?.toString() ?? '';
    final emailCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.workspaceSettings,
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(l10n.inviteCode, style: Theme.of(ctx).textTheme.titleSmall),
              const SizedBox(height: 6),
              SelectableText(invite.isEmpty ? '—' : invite),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: invite.isEmpty
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: invite));
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx)
                            .showSnackBar(SnackBar(content: Text(l10n.copied)));
                      },
                icon: const Icon(Icons.copy),
                label: Text(l10n.copyInviteCode),
              ),
              const SizedBox(height: 16),
              Text(l10n.inviteEmailHint,
                  style: Theme.of(ctx).textTheme.titleSmall),
              const SizedBox(height: 6),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: l10n.email,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  await WorkspaceMembership.inviteByEmail(
                    workspaceId: widget.wsId,
                    email: emailCtrl.text,
                  );
                  if (!ctx.mounted) return;
                  ScaffoldMessenger.of(ctx)
                      .showSnackBar(SnackBar(content: Text(l10n.inviteSent)));
                  emailCtrl.clear();
                },
                child: Text(l10n.sendInvite),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: UserProfileRepository.watch(user.uid),
      builder: (context, userSnap) {
        final userData = userSnap.data?.data();
        final currencyCode = userData?['currencyCode']?.toString() ?? 'ILS';
        final money = AppFormatters.money(context, currencyCode);

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('workspaces')
              .doc(widget.wsId)
              .snapshots(),
          builder: (context, wsSnap) {
            if (!wsSnap.hasData) {
              return const Scaffold(
                body: Stack(
                  children: [
                    Center(child: CircularProgressIndicator()),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(child: AppVersionDisplay()),
                    ),
                  ],
                ),
              );
            }

            final wsData = wsSnap.data!.data() ?? const <String, dynamic>{};
            final role = WorkspaceRole.fromFirestore(wsData, user.uid);

            final defaultCats = defaultWorkspaceCategories(l10n);
            int billingDay = getSafeField(wsSnap.data!, 'billingDay', 10);
            List<String> cats = List<String>.from(
                getSafeField(wsSnap.data!, 'customCategories', <String>[]));
            if (cats.isEmpty) {
              cats = List<String>.from(defaultCats);
            } else {
              for (final c in defaultCats) {
                if (!cats.contains(c)) cats.add(c);
              }
            }

            Map<String, dynamic> targets = {};
            try {
              final raw = wsSnap.data!.get('targets');
              if (raw is Map) targets = Map<String, dynamic>.from(raw);
            } catch (_) {}

            return Scaffold(
              appBar: AppBar(
                title: Text(widget.wsName),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                actions: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Center(child: AppVersionDisplay()),
                  ),
                  if (role == WorkspaceRole.admin)
                    IconButton(
                      tooltip: l10n.workspaceSettings,
                      onPressed: () =>
                          _openWorkspaceAdminSheet(context, wsData),
                      icon: const Icon(Icons.settings),
                    ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: [
                    Tab(text: l10n.tabExpenses),
                    Tab(text: l10n.tabIncome),
                    Tab(text: l10n.tabInstallments),
                    Tab(text: l10n.tabTargets),
                  ],
                ),
              ),
              drawer: Drawer(
                child: SafeArea(
                  child: Column(
                    children: [
                      DrawerHeader(
                        decoration: const BoxDecoration(color: Colors.teal),
                        child: Center(
                          child: Text(widget.wsName,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 24)),
                        ),
                      ),
                      const Spacer(),
                      const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: AppVersionDisplay()),
                    ],
                  ),
                ),
              ),
              body: Column(
                children: [
                  if (!role.canEditLedger)
                    ColoredBox(
                      color: Colors.amber.shade100,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.visibility, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(l10n.readOnlyNotice)),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('workspaces')
                          .doc(widget.wsId)
                          .collection('transactions')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final now = DateTime.now();
                        final cycleStart = now.day >= billingDay
                            ? DateTime(now.year, now.month, billingDay)
                            : DateTime(now.year, now.month - 1, billingDay);
                        final cycleEnd = DateTime(
                          cycleStart.year,
                          cycleStart.month + 1,
                          billingDay,
                        );

                        final allDocs = snapshot.data!.docs;
                        final currentDocs = allDocs.where((d) {
                          final dDate = (d['date'] as Timestamp).toDate();
                          return dDate.isAfter(cycleStart
                                  .subtract(const Duration(seconds: 1))) &&
                              dDate.isBefore(cycleEnd);
                        }).toList();

                        var totalExp = 0.0;
                        var totalInc = 0.0;
                        final expByCat = <String,
                            List<DocumentSnapshot<Map<String, dynamic>>>>{};
                        final incDocs =
                            <DocumentSnapshot<Map<String, dynamic>>>[];

                        for (final d in currentDocs) {
                          final a = (d['amount'] ?? 0).toDouble();
                          if (getSafeField(d, 'isExpense', true)) {
                            totalExp += a;
                            final c = getSafeField(d, 'category', l10n.catOther)
                                .toString();
                            expByCat.putIfAbsent(c, () => []).add(d);
                          } else {
                            totalInc += a;
                            incDocs.add(d);
                          }
                        }

                        return TabBarView(
                          controller: _tabController,
                          children: [
                            Column(
                              children: [
                                _buildBalanceHeader(
                                  context,
                                  l10n,
                                  money,
                                  totalInc,
                                  totalExp,
                                  cycleStart,
                                  cycleEnd,
                                ),
                                Expanded(
                                  child: ListView(
                                    children: cats.map((cat) {
                                      final catDocs = expByCat[cat] ??
                                          const <DocumentSnapshot<
                                              Map<String, dynamic>>>[];
                                      final catTarget =
                                          (targets[cat] ?? 0).toDouble();
                                      final catSpent = catDocs.fold<double>(
                                        0,
                                        (sum, doc) =>
                                            sum +
                                            ((doc['amount'] ?? 0) as num)
                                                .toDouble(),
                                      );
                                      final remaining = catTarget - catSpent;
                                      final labelColor = remaining >= 0
                                          ? Colors.teal
                                          : Colors.red;
                                      final statusText = remaining >= 0
                                          ? l10n.remaining(
                                              money.format(remaining))
                                          : l10n.overBudget(
                                              money.format(remaining.abs()));

                                      return Column(
                                        key: ValueKey('$cat$catTarget'),
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            color:
                                                Colors.teal.withOpacity(0.05),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '$cat ($statusText)',
                                                    style: TextStyle(
                                                      color: labelColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  l10n.spentOfTarget(
                                                    money.format(catSpent),
                                                    money.format(catTarget),
                                                  ),
                                                  style: TextStyle(
                                                    color: labelColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ...catDocs.map((d) => _buildTxTile(
                                              d, role, l10n, money, cats)),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            ListView(
                                children: incDocs
                                    .map((d) => _buildTxTile(
                                        d, role, l10n, money, cats))
                                    .toList()),
                            _buildInstallmentsTab(allDocs, role, l10n),
                            _buildTargetsTab(
                                targets, cats, role, l10n, currencyCode),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              floatingActionButton: role.canEditLedger
                  ? FloatingActionButton(
                      onPressed: () => _showAdd(context, cats, l10n),
                      child: const Icon(Icons.add),
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildTargetsTab(
    Map<String, dynamic> targets,
    List<String> cats,
    WorkspaceRole role,
    AppLocalizations l10n,
    String currencyCode,
  ) {
    final fmt = AppFormatters.money(context, currencyCode);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: cats.map((cat) {
        final ctrl =
            TextEditingController(text: (targets[cat] ?? '').toString());
        return ListTile(
          key: ValueKey('target_$cat'),
          title: Text(cat),
          trailing: SizedBox(
            width: 120,
            child: TextField(
              controller: ctrl,
              enabled: role.canEditLedger,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                prefixText: fmt.currencySymbol,
              ),
              onChanged: (val) {
                if (!role.canEditLedger) return;
                FirebaseFirestore.instance
                    .collection('workspaces')
                    .doc(widget.wsId)
                    .update({
                  'targets.$cat': double.tryParse(val) ?? 0,
                });
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInstallmentsTab(
    List<DocumentSnapshot<Map<String, dynamic>>> allDocs,
    WorkspaceRole role,
    AppLocalizations l10n,
  ) {
    final groups = <String, List<DocumentSnapshot<Map<String, dynamic>>>>{};
    for (final d in allDocs) {
      final gId = getSafeField(d, 'groupId', null);
      if (gId != null) groups.putIfAbsent(gId.toString(), () => []).add(d);
    }
    return ListView(
      children: groups.keys.map((gId) {
        var group = groups[gId]!;
        group.sort((a, b) =>
            (a['date'] as Timestamp).compareTo(b['date'] as Timestamp));
        final total = group.length;
        final current = group
            .where((d) =>
                (d['date'] as Timestamp).toDate().isBefore(DateTime.now()))
            .length;
        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            title: Text(group.first['title'].toString().split('(').first),
            subtitle: Text(l10n.installmentProgress('$current', '$total')),
            trailing: role.canEditLedger
                ? IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.red),
                    onPressed: () => _deleteSeries(group, l10n),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  void _deleteSeries(List<DocumentSnapshot<Map<String, dynamic>>> group,
      AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteSeriesTitle),
        content: Text(l10n.deleteSeriesConfirm),
        actions: [
          ElevatedButton(
            onPressed: () async {
              for (final d in group) {
                await d.reference.delete();
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.deleteAll),
          ),
        ],
      ),
    );
  }

  Widget _buildTxTile(
    DocumentSnapshot<Map<String, dynamic>> d,
    WorkspaceRole role,
    AppLocalizations l10n,
    NumberFormat money,
    List<String> cats,
  ) {
    final isExp = getSafeField(d, 'isExpense', true) as bool;
    return ListTile(
      leading: Icon(
        isExp ? Icons.remove_circle : Icons.add_circle,
        color: isExp ? Colors.red : Colors.green,
      ),
      title: Text('${d['title']}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            money.format((d['amount'] ?? 0) as num),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isExp ? Colors.red : Colors.green,
            ),
          ),
          if (role.canEditLedger) ...[
            IconButton(
              tooltip: l10n.edit,
              icon: const Icon(Icons.edit),
              onPressed: () => _editSingle(d, cats, l10n),
            ),
            IconButton(
              tooltip: l10n.delete,
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteSingle(d, l10n),
            ),
          ],
        ],
      ),
    );
  }

  void _editSingle(DocumentSnapshot<Map<String, dynamic>> doc,
      List<String> cats, AppLocalizations l10n) {
    final data = doc.data() as Map<String, dynamic>;
    final workingCats = List<String>.from(cats);
    final titleCtrl = TextEditingController(text: data['title']?.toString());
    final amtCtrl = TextEditingController(text: data['amount']?.toString());
    final instCtrl = TextEditingController(text: '1');
    final newCatCtrl = TextEditingController();

    var cat = data['category']?.toString() ?? workingCats.first;
    var isExp = data['isExpense'] as bool? ?? true;
    var isAddingNewCat = false;

    showModalBottomSheet<void>(
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
              Text(l10n.edit, style: Theme.of(ctx).textTheme.titleLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.income),
                  Switch(
                    value: isExp,
                    onChanged: (v) => setS(() => isExp = v),
                  ),
                  Text(l10n.expense),
                ],
              ),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(labelText: l10n.description),
              ),
              TextField(
                controller: amtCtrl,
                decoration: InputDecoration(labelText: l10n.totalAmount),
                keyboardType: TextInputType.number,
              ),
              if (isExp)
                TextField(
                  controller: instCtrl,
                  decoration: InputDecoration(labelText: l10n.payments),
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: 10),
              if (!isAddingNewCat)
                DropdownButtonFormField<String>(
                  value: workingCats.contains(cat) ? cat : workingCats.first,
                  items: workingCats
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    if (isOtherCategoryLabel(v, l10n)) {
                      setS(() => isAddingNewCat = true);
                    } else {
                      setS(() => cat = v);
                    }
                  },
                  decoration: InputDecoration(labelText: l10n.category),
                )
              else
                TextField(
                  controller: newCatCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.newCategoryName,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        final trimmed = newCatCtrl.text.trim();
                        if (trimmed.isEmpty) return;
                        setS(() {
                          if (!workingCats.contains(trimmed)) {
                            workingCats.insert(0, trimmed);
                          }
                          cat = trimmed;
                          isAddingNewCat = false;
                        });
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
                    final trimmedCat =
                        isAddingNewCat ? newCatCtrl.text.trim() : cat;

                    if (trimmedCat.isEmpty) return;

                    final count = int.tryParse(instCtrl.text) ?? 1;
                    final total = double.tryParse(amtCtrl.text) ?? 0.0;

                    if (count > 1) {
                      // If changing to installments, delete original and create series
                      await doc.reference.delete();
                      final gId =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      for (var i = 0; i < count; i++) {
                        final d = DateTime.now();
                        await FirebaseFirestore.instance
                            .collection('workspaces')
                            .doc(widget.wsId)
                            .collection('transactions')
                            .add({
                          'title': '${titleCtrl.text} (${i + 1}/$count)',
                          'amount': total / count,
                          'isExpense': isExp,
                          'category': trimmedCat,
                          'date': DateTime(d.year, d.month + i, d.day),
                          'groupId': gId,
                        });
                      }
                    } else {
                      await doc.reference.update({
                        'title': titleCtrl.text,
                        'amount': total,
                        'isExpense': isExp,
                        'category': trimmedCat,
                      });
                    }

                    // If a new category was created, also update workspace list
                    if (isAddingNewCat && !cats.contains(trimmedCat)) {
                      await FirebaseFirestore.instance
                          .collection('workspaces')
                          .doc(widget.wsId)
                          .update({
                        'customCategories': FieldValue.arrayUnion([trimmedCat]),
                        'targets.$trimmedCat': 0,
                      });
                    }

                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(l10n.update),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteSingle(
      DocumentSnapshot<Map<String, dynamic>> doc, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTxTitle),
        content: Text(l10n.deleteTxConfirm),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await doc.reference.delete();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.delete),
          ),
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
        ],
      ),
    );
  }

  Widget _buildBalanceHeader(
    BuildContext context,
    AppLocalizations l10n,
    NumberFormat money,
    double inc,
    double exp,
    DateTime start,
    DateTime end,
  ) {
    final df = AppFormatters.cycleDayMonth(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.teal.shade50,
      child: Column(
        children: [
          Text(
            l10n.cycle(df.format(start), df.format(end)),
            style: const TextStyle(fontSize: 12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.incomeTotal(money.format(inc)),
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold),
              ),
              Text(
                l10n.expensesTotal(money.format(exp)),
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
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
            l10n.balance(money.format(inc - exp)),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showAdd(
    BuildContext context,
    List<String> cats,
    AppLocalizations l10n,
  ) {
    final workingCats = List<String>.from(cats);
    final title = TextEditingController();
    final amt = TextEditingController();
    final inst = TextEditingController(text: '1');
    final newCatCtrl = TextEditingController();

    final defaultSpend = workingCats.contains(l10n.catGroceries)
        ? l10n.catGroceries
        : workingCats.first;
    var cat = defaultSpend;
    var isExp = true;
    var isAddingNewCat = false;

    showModalBottomSheet<void>(
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
                  Text(l10n.income),
                  Switch(
                    value: isExp,
                    onChanged: (v) => setS(() => isExp = v),
                  ),
                  Text(l10n.expense),
                ],
              ),
              TextField(
                controller: title,
                decoration: InputDecoration(labelText: l10n.description),
              ),
              TextField(
                controller: amt,
                decoration: InputDecoration(labelText: l10n.totalAmount),
                keyboardType: TextInputType.number,
              ),
              if (isExp)
                TextField(
                  controller: inst,
                  decoration: InputDecoration(labelText: l10n.payments),
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
                    if (v == null) return;
                    if (isOtherCategoryLabel(v, l10n)) {
                      setS(() => isAddingNewCat = true);
                    } else {
                      setS(() => cat = v);
                    }
                  },
                  decoration: InputDecoration(labelText: l10n.category),
                )
              else
                TextField(
                  controller: newCatCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.newCategoryName,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () async {
                        final trimmed = newCatCtrl.text.trim();
                        if (trimmed.isEmpty ||
                            isOtherCategoryLabel(trimmed, l10n)) return;

                        setS(() {
                          if (!workingCats.contains(trimmed)) {
                            final idx = indexOfOtherCategory(workingCats, l10n);
                            if (idx >= 0) {
                              workingCats.insert(idx, trimmed);
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
                            'targets.$trimmed': 0,
                          });
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    l10n.errorSavingCategory(e.toString()))),
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
                    if (isAddingNewCat) {
                      final trimmed = newCatCtrl.text.trim();
                      if (trimmed.isEmpty ||
                          isOtherCategoryLabel(trimmed, l10n)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.enterNewCategoryName)),
                        );
                        return;
                      }

                      setS(() {
                        if (!workingCats.contains(trimmed)) {
                          final idx = indexOfOtherCategory(workingCats, l10n);
                          if (idx >= 0) {
                            workingCats.insert(idx, trimmed);
                          } else {
                            workingCats.add(trimmed);
                          }
                        }
                        cat = trimmed;
                        isAddingNewCat = false;
                      });

                      await FirebaseFirestore.instance
                          .collection('workspaces')
                          .doc(widget.wsId)
                          .update({
                        'customCategories': FieldValue.arrayUnion([trimmed]),
                        'targets.$trimmed': 0,
                      });
                      newCatCtrl.clear();
                    }

                    final count = int.tryParse(inst.text) ?? 1;
                    final total = double.tryParse(amt.text) ?? 0;
                    final gId =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    for (var i = 0; i < count; i++) {
                      final d = DateTime.now();
                      await FirebaseFirestore.instance
                          .collection('workspaces')
                          .doc(widget.wsId)
                          .collection('transactions')
                          .add({
                        'title': count > 1
                            ? '${title.text} (${i + 1}/$count)'
                            : title.text,
                        'amount': total / count,
                        'isExpense': isExp,
                        'category': cat,
                        'date': DateTime(d.year, d.month + i, d.day),
                        'groupId': gId,
                      });
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(l10n.save),
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:family_biz_finance/app_theme.dart';
import 'package:family_biz_finance/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app_formatters.dart';
import '../default_categories.dart';
import '../shared_receipt.dart';
import '../user_profile_repository.dart';
import '../widgets/app_version_display.dart';
import '../workspace_membership.dart';
import '../workspace_role.dart';

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
  SharedReceiptData? _pendingShared;

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

    // Picks up a bill/receipt shared into the installed web app from
    // another app (Photos, Gmail, WhatsApp, ...) via the share sheet.
    consumePendingSharedReceipt().then((shared) {
      if (shared != null && mounted) {
        setState(() => _pendingShared = shared);
      }
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
            left: 20,
            right: 20,
            top: 8,
            bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.workspaceSettings,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              Text(l10n.inviteCode, style: Theme.of(ctx).textTheme.titleSmall),
              const SizedBox(height: 6),
              SelectableText(invite.isEmpty ? '—' : invite),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: invite.isEmpty
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: invite));
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(
                          ctx,
                        ).showSnackBar(SnackBar(content: Text(l10n.copied)));
                      },
                icon: const Icon(Icons.copy, size: 17),
                label: Text(l10n.copyInviteCode),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.inviteEmailHint,
                style: Theme.of(ctx).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(hintText: l10n.email),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () async {
                  await WorkspaceMembership.inviteByEmail(
                    workspaceId: widget.wsId,
                    email: emailCtrl.text,
                  );
                  if (!ctx.mounted) return;
                  ScaffoldMessenger.of(
                    ctx,
                  ).showSnackBar(SnackBar(content: Text(l10n.inviteSent)));
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
    final palette = AppColors.of(context);

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
              getSafeField(wsSnap.data!, 'customCategories', <String>[]),
            );
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

            if (_pendingShared != null && role.canEditLedger) {
              final shared = _pendingShared!;
              _pendingShared = null;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _showAdd(context, cats, l10n, shared: shared);
              });
            }

            return Scaffold(
              appBar: AppBar(
                titleSpacing: 20,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.wsName,
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: palette.inkSoft),
                    ),
                    Text(l10n.ledgerTitle, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 21)),
                  ],
                ),
                actions: [
                  const Center(child: AppVersionDisplay()),
                  const SizedBox(width: 6),
                  if (role == WorkspaceRole.admin)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        tooltip: l10n.workspaceSettings,
                        onPressed: () => _openWorkspaceAdminSheet(context, wsData),
                        icon: const Icon(Icons.settings_outlined),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                            side: BorderSide(color: palette.line, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              drawer: Drawer(
                child: SafeArea(
                  child: Column(
                    children: [
                      DrawerHeader(
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                        child: Center(
                          child: Text(
                            widget.wsName,
                            style: const TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: AppVersionDisplay(),
                      ),
                    ],
                  ),
                ),
              ),
              body: Column(
                children: [
                  if (!role.canEditLedger)
                    ColoredBox(
                      color: palette.surfaceTint,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.visibility_outlined, size: 18, color: palette.accentDeep),
                            const SizedBox(width: 8),
                            Expanded(child: Text(l10n.readOnlyNotice)),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _PillTabBar(controller: _tabController, labels: [
                      l10n.tabExpenses,
                      l10n.tabIncome,
                      l10n.tabInstallments,
                      l10n.tabTargets,
                    ]),
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
                            child: CircularProgressIndicator(),
                          );
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
                          return dDate.isAfter(
                                cycleStart.subtract(const Duration(seconds: 1)),
                              ) &&
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
                            final c = getSafeField(
                              d,
                              'category',
                              l10n.catOther,
                            ).toString();
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
                                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
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
                                          ? palette.positive
                                          : palette.negative;
                                      final statusText = remaining >= 0
                                          ? l10n.remaining(
                                              money.format(remaining),
                                            )
                                          : l10n.overBudget(
                                              money.format(remaining.abs()),
                                            );

                                      if (catDocs.isEmpty && catTarget == 0) {
                                        return const SizedBox.shrink();
                                      }

                                      return Padding(
                                        key: ValueKey('$cat$catTarget'),
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(categoryIcon(cat, l10n), size: 16, color: palette.accentDeep),
                                                      const SizedBox(width: 8),
                                                      Text(cat, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                                                    ],
                                                  ),
                                                  Text(
                                                    catTarget > 0
                                                        ? l10n.spentOfTarget(money.format(catSpent), money.format(catTarget))
                                                        : money.format(catSpent),
                                                    style: TextStyle(color: labelColor, fontWeight: FontWeight.w700, fontSize: 12.5),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (catTarget > 0)
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
                                                child: Text(statusText, style: TextStyle(color: labelColor, fontSize: 11.5)),
                                              ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.surface,
                                                borderRadius: BorderRadius.circular(18),
                                                border: Border.all(color: palette.line, width: 1.5),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: Column(
                                                children: [
                                                  for (var i = 0; i < catDocs.length; i++) ...[
                                                    if (i > 0) Divider(height: 1, color: palette.line),
                                                    _buildTxTile(catDocs[i], role, l10n, money, cats),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            ListView(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: palette.line, width: 1.5),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    children: [
                                      for (var i = 0; i < incDocs.length; i++) ...[
                                        if (i > 0) Divider(height: 1, color: palette.line),
                                        _buildTxTile(incDocs[i], role, l10n, money, cats),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            _buildInstallmentsTab(allDocs, role, l10n),
                            _buildTargetsTab(
                              targets,
                              cats,
                              role,
                              l10n,
                              currencyCode,
                            ),
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
    final palette = AppColors.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      children: cats.map((cat) {
        final ctrl = TextEditingController(
          text: (targets[cat] ?? '').toString(),
        );
        return Container(
          key: ValueKey('target_$cat'),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.line, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(categoryIcon(cat, l10n), size: 17, color: palette.accentDeep),
              const SizedBox(width: 12),
              Expanded(child: Text(cat, style: const TextStyle(fontWeight: FontWeight.w600))),
              SizedBox(
                width: 110,
                child: TextField(
                  controller: ctrl,
                  enabled: role.canEditLedger,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: '0',
                    prefixText: fmt.currencySymbol,
                  ),
                  onChanged: (val) {
                    if (!role.canEditLedger) return;
                    FirebaseFirestore.instance
                        .collection('workspaces')
                        .doc(widget.wsId)
                        .update({'targets.$cat': double.tryParse(val) ?? 0});
                  },
                ),
              ),
            ],
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
    final palette = AppColors.of(context);
    final groups = <String, List<DocumentSnapshot<Map<String, dynamic>>>>{};
    for (final d in allDocs) {
      final gId = getSafeField(d, 'groupId', null);
      if (gId != null) groups.putIfAbsent(gId.toString(), () => []).add(d);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      children: groups.keys.map((gId) {
        var group = groups[gId]!;
        group.sort(
          (a, b) => (a['date'] as Timestamp).compareTo(b['date'] as Timestamp),
        );
        final total = group.length;
        final current = group
            .where(
              (d) => (d['date'] as Timestamp).toDate().isBefore(DateTime.now()),
            )
            .length;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.line, width: 1.5),
          ),
          child: ListTile(
            title: Text(group.first['title'].toString().split('(').first),
            subtitle: Text(l10n.installmentProgress('$current', '$total')),
            trailing: role.canEditLedger
                ? IconButton(
                    icon: Icon(Icons.delete_sweep_outlined, color: palette.negative),
                    onPressed: () => _deleteSeries(group, l10n),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  void _deleteSeries(
    List<DocumentSnapshot<Map<String, dynamic>>> group,
    AppLocalizations l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteSeriesTitle),
        content: Text(l10n.deleteSeriesConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
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
    final palette = AppColors.of(context);
    final isExp = getSafeField(d, 'isExpense', true) as bool;
    final isBiz = getSafeField(d, 'isBusiness', false) as bool;
    final cat = getSafeField(d, 'category', l10n.catOther).toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: palette.surfaceTint,
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Icon(
              isExp ? categoryIcon(cat, l10n) : Icons.arrow_upward_rounded,
              size: 16,
              color: palette.accentDeep,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    '${d['title']}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isBiz) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: palette.surfaceTint,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.business_center_outlined, size: 11, color: palette.accentDeep),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isExp ? '-' : '+'}${money.format((d['amount'] ?? 0) as num)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              color: isExp ? palette.negative : palette.positive,
            ),
          ),
          if (role.canEditLedger) ...[
            IconButton(
              tooltip: l10n.edit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              visualDensity: VisualDensity.compact,
              onPressed: () => _editSingle(d, cats, l10n),
            ),
            IconButton(
              tooltip: l10n.delete,
              icon: Icon(Icons.delete_outline, size: 18, color: palette.negative),
              visualDensity: VisualDensity.compact,
              onPressed: () => _deleteSingle(d, l10n),
            ),
          ],
        ],
      ),
    );
  }

  void _editSingle(
    DocumentSnapshot<Map<String, dynamic>> doc,
    List<String> cats,
    AppLocalizations l10n,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    final workingCats = List<String>.from(cats);
    final titleCtrl = TextEditingController(text: data['title']?.toString());
    final amtCtrl = TextEditingController(text: data['amount']?.toString());
    final instCtrl = TextEditingController(text: '1');
    final newCatCtrl = TextEditingController();

    var cat = data['category']?.toString() ?? workingCats.first;
    var isExp = data['isExpense'] as bool? ?? true;
    var isBiz = data['isBusiness'] as bool? ?? false;
    var isAddingNewCat = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => _TransactionSheet(
          l10n: l10n,
          title: l10n.edit,
          isExp: isExp,
          isBiz: isBiz,
          workingCats: workingCats,
          selectedCat: cat,
          isAddingNewCat: isAddingNewCat,
          titleCtrl: titleCtrl,
          amountCtrl: amtCtrl,
          installmentsCtrl: instCtrl,
          newCatCtrl: newCatCtrl,
          onToggleExpense: (v) => setS(() => isExp = v),
          onToggleBusiness: (v) => setS(() => isBiz = v),
          onSelectCategory: (v) => setS(() => cat = v),
          onStartNewCategory: () => setS(() => isAddingNewCat = true),
          onConfirmNewCategory: () {
            final trimmed = newCatCtrl.text.trim();
            if (trimmed.isEmpty) return;
            setS(() {
              if (!workingCats.contains(trimmed)) workingCats.insert(0, trimmed);
              cat = trimmed;
              isAddingNewCat = false;
            });
          },
          onSubmit: () async {
            final trimmedCat = isAddingNewCat ? newCatCtrl.text.trim() : cat;
            if (trimmedCat.isEmpty) return;

            final count = int.tryParse(instCtrl.text) ?? 1;
            final total = double.tryParse(amtCtrl.text) ?? 0.0;

            if (count > 1) {
              // If changing to installments, delete original and create series
              await doc.reference.delete();
              final gId = DateTime.now().millisecondsSinceEpoch.toString();
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
                  'isBusiness': isBiz,
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
                'isBusiness': isBiz,
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
        ),
      ),
    );
  }

  void _deleteSingle(
    DocumentSnapshot<Map<String, dynamic>> doc,
    AppLocalizations l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTxTitle),
        content: Text(l10n.deleteTxConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await doc.reference.delete();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.delete),
          ),
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
    final palette = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: palette.line, width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              l10n.cycle(df.format(start), df.format(end)),
              style: TextStyle(fontSize: 12, color: palette.inkFaint, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(color: palette.positiveBg, borderRadius: BorderRadius.circular(9)),
                      child: Icon(Icons.arrow_upward_rounded, size: 14, color: palette.positive),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.income, style: TextStyle(fontSize: 11.5, color: palette.inkSoft, fontWeight: FontWeight.w600)),
                        Text(money.format(inc), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: palette.positive)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(l10n.expense, style: TextStyle(fontSize: 11.5, color: palette.inkSoft, fontWeight: FontWeight.w600)),
                        Text(money.format(exp), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: palette.negative)),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(color: palette.negativeBg, borderRadius: BorderRadius.circular(9)),
                      child: Icon(Icons.arrow_downward_rounded, size: 14, color: palette.negative),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (inc + exp) == 0 ? 0.5 : inc / (inc + exp),
                minHeight: 8,
                color: palette.positive,
                backgroundColor: palette.negativeBg,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.balance(money.format(inc - exp)),
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdd(
    BuildContext context,
    List<String> cats,
    AppLocalizations l10n, {
    SharedReceiptData? shared,
  }) {
    final workingCats = List<String>.from(cats);
    final sharedDescription = shared == null
        ? ''
        : (shared.text.isNotEmpty ? shared.text : shared.title);
    final title = TextEditingController(text: sharedDescription);
    final amt = TextEditingController();
    final inst = TextEditingController(text: '1');
    final newCatCtrl = TextEditingController();

    final defaultSpend = workingCats.contains(l10n.catGroceries)
        ? l10n.catGroceries
        : workingCats.first;
    var cat = defaultSpend;
    var isExp = true;
    var isBiz = false;
    var isAddingNewCat = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => _TransactionSheet(
          l10n: l10n,
          title: isExp ? l10n.tabExpenses : l10n.tabIncome,
          isExp: isExp,
          isBiz: isBiz,
          workingCats: workingCats,
          selectedCat: cat,
          isAddingNewCat: isAddingNewCat,
          titleCtrl: title,
          amountCtrl: amt,
          installmentsCtrl: inst,
          newCatCtrl: newCatCtrl,
          receiptImageBytes: shared?.bytes,
          onToggleExpense: (v) => setS(() => isExp = v),
          onToggleBusiness: (v) => setS(() => isBiz = v),
          onSelectCategory: (v) => setS(() => cat = v),
          onStartNewCategory: () => setS(() => isAddingNewCat = true),
          onConfirmNewCategory: () async {
            final trimmed = newCatCtrl.text.trim();
            if (trimmed.isEmpty || isOtherCategoryLabel(trimmed, l10n)) return;

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
                'customCategories': FieldValue.arrayUnion([trimmed]),
                'targets.$trimmed': 0,
              });
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.errorSavingCategory(e.toString()))),
              );
            }

            newCatCtrl.clear();
          },
          onSubmit: () async {
            if (isAddingNewCat) {
              final trimmed = newCatCtrl.text.trim();
              if (trimmed.isEmpty || isOtherCategoryLabel(trimmed, l10n)) {
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
            final gId = DateTime.now().millisecondsSinceEpoch.toString();
            for (var i = 0; i < count; i++) {
              final d = DateTime.now();
              await FirebaseFirestore.instance
                  .collection('workspaces')
                  .doc(widget.wsId)
                  .collection('transactions')
                  .add({
                'title': count > 1 ? '${title.text} (${i + 1}/$count)' : title.text,
                'amount': total / count,
                'isExpense': isExp,
                'isBusiness': isBiz,
                'category': cat,
                'date': DateTime(d.year, d.month + i, d.day),
                'groupId': gId,
              });
            }
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }
}

/// Warm pill-styled segmented tab bar, matching the redesign's tab treatment.
class _PillTabBar extends StatelessWidget {
  const _PillTabBar({required this.controller, required this.labels});

  final TabController controller;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.line, width: 1.5),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: palette.inkSoft,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: labels.map((l) => Tab(text: l, height: 38)).toList(),
      ),
    );
  }
}

/// Shared add/edit transaction bottom sheet content, matching the redesign.
class _TransactionSheet extends StatelessWidget {
  const _TransactionSheet({
    required this.l10n,
    required this.title,
    required this.isExp,
    required this.isBiz,
    required this.workingCats,
    required this.selectedCat,
    required this.isAddingNewCat,
    required this.titleCtrl,
    required this.amountCtrl,
    required this.installmentsCtrl,
    required this.newCatCtrl,
    this.receiptImageBytes,
    required this.onToggleExpense,
    required this.onToggleBusiness,
    required this.onSelectCategory,
    required this.onStartNewCategory,
    required this.onConfirmNewCategory,
    required this.onSubmit,
  });

  final AppLocalizations l10n;
  final String title;
  final bool isExp;
  final bool isBiz;
  final List<String> workingCats;
  final String selectedCat;
  final bool isAddingNewCat;
  final TextEditingController titleCtrl;
  final TextEditingController amountCtrl;
  final TextEditingController installmentsCtrl;
  final TextEditingController newCatCtrl;
  final Uint8List? receiptImageBytes;
  final ValueChanged<bool> onToggleExpense;
  final ValueChanged<bool> onToggleBusiness;
  final ValueChanged<String> onSelectCategory;
  final VoidCallback onStartNewCategory;
  final VoidCallback onConfirmNewCategory;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppColors.of(context);
    final actionColor = isExp ? palette.negative : palette.positive;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 14,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: palette.line, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (receiptImageBytes != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  receiptImageBytes!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Expanded(
                    child: _segment(
                      context,
                      label: l10n.income,
                      selected: !isExp,
                      color: palette.positive,
                      onTap: () => onToggleExpense(false),
                    ),
                  ),
                  Expanded(
                    child: _segment(
                      context,
                      label: l10n.expense,
                      selected: isExp,
                      color: palette.negative,
                      onTap: () => onToggleExpense(true),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onToggleBusiness(!isBiz),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: palette.surfaceTint, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(Icons.business_center_outlined, size: 17, color: palette.accentDeep),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.bizTx, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                          Text(l10n.bizTxHint, style: TextStyle(fontSize: 12, color: palette.inkSoft)),
                        ],
                      ),
                    ),
                    Switch(value: isBiz, onChanged: onToggleBusiness),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(labelText: l10n.description),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amountCtrl,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              decoration: InputDecoration(labelText: l10n.totalAmount),
              keyboardType: TextInputType.number,
            ),
            if (isExp) ...[
              const SizedBox(height: 14),
              TextField(
                controller: installmentsCtrl,
                decoration: InputDecoration(labelText: l10n.payments),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            Text(l10n.category.toUpperCase(), style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: palette.inkSoft)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in workingCats)
                  _categoryChip(context, label: c, selected: !isAddingNewCat && c == selectedCat, onTap: () {
                    if (isOtherCategoryLabel(c, l10n)) {
                      onStartNewCategory();
                    } else {
                      onSelectCategory(c);
                    }
                  }),
              ],
            ),
            if (isAddingNewCat) ...[
              const SizedBox(height: 12),
              TextField(
                controller: newCatCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.newCategoryName,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: onConfirmNewCategory,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: actionColor),
              onPressed: onSubmit,
              child: Text(l10n.save),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _segment(
    BuildContext context, {
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: selected ? Colors.white : AppColors.of(context).inkSoft,
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final palette = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: selected ? null : Border.all(color: palette.line, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

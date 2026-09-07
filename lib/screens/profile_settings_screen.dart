import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:family_biz_finance/app_theme.dart';
import 'package:family_biz_finance/l10n/app_localizations.dart';

import '../user_profile_repository.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  static const _timezones = <String>[
    'UTC',
    'Asia/Jerusalem',
    'Europe/London',
    'America/New_York',
    'America/Los_Angeles',
  ];

  static const _currencies = <String>['ILS', 'USD', 'EUR'];

  Widget _section(BuildContext context, {required String label, required Widget child}) {
    final palette = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: palette.inkSoft)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileSettings)),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: UserProfileRepository.watch(user.uid),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data!.data() ?? const <String, dynamic>{};
          final localeCode = (data['preferredLocale']?.toString() ?? 'he');
          final tz = (data['timezone']?.toString() ?? 'Asia/Jerusalem');
          final currency = (data['currencyCode']?.toString() ?? 'ILS');

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              _section(
                context,
                label: l10n.language.toUpperCase(),
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
                    ButtonSegment(value: 'he', label: Text(l10n.languageHebrew)),
                  ],
                  selected: {localeCode == 'en' ? 'en' : 'he'},
                  onSelectionChanged: (sel) async {
                    final code = sel.first;
                    await UserProfileRepository.updatePreferredLocale(user.uid, code);
                  },
                ),
              ),
              _section(
                context,
                label: l10n.timezone.toUpperCase(),
                child: DropdownButtonFormField<String>(
                  value: _timezones.contains(tz) ? tz : 'Asia/Jerusalem',
                  items: _timezones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                  onChanged: (v) async {
                    if (v == null) return;
                    await UserProfileRepository.updateTimezone(user.uid, v);
                  },
                ),
              ),
              _section(
                context,
                label: l10n.currency.toUpperCase(),
                child: DropdownButtonFormField<String>(
                  value: _currencies.contains(currency) ? currency : 'ILS',
                  items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) async {
                    if (v == null) return;
                    await UserProfileRepository.updateCurrency(user.uid, v);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

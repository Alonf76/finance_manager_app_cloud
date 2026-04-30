import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<String>(
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
              const SizedBox(height: 24),
              Text(l10n.timezone, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _timezones.contains(tz) ? tz : 'Asia/Jerusalem',
                items: _timezones
                    .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                    .toList(),
                onChanged: (v) async {
                  if (v == null) return;
                  await UserProfileRepository.updateTimezone(user.uid, v);
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              Text(l10n.currency, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _currencies.contains(currency) ? currency : 'ILS',
                items: _currencies
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) async {
                  if (v == null) return;
                  await UserProfileRepository.updateCurrency(user.uid, v);
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          );
        },
      ),
    );
  }
}

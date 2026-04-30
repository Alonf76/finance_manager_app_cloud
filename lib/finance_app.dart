import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:family_biz_finance/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/login_screen.dart';
import 'screens/workspace_selector.dart';
import 'user_profile_repository.dart';

class FinanceRoot extends StatelessWidget {
  const FinanceRoot({super.key});

  static ThemeData _theme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.teal,
      fontFamily: 'Roboto',
    );
  }

  static List<LocalizationsDelegate<dynamic>> get _delegates => const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: _theme(),
            localizationsDelegates: _delegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final user = authSnap.data;
        if (user == null) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
            theme: _theme(),
            localizationsDelegates: _delegates,
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback: (locale, supported) {
              if (locale == null) return const Locale('en');
              for (final s in supported) {
                if (s.languageCode == locale.languageCode) return s;
              }
              return const Locale('en');
            },
            home: const LoginScreen(),
          );
        }

        return FutureBuilder<void>(
          future: UserProfileRepository.ensureProfile(user),
          builder: (context, fut) {
            if (fut.connectionState != ConnectionState.done) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: _theme(),
                localizationsDelegates: _delegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const Scaffold(body: Center(child: CircularProgressIndicator())),
              );
            }

            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: UserProfileRepository.watch(user.uid),
              builder: (context, profSnap) {
                if (!profSnap.hasData) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: _theme(),
                    localizationsDelegates: _delegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    home: const Scaffold(body: Center(child: CircularProgressIndicator())),
                  );
                }

                final data = profSnap.data!.data();
                final code = data?['preferredLocale']?.toString() ?? 'he';
                final locale = code == 'en' ? const Locale('en') : const Locale('he', 'IL');

                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  locale: locale,
                  onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
                  theme: _theme(),
                  localizationsDelegates: _delegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  home: const WorkspaceSelector(),
                );
              },
            );
          },
        );
      },
    );
  }
}

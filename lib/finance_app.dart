import 'package:family_biz_finance/app_theme.dart';
import 'package:family_biz_finance/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:family_biz_finance/l10n/app_localizations.dart'; // Generated localization
import 'package:flutter_localizations/flutter_localizations.dart';

class FinanceRoot extends StatelessWidget {
  const FinanceRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Biz Finance', // This will be replaced by l10n.appTitle
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      // Localization setup
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('he', ''), // Hebrew
      ],
      home: const AuthWrapper(), // The entry point to your app's UI logic
    );
  }
}

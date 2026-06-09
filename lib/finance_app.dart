import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Generated localization
import 'package:family_biz_finance/auth_wrapper.dart';

class FinanceRoot extends StatelessWidget {
  const FinanceRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Biz Finance', // This will be replaced by l10n.appTitle
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
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

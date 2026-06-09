// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Family Biz Finance';

  @override
  String get loginTitle => 'Login';

  @override
  String get registerTitle => 'Register';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Password';

  @override
  String get workspaceSelectionTitle => 'Select Workspace';

  @override
  String get ledgerTitle => 'Ledger';
}

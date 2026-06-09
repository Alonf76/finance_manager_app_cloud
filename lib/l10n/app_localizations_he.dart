// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'כספים משפחתיים';

  @override
  String get loginTitle => 'התחברות';

  @override
  String get registerTitle => 'הרשמה';

  @override
  String get emailHint => 'אימייל';

  @override
  String get passwordHint => 'סיסמה';

  @override
  String get workspaceSelectionTitle => 'בחירת מרחב עבודה';

  @override
  String get ledgerTitle => 'ספר חשבונות';
}

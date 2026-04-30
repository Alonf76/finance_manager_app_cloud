import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Hand-maintained localizations (M2). See `docs/l10n/README.md` for ARB/codegen notes.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  bool get _he => locale.languageCode == 'he';

  static AppLocalizations of(BuildContext context) {
    final value = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(value != null, 'AppLocalizations not found in widget tree');
    return value!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('he', 'IL'),
  ];

  String get appTitle => _he ? 'כספים משפחתיים' : 'Family Biz Finance';

  String get signIn => _he ? 'כניסה' : 'Sign in';
  String get signUp => _he ? 'הרשמה' : 'Sign up';
  String get email => _he ? 'אימייל' : 'Email';
  String get password => _he ? 'סיסמה' : 'Password';
  String get createAccount => _he ? 'צור חשבון' : 'Create account';
  String get haveAccount => _he ? 'יש לך חשבון? התחבר' : 'Already have an account? Sign in';
  String get noAccount => _he ? 'אין לך חשבון? הרשם' : 'No account? Sign up';

  String errorWithMessage(String message) => _he ? 'שגיאה: $message' : 'Error: $message';

  String get myWorkspaces => _he ? 'החשבונות שלי' : 'My workspaces';
  String get noActiveWorkspaces => _he ? 'אין חשבונות פעילים' : 'No active workspaces';
  String get signOut => _he ? 'התנתק' : 'Sign out';
  String get createNewFamilyWorkspace => _he ? 'צור חשבון משפחתי חדש' : 'Create new family workspace';
  String get workspaceName => _he ? 'שם החשבון' : 'Workspace name';
  String get create => _he ? 'צור' : 'Create';
  String get cancel => _he ? 'ביטול' : 'Cancel';
  String get joinWorkspace => _he ? 'הצטרפות בקוד' : 'Join with code';
  String get enterInviteCode => _he ? 'קוד הזמנה' : 'Invite code';
  String get join => _he ? 'הצטרף' : 'Join';
  String get joinSuccess => _he ? 'הצטרפת לחשבון בהצלחה' : 'Joined workspace successfully';
  String get inviteInvalid => _he ? 'לא נמצא חשבון עם הקוד הזה.' : 'No workspace matches that code.';
  String get pendingInvitesTitle => _he ? 'הזמנות ממתינות' : 'Pending invitations';
  String get acceptInvite => _he ? 'קבל' : 'Accept';
  String get declineInvite => _he ? 'דחה' : 'Decline';

  String get tabExpenses => _he ? 'הוצאות' : 'Expenses';
  String get tabIncome => _he ? 'הכנסות' : 'Income';
  String get tabInstallments => _he ? 'תשלומים' : 'Installments';
  String get tabTargets => _he ? 'יעדים' : 'Targets';

  String cycle(String start, String end) => _he ? 'סבב: $start – $end' : 'Cycle: $start – $end';

  String incomeTotal(String amount) => _he ? 'הכנסות: $amount' : 'Income: $amount';
  String expensesTotal(String amount) => _he ? 'הוצאות: $amount' : 'Expenses: $amount';
  String balance(String amount) => _he ? 'יתרה: $amount' : 'Balance: $amount';

  String remaining(String amount) => _he ? 'נשאר: $amount' : 'Left: $amount';
  String overBudget(String amount) => _he ? 'חריגה: $amount' : 'Over: $amount';

  String spentOfTarget(String spent, String target) => '$spent / $target';

  String get deleteSeriesTitle => _he ? 'מחיקת סדרה' : 'Delete series';
  String get deleteSeriesConfirm => _he ? 'האם למחוק את כל התשלומים?' : 'Delete all payments in this series?';
  String get deleteAll => _he ? 'מחק הכל' : 'Delete all';
  String get edit => _he ? 'עריכה' : 'Edit';
  String get delete => _he ? 'מחיקה' : 'Delete';
  String get deleteTxTitle => _he ? 'מחיקת תנועה' : 'Delete transaction';
  String get deleteTxConfirm => _he ? 'האם למחוק את התנועה הזו?' : 'Delete this transaction?';
  String get update => _he ? 'עדכן' : 'Update';

  String get income => _he ? 'הכנסה' : 'Income';
  String get expense => _he ? 'הוצאה' : 'Expense';
  String get description => _he ? 'תיאור' : 'Description';
  String get totalAmount => _he ? 'סכום כולל' : 'Total amount';
  String get payments => _he ? 'תשלומים' : 'Payments';
  String get category => _he ? 'קטגוריה' : 'Category';
  String get newCategoryName => _he ? 'שם קטגוריה חדשה' : 'New category name';

  String errorSavingCategory(String message) =>
      _he ? 'שגיאה בשמירת קטגוריה: $message' : 'Could not save category: $message';

  String get enterNewCategoryName => _he ? 'נא להזין שם קטגוריה חדשה' : 'Enter a new category name';
  String get save => _he ? 'שמור' : 'Save';

  String installmentProgress(String current, String total) =>
      _he ? 'תשלום $current מתוך $total' : 'Payment $current of $total';

  String get settings => _he ? 'הגדרות' : 'Settings';
  String get profileSettings => _he ? 'פרופיל והעדפות' : 'Profile & preferences';
  String get language => _he ? 'שפה' : 'Language';
  String get timezone => _he ? 'אזור זמן' : 'Time zone';
  String get currency => _he ? 'מטבע' : 'Currency';
  String get languageEnglish => _he ? 'אנגלית' : 'English';
  String get languageHebrew => _he ? 'עברית' : 'Hebrew';
  String get workspaceSettings => _he ? 'חשבון' : 'Workspace';
  String get inviteCode => _he ? 'קוד הזמנה' : 'Invite code';
  String get copyInviteCode => _he ? 'העתק קוד' : 'Copy code';
  String get inviteEmailHint => _he ? 'אימייל מוזמן' : 'Invitee email';
  String get sendInvite => _he ? 'שלח הזמנה' : 'Send invite';
  String get inviteSent => _he ? 'ההזמנה נשלחה' : 'Invitation sent';
  String get copied => _he ? 'הועתק' : 'Copied';

  String get readOnlyNotice => _he ? 'גישה לצפייה בלבד' : 'View-only access';

  String get catGroceries => _he ? 'מכולת ומזון' : 'Groceries & food';
  String get catHousing => _he ? 'דיור' : 'Housing';
  String get catCar => _he ? 'רכב' : 'Car & transport';
  String get catHealth => _he ? 'בריאות' : 'Health';
  String get catLeisure => _he ? 'פנאי' : 'Leisure';
  String get catOther => _he ? 'אחר' : 'Other';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en' || locale.languageCode == 'he';

  @override
  Future<AppLocalizations> load(Locale locale) {
    final normalized =
        locale.languageCode == 'he' ? const Locale('he', 'IL') : const Locale('en');
    return SynchronousFuture(AppLocalizations(normalized));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

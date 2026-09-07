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

  @override
  String get bizTx => 'עסקה עסקית';

  @override
  String get bizTxHint => 'סמן כהוצאה/הכנסה עסקית';

  @override
  String get noWorkspacesFound => 'לא נמצאו מרחבי עבודה';

  @override
  String get signIn => 'התחבר';

  @override
  String get signUp => 'הירשם';

  @override
  String get loginSubtitle =>
      'נהלו את כספי המשפחה ביחד — הוצאות, הכנסות והעסק, הכל במקום אחד.';

  @override
  String get signOut => 'התנתק';

  @override
  String get email => 'אימייל';

  @override
  String get password => 'סיסמה';

  @override
  String get noAccount => 'אין לך חשבון? הירשם';

  @override
  String get haveAccount => 'יש לך כבר חשבון? התחבר';

  @override
  String get myWorkspaces => 'מרחבי העבודה שלי';

  @override
  String get workspaceName => 'שם מרחב העבודה';

  @override
  String get createNewFamilyWorkspace => 'צור מרחב עבודה משפחתי חדש';

  @override
  String get create => 'צור';

  @override
  String get joinWorkspace => 'הצטרף למרחב עבודה';

  @override
  String get join => 'הצטרף';

  @override
  String get enterInviteCode => 'הזן קוד הזמנה';

  @override
  String get inviteInvalid => 'קוד הזמנה לא תקין או שפג תוקפו';

  @override
  String get joinSuccess => 'הצטרפת למרחב העבודה בהצלחה';

  @override
  String get noActiveWorkspaces => 'עדיין אין לך מרחבי עבודה פעילים';

  @override
  String get pendingInvitesTitle => 'הזמנות ממתינות';

  @override
  String get invitedToJoin => 'הוזמנת להצטרף';

  @override
  String get yourWorkspaces => 'מרחבי העבודה שלך';

  @override
  String get acceptInvite => 'קבל';

  @override
  String get declineInvite => 'דחה';

  @override
  String get cancel => 'ביטול';

  @override
  String errorWithMessage(Object error) {
    return 'שגיאה: $error';
  }

  @override
  String get workspaceSettings => 'הגדרות מרחב עבודה';

  @override
  String get inviteCode => 'קוד הזמנה';

  @override
  String get copyInviteCode => 'העתק קוד הזמנה';

  @override
  String get copied => 'הועתק';

  @override
  String get inviteEmailHint => 'הזמן באמצעות אימייל';

  @override
  String get sendInvite => 'שלח הזמנה';

  @override
  String get inviteSent => 'ההזמנה נשלחה';

  @override
  String get profileSettings => 'הגדרות פרופיל';

  @override
  String get language => 'שפה';

  @override
  String get languageEnglish => 'אנגלית';

  @override
  String get languageHebrew => 'עברית';

  @override
  String get timezone => 'אזור זמן';

  @override
  String get currency => 'מטבע';

  @override
  String get tabExpenses => 'הוצאות';

  @override
  String get tabIncome => 'הכנסות';

  @override
  String get tabInstallments => 'תשלומים';

  @override
  String get tabTargets => 'יעדים';

  @override
  String get readOnlyNotice => 'יש לך גישת צפייה בלבד למרחב עבודה זה';

  @override
  String get income => 'הכנסה';

  @override
  String get expense => 'הוצאה';

  @override
  String get description => 'תיאור';

  @override
  String get totalAmount => 'סכום כולל';

  @override
  String get payments => 'תשלומים';

  @override
  String get category => 'קטגוריה';

  @override
  String get newCategoryName => 'שם קטגוריה חדשה';

  @override
  String get enterNewCategoryName => 'הזן שם קטגוריה';

  @override
  String errorSavingCategory(Object error) {
    return 'שגיאה בשמירת הקטגוריה: $error';
  }

  @override
  String get save => 'שמור';

  @override
  String get update => 'עדכן';

  @override
  String get edit => 'עריכה';

  @override
  String get delete => 'מחק';

  @override
  String get deleteAll => 'מחק הכל';

  @override
  String get deleteTxTitle => 'מחיקת עסקה';

  @override
  String get deleteTxConfirm => 'למחוק את העסקה? לא ניתן לשחזר פעולה זו.';

  @override
  String get deleteSeriesTitle => 'מחיקת סדרה';

  @override
  String get deleteSeriesConfirm =>
      'למחוק את כל התשלומים בסדרה זו? לא ניתן לשחזר פעולה זו.';

  @override
  String installmentProgress(Object current, Object total) {
    return '$current מתוך $total תשלומים';
  }

  @override
  String cycle(Object start, Object end) {
    return 'מחזור: $start – $end';
  }

  @override
  String incomeTotal(Object amount) {
    return 'הכנסות: $amount';
  }

  @override
  String expensesTotal(Object amount) {
    return 'הוצאות: $amount';
  }

  @override
  String balance(Object amount) {
    return 'יתרה: $amount';
  }

  @override
  String remaining(Object amount) {
    return '$amount נותרו';
  }

  @override
  String overBudget(Object amount) {
    return 'חריגה מהתקציב ב-$amount';
  }

  @override
  String spentOfTarget(Object spent, Object target) {
    return '$spent מתוך $target';
  }

  @override
  String get catGroceries => 'מכולת';

  @override
  String get catHousing => 'דיור';

  @override
  String get catCar => 'רכב';

  @override
  String get catHealth => 'בריאות';

  @override
  String get catLeisure => 'פנאי';

  @override
  String get catOther => 'אחר';
}

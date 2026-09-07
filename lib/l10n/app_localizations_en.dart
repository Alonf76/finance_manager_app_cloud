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

  @override
  String get bizTx => 'Business Transaction';

  @override
  String get bizTxHint => 'Tag this as a business expense/income';

  @override
  String get noWorkspacesFound => 'No workspaces found';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get loginSubtitle =>
      'Track your family\'s money, together — expenses, income, and the business, all in one place.';

  @override
  String get signOut => 'Sign out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get noAccount => 'Don\'t have an account? Sign up';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get myWorkspaces => 'My workspaces';

  @override
  String get workspaceName => 'Workspace name';

  @override
  String get createNewFamilyWorkspace => 'Create new family workspace';

  @override
  String get create => 'Create';

  @override
  String get joinWorkspace => 'Join workspace';

  @override
  String get join => 'Join';

  @override
  String get enterInviteCode => 'Enter invite code';

  @override
  String get inviteInvalid => 'Invalid or expired invite code';

  @override
  String get joinSuccess => 'Joined workspace successfully';

  @override
  String get noActiveWorkspaces => 'You have no active workspaces yet';

  @override
  String get pendingInvitesTitle => 'Pending invites';

  @override
  String get invitedToJoin => 'Invited you to join';

  @override
  String get yourWorkspaces => 'Your workspaces';

  @override
  String get acceptInvite => 'Accept';

  @override
  String get declineInvite => 'Decline';

  @override
  String get cancel => 'Cancel';

  @override
  String errorWithMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String get workspaceSettings => 'Workspace settings';

  @override
  String get inviteCode => 'Invite code';

  @override
  String get copyInviteCode => 'Copy invite code';

  @override
  String get copied => 'Copied';

  @override
  String get inviteEmailHint => 'Invite by email';

  @override
  String get sendInvite => 'Send invite';

  @override
  String get inviteSent => 'Invite sent';

  @override
  String get profileSettings => 'Profile settings';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHebrew => 'Hebrew';

  @override
  String get timezone => 'Timezone';

  @override
  String get currency => 'Currency';

  @override
  String get tabExpenses => 'Expenses';

  @override
  String get tabIncome => 'Income';

  @override
  String get tabInstallments => 'Installments';

  @override
  String get tabTargets => 'Targets';

  @override
  String get readOnlyNotice => 'You have view-only access to this workspace';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get description => 'Description';

  @override
  String get totalAmount => 'Total amount';

  @override
  String get payments => 'Payments';

  @override
  String get category => 'Category';

  @override
  String get newCategoryName => 'New category name';

  @override
  String get enterNewCategoryName => 'Enter a category name';

  @override
  String errorSavingCategory(Object error) {
    return 'Error saving category: $error';
  }

  @override
  String get save => 'Save';

  @override
  String get update => 'Update';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get deleteTxTitle => 'Delete transaction';

  @override
  String get deleteTxConfirm =>
      'Delete this transaction? This cannot be undone.';

  @override
  String get deleteSeriesTitle => 'Delete series';

  @override
  String get deleteSeriesConfirm =>
      'Delete all payments in this series? This cannot be undone.';

  @override
  String installmentProgress(Object current, Object total) {
    return '$current of $total payments';
  }

  @override
  String cycle(Object start, Object end) {
    return 'Cycle: $start – $end';
  }

  @override
  String incomeTotal(Object amount) {
    return 'Income: $amount';
  }

  @override
  String expensesTotal(Object amount) {
    return 'Expenses: $amount';
  }

  @override
  String balance(Object amount) {
    return 'Balance: $amount';
  }

  @override
  String remaining(Object amount) {
    return '$amount remaining';
  }

  @override
  String overBudget(Object amount) {
    return 'Over budget by $amount';
  }

  @override
  String spentOfTarget(Object spent, Object target) {
    return '$spent of $target';
  }

  @override
  String get catGroceries => 'Groceries';

  @override
  String get catHousing => 'Housing';

  @override
  String get catCar => 'Car';

  @override
  String get catHealth => 'Health';

  @override
  String get catLeisure => 'Leisure';

  @override
  String get catOther => 'Other';
}

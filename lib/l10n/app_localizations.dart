import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Biz Finance'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @workspaceSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Workspace'**
  String get workspaceSelectionTitle;

  /// No description provided for @ledgerTitle.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledgerTitle;

  /// No description provided for @bizTx.
  ///
  /// In en, this message translates to:
  /// **'Business Transaction'**
  String get bizTx;

  /// No description provided for @bizTxHint.
  ///
  /// In en, this message translates to:
  /// **'Tag this as a business expense/income'**
  String get bizTxHint;

  /// No description provided for @noWorkspacesFound.
  ///
  /// In en, this message translates to:
  /// **'No workspaces found'**
  String get noWorkspacesFound;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your family\'s money, together — expenses, income, and the business, all in one place.'**
  String get loginSubtitle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccount;

  /// No description provided for @myWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'My workspaces'**
  String get myWorkspaces;

  /// No description provided for @workspaceName.
  ///
  /// In en, this message translates to:
  /// **'Workspace name'**
  String get workspaceName;

  /// No description provided for @createNewFamilyWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Create new family workspace'**
  String get createNewFamilyWorkspace;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @joinWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Join workspace'**
  String get joinWorkspace;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @enterInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Enter invite code'**
  String get enterInviteCode;

  /// No description provided for @inviteInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired invite code'**
  String get inviteInvalid;

  /// No description provided for @joinSuccess.
  ///
  /// In en, this message translates to:
  /// **'Joined workspace successfully'**
  String get joinSuccess;

  /// No description provided for @noActiveWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'You have no active workspaces yet'**
  String get noActiveWorkspaces;

  /// No description provided for @pendingInvitesTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending invites'**
  String get pendingInvitesTitle;

  /// No description provided for @invitedToJoin.
  ///
  /// In en, this message translates to:
  /// **'Invited you to join'**
  String get invitedToJoin;

  /// No description provided for @yourWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'Your workspaces'**
  String get yourWorkspaces;

  /// No description provided for @acceptInvite.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptInvite;

  /// No description provided for @declineInvite.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get declineInvite;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithMessage(Object error);

  /// No description provided for @workspaceSettings.
  ///
  /// In en, this message translates to:
  /// **'Workspace settings'**
  String get workspaceSettings;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCode;

  /// No description provided for @copyInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Copy invite code'**
  String get copyInviteCode;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @inviteEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Invite by email'**
  String get inviteEmailHint;

  /// No description provided for @sendInvite.
  ///
  /// In en, this message translates to:
  /// **'Send invite'**
  String get sendInvite;

  /// No description provided for @inviteSent.
  ///
  /// In en, this message translates to:
  /// **'Invite sent'**
  String get inviteSent;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile settings'**
  String get profileSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHebrew.
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get languageHebrew;

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @tabExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get tabExpenses;

  /// No description provided for @tabIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get tabIncome;

  /// No description provided for @tabInstallments.
  ///
  /// In en, this message translates to:
  /// **'Installments'**
  String get tabInstallments;

  /// No description provided for @tabTargets.
  ///
  /// In en, this message translates to:
  /// **'Targets'**
  String get tabTargets;

  /// No description provided for @readOnlyNotice.
  ///
  /// In en, this message translates to:
  /// **'You have view-only access to this workspace'**
  String get readOnlyNotice;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get totalAmount;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @newCategoryName.
  ///
  /// In en, this message translates to:
  /// **'New category name'**
  String get newCategoryName;

  /// No description provided for @enterNewCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Enter a category name'**
  String get enterNewCategoryName;

  /// No description provided for @errorSavingCategory.
  ///
  /// In en, this message translates to:
  /// **'Error saving category: {error}'**
  String errorSavingCategory(Object error);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// No description provided for @deleteTxTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction'**
  String get deleteTxTitle;

  /// No description provided for @deleteTxConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this transaction? This cannot be undone.'**
  String get deleteTxConfirm;

  /// No description provided for @deleteSeriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete series'**
  String get deleteSeriesTitle;

  /// No description provided for @deleteSeriesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all payments in this series? This cannot be undone.'**
  String get deleteSeriesConfirm;

  /// No description provided for @installmentProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total} payments'**
  String installmentProgress(Object current, Object total);

  /// No description provided for @cycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle: {start} – {end}'**
  String cycle(Object start, Object end);

  /// No description provided for @incomeTotal.
  ///
  /// In en, this message translates to:
  /// **'Income: {amount}'**
  String incomeTotal(Object amount);

  /// No description provided for @expensesTotal.
  ///
  /// In en, this message translates to:
  /// **'Expenses: {amount}'**
  String expensesTotal(Object amount);

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance: {amount}'**
  String balance(Object amount);

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String remaining(Object amount);

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget by {amount}'**
  String overBudget(Object amount);

  /// No description provided for @spentOfTarget.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {target}'**
  String spentOfTarget(Object spent, Object target);

  /// No description provided for @catGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get catGroceries;

  /// No description provided for @catHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get catHousing;

  /// No description provided for @catCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get catCar;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @catLeisure.
  ///
  /// In en, this message translates to:
  /// **'Leisure'**
  String get catLeisure;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

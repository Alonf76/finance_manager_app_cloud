import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static NumberFormat money(BuildContext context, String currencyCode) {
    final locale = Localizations.localeOf(context).toString();
    return NumberFormat.currency(
      locale: locale,
      name: currencyCode,
      decimalDigits: 0,
    );
  }

  static DateFormat cycleDayMonth(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.Md(locale);
  }
}

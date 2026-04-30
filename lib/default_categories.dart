import 'package:family_biz_finance/l10n/app_localizations.dart';

List<String> defaultWorkspaceCategories(AppLocalizations l10n) => [
      l10n.catGroceries,
      l10n.catHousing,
      l10n.catCar,
      l10n.catHealth,
      l10n.catLeisure,
      l10n.catOther,
    ];

bool isOtherCategoryLabel(String category, AppLocalizations l10n) {
  return category == l10n.catOther || category == 'אחר';
}

int indexOfOtherCategory(List<String> categories, AppLocalizations l10n) {
  for (var i = 0; i < categories.length; i++) {
    if (isOtherCategoryLabel(categories[i], l10n)) return i;
  }
  return categories.isEmpty ? -1 : categories.length - 1;
}

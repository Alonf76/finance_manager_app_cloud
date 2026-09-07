import 'package:flutter/material.dart';
import 'package:family_biz_finance/l10n/app_localizations.dart';

IconData categoryIcon(String category, AppLocalizations l10n) {
  if (category == l10n.catGroceries) return Icons.shopping_cart_outlined;
  if (category == l10n.catHousing) return Icons.home_outlined;
  if (category == l10n.catCar) return Icons.directions_car_outlined;
  if (category == l10n.catHealth) return Icons.favorite_outline;
  if (category == l10n.catLeisure) return Icons.star_outline_rounded;
  return Icons.more_horiz_rounded;
}

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

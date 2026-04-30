# Localization source notes (M2)

The app ships with a hand-written `lib/l10n/app_localizations.dart` so the project builds without relying on `flutter gen-l10n` in this environment.

If you want ARB-based codegen later:

1. Move ARB files back under `lib/l10n/`.
2. Add `l10n.yaml` and `flutter: generate: true` in `pubspec.yaml`.
3. Replace imports of `package:family_biz_finance/l10n/app_localizations.dart` with `package:flutter_gen/gen_l10n/app_localizations.dart`.

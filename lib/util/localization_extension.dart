import 'package:flutter/cupertino.dart';
import 'package:kjg_qr_code_generator/l10n/app_localizations.dart';


extension LocalizationExtension on BuildContext {
  AppLocalizations get localizations => AppLocalizations.of(this)!;
}
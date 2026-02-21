// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get title => 'KjG QR-Code Generator';

  @override
  String get kjg_logo => 'Seelenbohrer';

  @override
  String get download => 'Download';

  @override
  String get url => 'URL';

  @override
  String get downloading => 'Lädt herunter...';

  @override
  String get color => 'Farbe';

  @override
  String get colorCustom => 'Eigene Farbe';

  @override
  String get colorInvalidHex => 'Ungültiger Hex-Wert';
}

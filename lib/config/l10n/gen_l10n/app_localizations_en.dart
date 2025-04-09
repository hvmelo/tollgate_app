// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navBarHome => 'Home';

  @override
  String get navBarWallet => 'Wallet';

  @override
  String get navBarSettings => 'Settings';

  @override
  String get navBarMap => 'Map';

  @override
  String get mintScreenTitle => 'Mint';

  @override
  String get mintScreenAmountInSatsLabel => 'Amount in Sats';

  @override
  String get mintScreenCreateInvoice => 'Create Invoice';

  @override
  String get mintScreenCopyInvoice => 'Copy Invoice';

  @override
  String get mintScreenClose => 'Close';

  @override
  String get mintScreenInvoiceCopied => 'Invoice copied to clipboard';

  @override
  String mintScreenAmountTooLarge(Object maxAmount) {
    return 'Amount must be less than $maxAmount sats';
  }

  @override
  String get mintScreenAmountNegativeOrZero => 'Amount must be greater than 0';
}

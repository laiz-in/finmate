import 'dart:io';

class CurrencyOption {
  final String code;
  final String symbol;
  final String name;
  const CurrencyOption(this.code, this.symbol, this.name);
}

const List<CurrencyOption> kCurrencies = [
  CurrencyOption('USD', '\$', 'US Dollar'),
  CurrencyOption('AED', 'AED', 'UAE Dirham'),
  CurrencyOption('INR', '₹', 'Indian Rupee'),
  CurrencyOption('GBP', '£', 'British Pound'),
  CurrencyOption('EUR', '€', 'Euro'),
  CurrencyOption('SAR', 'SAR', 'Saudi Riyal'),
  CurrencyOption('AUD', 'A\$', 'Australian Dollar'),
  CurrencyOption('CAD', 'C\$', 'Canadian Dollar'),
  CurrencyOption('JPY', '¥', 'Japanese Yen'),
  CurrencyOption('CNY', '¥', 'Chinese Yuan'),
  CurrencyOption('SGD', 'S\$', 'Singapore Dollar'),
  CurrencyOption('PKR', '₨', 'Pakistani Rupee'),
  CurrencyOption('PHP', '₱', 'Philippine Peso'),
  CurrencyOption('EGP', 'E£', 'Egyptian Pound'),
  CurrencyOption('QAR', 'QAR', 'Qatari Riyal'),
];

const Map<String, String> _countryToCurrency = {
  'US': 'USD', 'AE': 'AED', 'IN': 'INR', 'GB': 'GBP', 'SA': 'SAR',
  'AU': 'AUD', 'CA': 'CAD', 'JP': 'JPY', 'CN': 'CNY', 'SG': 'SGD',
  'PK': 'PKR', 'PH': 'PHP', 'EG': 'EGP', 'QA': 'QAR',
  'DE': 'EUR', 'FR': 'EUR', 'ES': 'EUR', 'IT': 'EUR', 'NL': 'EUR',
};

CurrencyOption detectDefaultCurrency() {
  try {
    final locale = Platform.localeName; // e.g. en_AE
    final parts = locale.split('_');
    final country = parts.length > 1 ? parts[1] : '';
    final code = _countryToCurrency[country] ?? 'USD';
    return kCurrencies.firstWhere((c) => c.code == code, orElse: () => kCurrencies.first);
  } catch (_) {
    return kCurrencies.first;
  }
}
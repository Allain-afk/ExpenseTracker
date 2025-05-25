class Settings {
  final String currency;
  final String currencySymbol;
  final String userName;
  final bool notificationsEnabled;
  final double lowBalanceThreshold;
  final String notificationMessage;

  const Settings({
    required this.currency,
    required this.currencySymbol,
    required this.userName,
    required this.notificationsEnabled,
    required this.lowBalanceThreshold,
    required this.notificationMessage,
  });

  factory Settings.defaultSettings() {
    return const Settings(
      currency: 'PHP',
      currencySymbol: '₱',
      userName: '',
      notificationsEnabled: true,
      lowBalanceThreshold: 1000.0,
      notificationMessage: 'Hey {name}! Slow down on spending! You are now low on budget. You dumbass!',
    );
  }

  Settings copyWith({
    String? currency,
    String? currencySymbol,
    String? userName,
    bool? notificationsEnabled,
    double? lowBalanceThreshold,
    String? notificationMessage,
  }) {
    return Settings(
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      userName: userName ?? this.userName,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lowBalanceThreshold: lowBalanceThreshold ?? this.lowBalanceThreshold,
      notificationMessage: notificationMessage ?? this.notificationMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'currencySymbol': currencySymbol,
      'userName': userName,
      'notificationsEnabled': notificationsEnabled,
      'lowBalanceThreshold': lowBalanceThreshold,
      'notificationMessage': notificationMessage,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      currency: map['currency'] ?? 'PHP',
      currencySymbol: map['currencySymbol'] ?? '₱',
      userName: map['userName'] ?? '',
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      lowBalanceThreshold: map['lowBalanceThreshold']?.toDouble() ?? 1000.0,
      notificationMessage: map['notificationMessage'] ?? 'Hey {name}! Slow down on spending! You are now low on budget. You dumbass!',
    );
  }
}

class CurrencyOption {
  final String code;
  final String symbol;
  final String name;

  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.name,
  });

  static const List<CurrencyOption> availableCurrencies = [
    CurrencyOption(code: 'PHP', symbol: '₱', name: 'Philippine Peso'),
    CurrencyOption(code: 'USD', symbol: '\$', name: 'US Dollar'),
    CurrencyOption(code: 'EUR', symbol: '€', name: 'Euro'),
    CurrencyOption(code: 'GBP', symbol: '£', name: 'British Pound'),
    CurrencyOption(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    CurrencyOption(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
    CurrencyOption(code: 'KRW', symbol: '₩', name: 'South Korean Won'),
    CurrencyOption(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar'),
    CurrencyOption(code: 'MYR', symbol: 'RM', name: 'Malaysian Ringgit'),
    CurrencyOption(code: 'THB', symbol: '฿', name: 'Thai Baht'),
  ];
} 
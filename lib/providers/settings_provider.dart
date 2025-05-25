import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/settings.dart';
import '../database/database_helper.dart';

class SettingsProvider with ChangeNotifier {
  Settings _settings = Settings.defaultSettings();
  bool _isSetupComplete = false;
  
  Settings get settings => _settings;
  String get currencySymbol => _settings.currencySymbol;
  String get currency => _settings.currency;
  String get userName => _settings.userName;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  double get lowBalanceThreshold => _settings.lowBalanceThreshold;
  String get notificationMessage => _settings.notificationMessage;
  bool get isSetupComplete => _isSetupComplete;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('settings');
    _isSetupComplete = prefs.getBool('setup_complete') ?? false;
    
    if (settingsJson != null) {
      final settingsMap = json.decode(settingsJson);
      _settings = Settings.fromMap(settingsMap);
    } else {
      _settings = Settings.defaultSettings();
    }
    notifyListeners();
  }

  Future<void> updateCurrency(String currency, String currencySymbol) async {
    _settings = _settings.copyWith(
      currency: currency,
      currencySymbol: currencySymbol,
    );
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', json.encode(_settings.toMap()));
    notifyListeners();
  }

  Future<void> resetSettings() async {
    _settings = Settings.defaultSettings();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('settings');
    notifyListeners();
  }

  Future<void> updateUserSettings({
    required String userName,
    required bool notificationsEnabled,
    required double lowBalanceThreshold,
    required String notificationMessage,
  }) async {
    _settings = _settings.copyWith(
      userName: userName,
      notificationsEnabled: notificationsEnabled,
      lowBalanceThreshold: lowBalanceThreshold,
      notificationMessage: notificationMessage,
    );
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', json.encode(_settings.toMap()));
    notifyListeners();
  }

  Future<void> updateNotificationSettings({
    bool? notificationsEnabled,
    double? lowBalanceThreshold,
    String? notificationMessage,
  }) async {
    _settings = _settings.copyWith(
      notificationsEnabled: notificationsEnabled,
      lowBalanceThreshold: lowBalanceThreshold,
      notificationMessage: notificationMessage,
    );
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', json.encode(_settings.toMap()));
    notifyListeners();
  }

  Future<void> markSetupComplete() async {
    _isSetupComplete = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('setup_complete', true);
    notifyListeners();
  }

  Future<void> resetAllAppData() async {
    // Reset settings
    _settings = Settings.defaultSettings();
    _isSetupComplete = false;
    
    // Clear all shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Clear all transactions from database
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    await db.delete('transactions');
    
    notifyListeners();
  }
} 
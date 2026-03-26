import 'package:flutter/foundation.dart';
import '../models/wallet.dart';
import '../database/database_helper.dart';
import '../providers/transaction_provider.dart';

class WalletProvider with ChangeNotifier {
  List<Wallet> _wallets = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Wallet> get wallets => _wallets;

  Future<void> loadWallets() async {
    try {
      _wallets = await _dbHelper.getAllWallets();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading wallets: $e');
    }
  }

  Future<void> addWallet(Wallet wallet) async {
    try {
      await _dbHelper.insertWallet(wallet);
      await loadWallets();
    } catch (e) {
      debugPrint('Error adding wallet: $e');
    }
  }

  Future<void> updateWallet(Wallet wallet) async {
    try {
      await _dbHelper.updateWallet(wallet);
      await loadWallets();
    } catch (e) {
      debugPrint('Error updating wallet: $e');
    }
  }

  Future<void> deleteWallet(int id) async {
    try {
      await _dbHelper.deleteWallet(id);
      await loadWallets();
    } catch (e) {
      debugPrint('Error deleting wallet: $e');
    }
  }
}

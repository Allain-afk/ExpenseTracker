import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import 'add_wallet_screen.dart';
import 'package:intl/intl.dart';

class ManageWalletsScreen extends StatelessWidget {
  const ManageWalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Manage Cards'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddWalletScreen()));
            },
          ),
        ],
      ),
      body: Consumer3<WalletProvider, TransactionProvider, SettingsProvider>(
        builder: (context, walletProvider, transactionProvider, settingsProvider, child) {
          final wallets = walletProvider.wallets;
          final currencySymbol = settingsProvider.currencySymbol;

          if (wallets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No cards set up yet.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wallets.length,
            itemBuilder: (context, index) {
              final wallet = wallets[index];
              final balance = transactionProvider.getWalletBalance(wallet.id!);
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                color: Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Color(wallet.colorValue),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.credit_card, color: Colors.white, size: 22),
                  ),
                  title: Text(wallet.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(wallet.type, style: TextStyle(color: Colors.grey.shade600)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat.currency(symbol: currencySymbol).format(balance),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddWalletScreen(wallet: wallet)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

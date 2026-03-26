import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/expense_group_provider.dart';
import '../providers/settings_provider.dart';
import 'dart:ui';
import '../models/transaction.dart';
import '../widgets/glass_card.dart';
import '../widgets/inset_grouped_list.dart';
import 'group_detail_screen.dart';
import 'add_transaction_screen.dart';
import 'add_group_screen.dart';
import 'add_wallet_screen.dart';
import '../models/wallet.dart';
import '../providers/wallet_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
    await Provider.of<ExpenseGroupProvider>(context, listen: false).loadExpenseGroups();
    await Provider.of<WalletProvider>(context, listen: false).loadWallets();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: HomeScreenContent(),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  @override
  Widget build(BuildContext context) {
    return Consumer4<TransactionProvider, ExpenseGroupProvider, SettingsProvider, WalletProvider>(
      builder: (context, provider, groupProvider, settingsProvider, walletProvider, child) {
        final currencySymbol = settingsProvider.currencySymbol;
        
        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadTransactions();
            await groupProvider.loadExpenseGroups();
            await walletProvider.loadWallets();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 16, bottom: 80),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Welcome back,', style: TextStyle(color: Colors.grey, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(
                                  settingsProvider.userName.isNotEmpty ? settingsProvider.userName : 'User',
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade400, width: 1.5),
                                ),
                                child: const Icon(Icons.add, color: Colors.grey, size: 20),
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionScreen()));
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildWalletCarousel(context, provider, walletProvider, settingsProvider),
                      const SizedBox(height: 24),
                      _buildQuickActionsRow(context),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: InsetGroupedList(
                          headerText: 'EXPENSE GROUPS',
                          children: _buildGroupListItems(context, groupProvider, currencySymbol),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: InsetGroupedList(
                          headerText: 'RECENT TRANSACTIONS',
                          children: _buildRecentTransactionItems(context, provider, currencySymbol),
                        ),
                      ),
                      const SizedBox(height: 80), // Extra space at bottom for navigation
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletCarousel(BuildContext context, TransactionProvider provider, WalletProvider walletProvider, SettingsProvider settingsProvider) {
    final currencySymbol = settingsProvider.currencySymbol;
    return SizedBox(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildWalletCard(
            color: Color(settingsProvider.mainWalletColor),
            balance: NumberFormat.currency(symbol: currencySymbol).format(provider.balance),
            name: settingsProvider.mainWalletName,
            type: 'All Wallets',
            icon: Icons.account_balance_wallet,
            onTap: () => _showMainWalletActions(context, settingsProvider),
          ),
          ...walletProvider.wallets.map((wallet) {
            final double walletBal = provider.getWalletBalance(wallet.id!);
            return Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _buildWalletCard(
                color: Color(wallet.colorValue),
                balance: NumberFormat.currency(symbol: currencySymbol).format(walletBal),
                name: wallet.name,
                type: wallet.type,
                icon: Icons.credit_card,
                onTap: () => _showWalletActions(context, wallet),
              ),
            );
          }),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddWalletScreen()));
            },
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                color: Colors.grey.shade200.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300, width: 1, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                    child: const Icon(Icons.add_card, color: Colors.blue, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Add Card',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard({
    required Color color,
    required String balance,
    required String name,
    required String type,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 310,
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Type: $type',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Icon(icon, color: Colors.white70, size: 24),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      balance,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Wallet Name: $name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  void _showWalletActions(BuildContext context, Wallet wallet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  wallet.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.green),
                title: const Text('Add Income', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddTransactionScreen(initialWalletId: wallet.id, initialType: 'income')));
                },
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.red),
                title: const Text('Deduct Money', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddTransactionScreen(initialWalletId: wallet.id, initialType: 'expense')));
                },
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.blue),
                title: const Text('Manage Card'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddWalletScreen(wallet: wallet)));
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showMainWalletActions(BuildContext context, SettingsProvider settingsProvider) {
    String tempName = settingsProvider.mainWalletName;
    int tempColor = settingsProvider.mainWalletColor;

    final List<int> colors = [
      0xFF1F2937, 0xFF2563EB, 0xFF059669, 0xFFDC2626, 0xFFD97706, 0xFF7C3AED, 0xFF475569
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              margin: const EdgeInsets.only(top: 64, left: 16, right: 16, bottom: 16),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(20)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Edit Main Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            initialValue: tempName,
                            decoration: const InputDecoration(labelText: 'Wallet Name (e.g., Total Money)', border: OutlineInputBorder()),
                            onChanged: (val) => tempName = val,
                          ),
                          const SizedBox(height: 24),
                          const Text('Card Color', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: colors.map((c) {
                              final isSelected = tempColor == c;
                              return GestureDetector(
                                onTap: () => setModalState(() => tempColor = c),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Color(c),
                                    shape: BoxShape.circle,
                                    border: isSelected ? Border.all(color: Colors.blue, width: 3) : null,
                                  ),
                                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () async {
                                await settingsProvider.updateMainWallet(mainWalletName: tempName.trim().isEmpty ? 'Total Money' : tempName.trim(), mainWalletColor: tempColor);
                                if (context.mounted) Navigator.pop(context);
                              },
                              child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionCircle(Icons.document_scanner_outlined, 'Scan\nReceipt', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Scan Receipt feature coming soon!')),
            );
          }),
          _buildActionCircle(Icons.arrow_downward, 'Add\nIncome', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionScreen()));
          }),
          _buildActionCircle(Icons.add, 'New\nTransaction', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildActionCircle(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.blue.shade700, size: 28),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupListItems(
    BuildContext context,
    ExpenseGroupProvider groupProvider,
    String currencySymbol,
  ) {
    final groups = groupProvider.groups;
    if (groups.isEmpty) {
      return [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          child: const Center(
             child: Text('No expense groups yet', style: TextStyle(color: Colors.grey)),
          ),
        ),
      ];
    }
    
    final topGroups = groups.take(3).toList();
    return topGroups.map((group) {
      final total = groupProvider.getGroupTotal(group.id!);
      final transactionCount = groupProvider.getGroupTransactions(group.id!).length;
      return Container(
        color: Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.folder_rounded, color: Colors.blue.shade600, size: 22),
          ),
          title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          subtitle: Text('$transactionCount transaction${transactionCount != 1 ? 's' : ''}', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          trailing: Text(
            NumberFormat.currency(symbol: currencySymbol).format(total),
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade600, fontSize: 16),
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => GroupDetailScreen(group: group)));
          },
        ),
      );
    }).toList();
  }

  List<Widget> _buildRecentTransactionItems(
    BuildContext context,
    TransactionProvider provider,
    String currencySymbol,
  ) {
    final transactions = provider.transactions.take(5).toList();
    if (transactions.isEmpty) {
      return [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          child: const Center(
             child: Text('No transactions yet', style: TextStyle(color: Colors.grey)),
          ),
        ),
      ];
    }

    return transactions.map((transaction) {
      final isIncome = transaction.type == 'income';
      final iconColor = isIncome ? Colors.green.shade600 : Colors.red.shade600;
      final bgColor = isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1);

      return Container(
        color: Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: iconColor,
              size: 22,
            ),
          ),
          title: Text(transaction.description, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          subtitle: Text(transaction.category, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(symbol: currencySymbol).format(transaction.amount),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isIncome ? Colors.green.shade600 : Colors.black87,
                  fontSize: 16,
                ),
              ),
              Text(
                DateFormat('MMM d').format(transaction.date),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
} 
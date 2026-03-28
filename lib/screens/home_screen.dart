import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/expense_group_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/inset_grouped_list.dart';
import 'group_detail_screen.dart';
import 'add_transaction_screen.dart';
import 'add_wallet_screen.dart';
import '../models/wallet.dart';
import '../providers/wallet_provider.dart';
import '../utils/app_theme.dart';

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
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );
    final expenseGroupProvider = Provider.of<ExpenseGroupProvider>(
      context,
      listen: false,
    );
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });
    await transactionProvider.loadTransactions();
    await expenseGroupProvider.loadExpenseGroups();
    await walletProvider.loadWallets();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : const HomeScreenContent(),
      ),
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
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final currencySymbol = settingsProvider.currencySymbol;

        return RefreshIndicator(
          onRefresh: () async {
            final transactionProvider = Provider.of<TransactionProvider>(
              context,
              listen: false,
            );
            final expenseGroupProvider = Provider.of<ExpenseGroupProvider>(
              context,
              listen: false,
            );
            final walletProvider = Provider.of<WalletProvider>(
              context,
              listen: false,
            );

            await transactionProvider.loadTransactions();
            await expenseGroupProvider.loadExpenseGroups();
            await walletProvider.loadWallets();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 12, bottom: 104),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              settingsProvider.userName.isNotEmpty
                                  ? settingsProvider.userName
                                  : 'User',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.8,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildWalletCarousel(context, settingsProvider),
                      const SizedBox(height: 28),
                      Consumer<ExpenseGroupProvider>(
                        builder: (context, groupProvider, child) {
                          return InsetGroupedList(
                            headerText: 'Expense Groups',
                            children: _buildGroupListItems(
                              context,
                              groupProvider,
                              currencySymbol,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Consumer<TransactionProvider>(
                        builder: (context, provider, child) {
                          return InsetGroupedList(
                            headerText: 'Recent Transactions',
                            children: _buildRecentTransactionItems(
                              context,
                              provider,
                              currencySymbol,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
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

  Widget _buildWalletCarousel(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    return Consumer2<TransactionProvider, WalletProvider>(
      builder: (context, provider, walletProvider, child) {
        final currencySymbol = settingsProvider.currencySymbol;

        double totalWalletBalance = 0;
        for (var wallet in walletProvider.wallets) {
          totalWalletBalance += provider.getWalletBalance(wallet.id!);
        }

        return SizedBox(
          height: 204,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: walletProvider.wallets.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildWalletCard(
                    color: Color(settingsProvider.mainWalletColor),
                    balance: NumberFormat.currency(
                      symbol: currencySymbol,
                    ).format(
                      walletProvider.wallets.isEmpty
                          ? provider.balance
                          : totalWalletBalance,
                    ),
                    name: settingsProvider.mainWalletName,
                    type: 'All Wallets',
                    icon: Icons.account_balance_wallet,
                    onTap:
                        () => _showMainWalletActions(context, settingsProvider),
                  ),
                );
              } else if (index == walletProvider.wallets.length + 1) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _buildAddCardTile(context),
                );
              } else {
                final wallet = walletProvider.wallets[index - 1];
                final double walletBal = provider.getWalletBalance(wallet.id!);
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildWalletCard(
                    color: Color(wallet.colorValue),
                    balance: NumberFormat.currency(
                      symbol: currencySymbol,
                    ).format(walletBal),
                    name: wallet.name,
                    type: wallet.type,
                    icon: Icons.credit_card,
                    onTap: () => _showWalletActions(context, wallet),
                  ),
                );
              }
            },
          ),
        );
      },
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
    final gradientColors = AppTheme.walletGradientColors(color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 310,
        decoration: BoxDecoration(
          gradient: AppTheme.walletGradient(color),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withValues(alpha: 0.28),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -32,
              right: -12,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -46,
              left: -10,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              type.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: const Icon(
                          Icons.north_east_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    balance,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.1,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tap to manage',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCardTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddWalletScreen()),
        );
      },
      child: Container(
        width: 174,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.96),
              AppTheme.surfaceSoft.withValues(alpha: 0.82),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppTheme.border.withValues(alpha: 0.85)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_card_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Add Card',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Create another wallet with its own balance and color theme.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.green),
                title: const Text(
                  'Add Income',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddTransactionScreen(
                            initialWalletId: wallet.id,
                            initialType: 'income',
                          ),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.red),
                title: const Text(
                  'Deduct Money',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddTransactionScreen(
                            initialWalletId: wallet.id,
                            initialType: 'expense',
                          ),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.blue),
                title: const Text('Manage Card'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddWalletScreen(wallet: wallet),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showMainWalletActions(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    String tempName = settingsProvider.mainWalletName;
    int tempColor = settingsProvider.mainWalletColor;

    final List<int> colors = [
      0xFF1F2937,
      0xFF2563EB,
      0xFF059669,
      0xFFDC2626,
      0xFFD97706,
      0xFF7C3AED,
      0xFF475569,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              margin: const EdgeInsets.only(
                top: 64,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Edit Main Card',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            initialValue: tempName,
                            decoration: const InputDecoration(
                              labelText: 'Wallet Name (e.g., Total Money)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => tempName = val,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Card Color',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children:
                                colors.map((c) {
                                  final isSelected = tempColor == c;
                                  return GestureDetector(
                                    onTap:
                                        () =>
                                            setModalState(() => tempColor = c),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Color(c),
                                        shape: BoxShape.circle,
                                        border:
                                            isSelected
                                                ? Border.all(
                                                  color: Colors.blue,
                                                  width: 3,
                                                )
                                                : null,
                                      ),
                                      child:
                                          isSelected
                                              ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 24,
                                              )
                                              : null,
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                await settingsProvider.updateMainWallet(
                                  mainWalletName:
                                      tempName.trim().isEmpty
                                          ? 'Total Money'
                                          : tempName.trim(),
                                  mainWalletColor: tempColor,
                                );
                                if (context.mounted) Navigator.pop(context);
                              },
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
            child: Text(
              'No expense groups yet',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ];
    }

    final topGroups = groups.take(3).toList();
    return topGroups.map((group) {
      final total = groupProvider.getGroupTotal(group.id!);
      final transactionCount =
          groupProvider.getGroupTransactions(group.id!).length;
      return Container(
        color: Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.folder_rounded,
              color: Colors.blue.shade600,
              size: 22,
            ),
          ),
          title: Text(
            group.name,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          subtitle: Text(
            '$transactionCount transaction${transactionCount != 1 ? 's' : ''}',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          trailing: Text(
            NumberFormat.currency(symbol: currencySymbol).format(total),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.green.shade600,
              fontSize: 16,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupDetailScreen(group: group),
              ),
            );
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
            child: Text(
              'No transactions yet',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ];
    }

    return transactions.map((transaction) {
      final isIncome = transaction.type == 'income';
      final iconColor = isIncome ? Colors.green.shade600 : Colors.red.shade600;
      final bgColor =
          isIncome
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1);

      return Container(
        color: Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIncome ? Icons.add_rounded : Icons.remove_rounded,
              color: iconColor,
              size: 22,
            ),
          ),
          title: Text(
            transaction.description,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          subtitle: Text(
            transaction.category,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(
                  symbol: currencySymbol,
                ).format(transaction.amount),
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

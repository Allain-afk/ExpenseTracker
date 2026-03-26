import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/expense_group_provider.dart';
import '../providers/settings_provider.dart';
import 'home_screen.dart';
import 'transactions_screen.dart';
import 'expense_groups_screen.dart';
import 'add_transaction_screen.dart';
import 'settings_screen.dart';
import 'add_group_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionsScreen(),
    const ExpenseGroupsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final expenseGroupProvider = Provider.of<ExpenseGroupProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      
      // Add timeout to prevent infinite loading
      await Future.wait([
        settingsProvider.loadSettings(),
        transactionProvider.loadTransactions(),
        expenseGroupProvider.loadExpenseGroups(),
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Data loading timed out');
          throw Exception('Data loading timed out');
        },
      );
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  void _showAddTransactionMenu() {
    final groupProvider = Provider.of<ExpenseGroupProvider>(context, listen: false);
    final groups = groupProvider.groups;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Transaction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Add to General'),
                subtitle: const Text('Transaction without group'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTransactionScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add to Group',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddGroupScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.create_new_folder, size: 16),
                    label: const Text('Create New Group'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (groups.isNotEmpty) ...[
                ...groups.map((group) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      Icons.folder,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  title: Text(group.name),
                  subtitle: Text(group.description ?? 'No description'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTransactionScreen(
                          initialGroupId: group.id,
                        ),
                      ),
                    );
                  },
                )),
              ] else ...[
                const ListTile(
                  leading: Icon(Icons.folder_open, color: Colors.grey),
                  title: Text('No groups yet'),
                  subtitle: Text('Create your first group to organize expenses'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true, // Allow body to scroll behind bottom navigation
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildNavIcon(0, Icons.home_outlined, Icons.home, 'Home')),
                  Expanded(child: _buildNavIcon(1, Icons.list_alt_outlined, Icons.list_alt, 'Transactions')),
                  
                  // Central Floating + Action
                  GestureDetector(
                    onTap: _showAddTransactionMenu,
                    child: Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.blue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  ),
                  
                  Expanded(child: _buildNavIcon(2, Icons.folder_outlined, Icons.folder, 'Groups')),
                  Expanded(child: _buildNavIcon(3, Icons.settings_outlined, Icons.settings, 'Settings')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(int index, IconData outlineIcon, IconData solidIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? solidIcon : outlineIcon,
              color: isSelected ? Colors.blue : Colors.grey.shade400,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.blue : Colors.grey.shade500,
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
            softWrap: false,
          ),
        ],
      ),
    );
  }
} 
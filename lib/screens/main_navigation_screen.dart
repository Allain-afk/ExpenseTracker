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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionMenu,
        child: const Icon(Icons.add),
      ),
    );
  }
} 
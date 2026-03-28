import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_group_provider.dart';
import '../providers/settings_provider.dart';
import '../models/expense_group.dart';
import '../widgets/inset_grouped_list.dart';
import 'group_detail_screen.dart';
import 'add_group_screen.dart';
import 'add_transaction_screen.dart';
import '../utils/app_theme.dart';

class ExpenseGroupsScreen extends StatefulWidget {
  const ExpenseGroupsScreen({super.key});

  @override
  State<ExpenseGroupsScreen> createState() => _ExpenseGroupsScreenState();
}

class _ExpenseGroupsScreenState extends State<ExpenseGroupsScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadGroups();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadGroups();
    }
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<ExpenseGroupProvider>(
        context,
        listen: false,
      ).loadExpenseGroups();
    } catch (e) {
      debugPrint('Error loading expense groups in screen: $e');
    }
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
                : const ExpenseGroupsContent(),
      ),
    );
  }
}

class ExpenseGroupsContent extends StatelessWidget {
  const ExpenseGroupsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseGroupProvider, SettingsProvider>(
      builder: (context, groupProvider, settingsProvider, child) {
        final currencySymbol = settingsProvider.currencySymbol;
        final groups = groupProvider.groups;

        Widget content;
        if (groups.isEmpty) {
          content = SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No expense groups yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first expense group to organize your expenses',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        } else {
          content = SliverPadding(
            padding: const EdgeInsets.only(bottom: 104, top: 16),
            sliver: SliverToBoxAdapter(
              child: InsetGroupedList(
                children:
                    groups.map((group) {
                      final total = groupProvider.getGroupTotal(group.id!);
                      final transactionCount =
                          groupProvider.getGroupTransactions(group.id!).length;

                      return Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            ListTile(
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
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (group.description != null &&
                                      group.description!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 4,
                                        bottom: 4,
                                      ),
                                      child: Text(
                                        group.description!,
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        size: 14,
                                        color: Colors.green.shade600,
                                      ),
                                      Text(
                                        NumberFormat.currency(
                                          symbol: currencySymbol,
                                        ).format(total),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade600,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.receipt_long,
                                        size: 14,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$transactionCount txs',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => AddTransactionScreen(
                                                initialGroupId: group.id,
                                              ),
                                        ),
                                      );
                                      if (result == true) {
                                        await groupProvider.loadExpenseGroups();
                                      }
                                    },
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_horiz,
                                      color: Colors.grey.shade400,
                                    ),
                                    onSelected: (value) async {
                                      switch (value) {
                                        case 'edit':
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => AddGroupScreen(
                                                    group: group,
                                                  ),
                                            ),
                                          );
                                          if (result == true) {
                                            await groupProvider
                                                .loadExpenseGroups();
                                          }
                                          break;
                                        case 'delete':
                                          _showDeleteConfirmation(
                                            context,
                                            group,
                                            groupProvider,
                                          );
                                          break;
                                      }
                                    },
                                    itemBuilder:
                                        (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_outlined),
                                                SizedBox(width: 12),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            GroupDetailScreen(group: group),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await groupProvider.loadExpenseGroups();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                primary: false,
                title: const Text('Groups'),
                pinned: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add, color: AppTheme.primary),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddGroupScreen(),
                        ),
                      );
                      if (result == true) {
                        groupProvider.loadExpenseGroups();
                      }
                    },
                  ),
                ],
              ),
              content,
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ExpenseGroup group,
    ExpenseGroupProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Group'),
          content: Text(
            'Are you sure you want to delete "${group.name}"? This will remove all transactions from this group.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await provider.deleteExpenseGroup(group.id!);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

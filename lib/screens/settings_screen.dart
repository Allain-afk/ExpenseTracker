import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/settings.dart';
import '../widgets/inset_grouped_list.dart';
import 'manage_wallets_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverAppBar(
                title: Text('Settings'),
                pinned: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 80, top: 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      InsetGroupedList(
                        headerText: 'PREFERENCES',
                        children: [
                          _buildSettingsTile(
                            icon: Icons.currency_exchange,
                            iconColor: Colors.green,
                            title: 'Currency',
                            subtitle: '${settingsProvider.settings.currency} (${settingsProvider.settings.currencySymbol})',
                            onTap: () => _showCurrencySelector(context, settingsProvider),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      InsetGroupedList(
                        headerText: 'CARDS & WALLETS',
                        children: [
                          _buildSettingsTile(
                            icon: Icons.credit_card,
                            iconColor: Colors.blueAccent,
                            title: 'Manage Cards',
                            subtitle: 'Add, edit, or remove wallets',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageWalletsScreen()));
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      InsetGroupedList(
                        headerText: 'NOTIFICATIONS',
                        children: [
                          Container(
                            color: Colors.white,
                            child: SwitchListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              secondary: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.notifications_active, color: Colors.white, size: 18),
                              ),
                              title: const Text('Low Balance Alerts', style: TextStyle(fontSize: 16)),
                              subtitle: const Text('Get notified when balance is low'),
                              value: settingsProvider.notificationsEnabled,
                              onChanged: (value) {
                                settingsProvider.updateNotificationSettings(
                                  notificationsEnabled: value,
                                );
                              },
                            ),
                          ),
                          if (settingsProvider.notificationsEnabled) ...[
                            _buildSettingsTile(
                              icon: Icons.account_balance_wallet,
                              iconColor: Colors.blueGrey,
                              title: 'Threshold Amount',
                              subtitle: '${settingsProvider.currencySymbol}${settingsProvider.lowBalanceThreshold.toStringAsFixed(2)}',
                              onTap: () => _showThresholdEditor(context, settingsProvider),
                            ),
                            _buildSettingsTile(
                              icon: Icons.message,
                              iconColor: Colors.indigo,
                              title: 'Alert Message',
                              subtitle: settingsProvider.notificationMessage,
                              onTap: () => _showMessageEditor(context, settingsProvider),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      InsetGroupedList(
                        headerText: 'DATA MANAGEMENT',
                        children: [
                          _buildSettingsTile(
                            icon: Icons.delete_forever,
                            iconColor: Colors.red,
                            title: 'Reset All App Data',
                            subtitle: 'Delete all transactions and reset settings',
                            titleColor: Colors.red,
                            onTap: () => _showResetAllDataDialog(context, settingsProvider),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      InsetGroupedList(
                        headerText: 'ABOUT',
                        children: [
                          _buildSettingsTile(
                            icon: Icons.info_outline,
                            iconColor: Colors.blue,
                            title: 'Version',
                            subtitle: '1.2.0',
                            onTap: () => _showVersionHistory(context),
                          ),
                          _buildSettingsTile(
                            icon: Icons.person_outline,
                            iconColor: Colors.purple,
                            title: 'Developer',
                            subtitle: 'Allain Ralph Legaspi',
                            showChevron: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    bool showChevron = true,
    VoidCallback? onTap,
  }) {
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: titleColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: showChevron ? const Icon(Icons.chevron_right, color: Colors.grey) : null,
        onTap: onTap,
      ),
    );
  }

  void _showCurrencySelector(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
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
                'Select Currency',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: CurrencyOption.availableCurrencies.length,
                  itemBuilder: (context, index) {
                    final currency = CurrencyOption.availableCurrencies[index];
                    final isSelected =
                        currency.code == settingsProvider.settings.currency;

                    return ListTile(
                      title: Text(currency.name),
                      subtitle: Text('${currency.code} (${currency.symbol})'),
                      trailing:
                          isSelected
                              ? const Icon(Icons.check, color: Colors.blue)
                              : null,
                      onTap: () {
                        settingsProvider.updateCurrency(
                          currency.code,
                          currency.symbol,
                        );
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResetAllDataDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Reset All App Data'),
            ],
          ),
          content: const Text(
            'This will permanently delete:\n\n'
            '• All your transactions\n'
            '• All app settings\n'
            '• All stored data\n\n'
            'This action cannot be undone. Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) => const AlertDialog(
                        content: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('Resetting app data...'),
                          ],
                        ),
                      ),
                );

                // Reset all app data
                await settingsProvider.resetAllAppData();

                // Reload transaction provider to reflect changes
                if (context.mounted) {
                  await Provider.of<TransactionProvider>(
                    context,
                    listen: false,
                  ).loadTransactions();

                  // Close loading dialog
                  Navigator.pop(context);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All app data has been reset successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text(
                'Reset All Data',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showThresholdEditor(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    final controller = TextEditingController(
      text: settingsProvider.lowBalanceThreshold.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Low Balance Threshold'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Threshold Amount',
                prefixText: '${settingsProvider.currencySymbol} ',
                border: const OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final amount = double.tryParse(controller.text);
                  if (amount != null && amount >= 0) {
                    settingsProvider.updateNotificationSettings(
                      lowBalanceThreshold: amount,
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid amount'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showMessageEditor(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    final controller = TextEditingController(
      text: settingsProvider.notificationMessage,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Notification Message'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Custom Message',
                    hintText: 'Use {name} as placeholder for your name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tip: Use {name} in your message to include your name',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    settingsProvider.updateNotificationSettings(
                      notificationMessage: controller.text.trim(),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a message'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showVersionHistory(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.history, color: Colors.blue),
                SizedBox(width: 8),
                Text('Version History'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: const [
                        _VersionHistoryItem(
                          version: '1.2.0',
                          title: 'New user UI/UX functionalities',
                          description:
                              '• Added a notification system for low budget threshold\n• Personalized notifications with user name\n• Customizable notification settings',
                          isLatest: true,
                        ),
                        _VersionHistoryItem(
                          version: '1.0.3',
                          title:
                              'App Animation Feature (Splash Screen) when opened',
                          description:
                              '• Beautiful animated splash screen\n• Smooth transitions and loading animations',
                        ),
                        _VersionHistoryItem(
                          version: '1.0.2',
                          title: 'UI and UX Improvements',
                          description:
                              '• Enhanced user interface design\n• Better user experience\n• Performance optimizations',
                        ),
                        _VersionHistoryItem(
                          version: '1.0.1',
                          title: 'App Icon Update',
                          description:
                              '• New and improved app icon\n• Better visual identity',
                        ),
                        _VersionHistoryItem(
                          version: '1.0.0',
                          title: 'Basic Features for Expense Tracking',
                          description:
                              '• Core expense tracking functionality\n• Transaction management\n• Basic reporting features',
                          isDeprecated: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

class _VersionHistoryItem extends StatelessWidget {
  final String version;
  final String title;
  final String description;
  final bool isLatest;
  final bool isDeprecated;

  const _VersionHistoryItem({
    required this.version,
    required this.title,
    required this.description,
    this.isLatest = false,
    this.isDeprecated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isLatest ? 4 : 1,
      color:
          isLatest
              ? Colors.blue.shade50
              : isDeprecated
              ? Colors.grey.shade100
              : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isLatest
                            ? Colors.blue
                            : isDeprecated
                            ? Colors.grey
                            : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'v$version',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isLatest)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'LATEST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isDeprecated)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'DEPRECATED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDeprecated ? Colors.grey.shade600 : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color:
                    isDeprecated ? Colors.grey.shade500 : Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

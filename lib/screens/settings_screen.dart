import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Currency',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Select Currency'),
                        subtitle: Text(
                          '${settingsProvider.settings.currency} (${settingsProvider.settings.currencySymbol})',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showCurrencySelector(context, settingsProvider),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Low Balance Notifications'),
                        subtitle: const Text('Get notified when balance is low'),
                        value: settingsProvider.notificationsEnabled,
                        onChanged: (value) {
                          settingsProvider.updateNotificationSettings(
                            notificationsEnabled: value,
                          );
                        },
                      ),
                      if (settingsProvider.notificationsEnabled) ...[
                        ListTile(
                          title: const Text('Low Balance Threshold'),
                          subtitle: Text(
                            '${settingsProvider.currencySymbol}${settingsProvider.lowBalanceThreshold.toStringAsFixed(2)}',
                          ),
                          trailing: const Icon(Icons.edit),
                          onTap: () => _showThresholdEditor(context, settingsProvider),
                        ),
                        ListTile(
                          title: const Text('Notification Message'),
                          subtitle: Text(
                            settingsProvider.notificationMessage,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.edit),
                          onTap: () => _showMessageEditor(context, settingsProvider),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'App Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Version'),
                        subtitle: const Text('1.2.0'),
                        leading: const Icon(Icons.info_outline),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showVersionHistory(context),
                      ),
                      const ListTile(
                        title: Text('Developer'),
                        subtitle: Text('Allain Ralph Legaspi'),
                        leading: Icon(Icons.person_outline),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Data Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text(
                          'Reset All App Data',
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: const Text('Delete all transactions and reset settings'),
                        leading: const Icon(Icons.delete_forever, color: Colors.red),
                        onTap: () => _showResetAllDataDialog(context, settingsProvider),
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

  void _showCurrencySelector(BuildContext context, SettingsProvider settingsProvider) {
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: CurrencyOption.availableCurrencies.length,
                  itemBuilder: (context, index) {
                    final currency = CurrencyOption.availableCurrencies[index];
                    final isSelected = currency.code == settingsProvider.settings.currency;
                    
                    return ListTile(
                      title: Text(currency.name),
                      subtitle: Text('${currency.code} (${currency.symbol})'),
                      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                      onTap: () {
                        settingsProvider.updateCurrency(currency.code, currency.symbol);
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

  void _showResetAllDataDialog(BuildContext context, SettingsProvider settingsProvider) {
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
            'This action cannot be undone. Are you sure you want to continue?'
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
                  builder: (context) => const AlertDialog(
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
                  await Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
                  
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

  void _showThresholdEditor(BuildContext context, SettingsProvider settingsProvider) {
    final controller = TextEditingController(
      text: settingsProvider.lowBalanceThreshold.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  void _showMessageEditor(BuildContext context, SettingsProvider settingsProvider) {
    final controller = TextEditingController(
      text: settingsProvider.notificationMessage,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      builder: (context) => AlertDialog(
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
                      description: '• Added a notification system for low budget threshold\n• Personalized notifications with user name\n• Customizable notification settings',
                      isLatest: true,
                    ),
                    _VersionHistoryItem(
                      version: '1.0.3',
                      title: 'App Animation Feature (Splash Screen) when opened',
                      description: '• Beautiful animated splash screen\n• Smooth transitions and loading animations',
                    ),
                    _VersionHistoryItem(
                      version: '1.0.2',
                      title: 'UI and UX Improvements',
                      description: '• Enhanced user interface design\n• Better user experience\n• Performance optimizations',
                    ),
                    _VersionHistoryItem(
                      version: '1.0.1',
                      title: 'App Icon Update',
                      description: '• New and improved app icon\n• Better visual identity',
                    ),
                    _VersionHistoryItem(
                      version: '1.0.0',
                      title: 'Basic Features for Expense Tracking',
                      description: '• Core expense tracking functionality\n• Transaction management\n• Basic reporting features',
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
      color: isLatest 
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLatest 
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                color: isDeprecated ? Colors.grey.shade500 : Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
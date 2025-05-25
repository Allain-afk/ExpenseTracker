import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';

class UserSetupScreen extends StatefulWidget {
  const UserSetupScreen({super.key});

  @override
  State<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends State<UserSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _thresholdController = TextEditingController(text: '1000');
  final _messageController = TextEditingController(
    text: 'Hey {name}! Slow down on spending! You are now low on budget. You dumbass!',
  );
  bool _notificationsEnabled = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _thresholdController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      
      // Initialize notification service
      if (_notificationsEnabled) {
        await NotificationService().initialize();
      }

      // Save user settings
      await settingsProvider.updateUserSettings(
        userName: _nameController.text.trim(),
        notificationsEnabled: _notificationsEnabled,
        lowBalanceThreshold: double.parse(_thresholdController.text),
        notificationMessage: _messageController.text.trim(),
      );

      // Mark setup as complete
      await settingsProvider.markSetupComplete();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Welcome! 👋',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s set up your expense tracker with personalized notifications',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Name input
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    hintText: 'Enter your name for personalized notifications',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Notifications toggle
                Card(
                  child: SwitchListTile(
                    title: const Text('Enable Low Balance Notifications'),
                    subtitle: const Text('Get notified when your balance is getting low'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    secondary: const Icon(Icons.notifications),
                  ),
                ),
                const SizedBox(height: 16),

                // Threshold input
                if (_notificationsEnabled) ...[
                  TextFormField(
                    controller: _thresholdController,
                    decoration: const InputDecoration(
                      labelText: 'Low Balance Threshold',
                      hintText: 'Amount that triggers notification',
                      prefixIcon: Icon(Icons.warning),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a threshold amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount < 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Custom message input
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Notification Message',
                      hintText: 'Use {name} as placeholder for your name',
                      prefixIcon: Icon(Icons.message),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a notification message';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tip: Use {name} in your message to include your name',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],

                const Spacer(),

                // Complete setup button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeSetup,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Complete Setup',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
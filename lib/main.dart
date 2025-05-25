import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/transaction_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/user_setup_screen.dart';
import 'services/widget_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize widget service
  await WidgetService.initializeWidget();
  await WidgetService.registerBackgroundCallback();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
        ],
        home: const SplashScreen(),
        routes: {
          '/add': (context) => const AddTransactionScreen(),
          '/setup': (context) => const UserSetupScreen(),
        },
      ),
    );
  }
}

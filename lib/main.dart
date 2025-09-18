import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'screens/navigation/main_navigation.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env.dev"); // switch to .env.prod in release

  // Get base URL from environment
  final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
  
  // Initialize ApiClient with BASE_URL from .env
  final apiClient = ApiClient(baseUrl: baseUrl);

  // Set the base URL for AuthService so it can make refresh token calls
  AuthService().setBaseUrl(baseUrl);
  
  // Initialize AuthService to check existing auth state
  await AuthService().initialize();

  runApp(LocalLoopApp(apiClient: apiClient));
}

class LocalLoopApp extends StatelessWidget {
  final ApiClient apiClient;

  const LocalLoopApp({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocalLoop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      // Pass ApiClient down to MainNavigation
      home: MainNavigation(apiClient: apiClient),
    );
  }
}
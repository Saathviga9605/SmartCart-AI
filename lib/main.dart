import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/datasources/hive_service.dart';
import 'data/repositories/grocery_repository_impl.dart';
import 'presentation/providers/grocery_provider.dart';
import 'presentation/providers/voice_provider.dart';
import 'presentation/providers/ml_inference_provider.dart';
import 'presentation/providers/smartpantry_provider.dart';
import 'presentation/providers/recipe_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();

  runApp(SmartCartApp(hiveService: hiveService));
}

class SmartCartApp extends StatelessWidget {
  final HiveService hiveService;

  const SmartCartApp({super.key, required this.hiveService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Hive Service (Singleton)
        Provider<HiveService>.value(value: hiveService),

        // Repository
        Provider<GroceryRepositoryImpl>(
          create: (context) => GroceryRepositoryImpl(hiveService),
        ),

        // Providers
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(hiveService),
        ),
        ChangeNotifierProvider<GroceryProvider>(
          create: (context) => GroceryProvider(
            context.read<GroceryRepositoryImpl>(),
          ),
        ),
        ChangeNotifierProvider<VoiceProvider>(
          create: (context) => VoiceProvider(),
        ),
        ChangeNotifierProvider<MLInferenceProvider>(
          create: (context) => MLInferenceProvider()..loadModel(),
        ),
        ChangeNotifierProvider<SmartPantryProvider>(
          create: (context) => SmartPantryProvider(),
        ),
        ChangeNotifierProvider<RecipeProvider>(
          create: (context) => RecipeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

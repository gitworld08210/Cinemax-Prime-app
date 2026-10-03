import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/core/app_theme.dart';
import 'ui/features/home/views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system navigation overlay style for authentic Netflix pitch-black theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.canvas,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const CinemaxPrimeApp());
}

class CinemaxPrimeApp extends StatelessWidget {
  const CinemaxPrimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CINEMAX PRIME',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}

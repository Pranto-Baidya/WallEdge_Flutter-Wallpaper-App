
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/riverpod/theme_riverpod.dart';
import 'package:learning_riverpod/screens/splash_screen.dart';
import 'package:learning_riverpod/theme_data.dart';

main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'api_key/api_key.env');
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      themeMode: themeState,
      theme: lightTheme,
      darkTheme: darkTheme,
    );
  }
}

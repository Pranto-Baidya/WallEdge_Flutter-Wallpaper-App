import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/screens/main_screen.dart';

import '../riverpod/theme_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {

  @override
  void initState() {
    Future.delayed(Duration(seconds: 3)).then((_){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MainScreen()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider)==ThemeMode.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: isDark? Colors.black:Colors.white,
            systemNavigationBarDividerColor: Colors.transparent,
            statusBarIconBrightness: isDark? Brightness.light: Brightness.dark
        ),
        toolbarHeight: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isDark? ClipOval(child: Image.asset('assets/wIcon.png',fit: BoxFit.contain,width: 150,height: 150,))
                :ClipOval(child: Image.asset('assets/icon.png',fit: BoxFit.contain,width: 150,height: 150,)),
            SizedBox(height: 20,),
            Text('WallEdge',style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),)
          ],
        ),
      ),
    );
  }
}
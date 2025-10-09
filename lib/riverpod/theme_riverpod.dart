
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier,ThemeMode>((ref)=>ThemeNotifier());

class ThemeNotifier extends StateNotifier<ThemeMode>{

  ThemeNotifier() : super(ThemeMode.light){
    _loadTheme();
  }

  Future<void> _loadTheme()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final isDark = preferences.getBool('theme') ?? false;
    state = isDark? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setTheme(bool isDark)async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool('theme', isDark);
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
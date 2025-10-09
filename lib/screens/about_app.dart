import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/riverpod/theme_riverpod.dart';

class AboutApp extends ConsumerWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('About WallEdge', style: theme.textTheme.titleLarge),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: theme.dividerColor,
                spreadRadius: 0,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
          statusBarColor: Colors.transparent,
          systemNavigationBarColor:
          isDark ? Colors.black : Colors.white,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🖼️ About WallEdge',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'WallEdge is a modern wallpaper app designed to bring high-quality, curated images right to your device — with simplicity, speed, and personalization at its core. '
                  'Built using Flutter and powered by the Riverpod state management system, WallEdge offers a smooth, responsive, and beautifully adaptive experience for both light and dark themes.\n\n'
                  'With WallEdge, you can explore and download breathtaking wallpapers, discover trending visuals, and even enjoy a growing library of videos — all within a sleek, minimal UI that focuses on what matters most: your content.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              '🌟 Key Features',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '• Smart Search: Instantly find wallpapers that match your vibe.\n'
                  '• High-Quality Images: Access stunning, high-resolution wallpapers optimized for your device.\n'
                  '• Favorites: Save and manage your favorite wallpapers for quick access.\n'
                  '• Watch Videos: Elevate your mood with amazing videos everyday.\n'
                  '• Light & Dark Mode: Automatically adjusts to your theme preference for a seamless look.\n'
                  '• Offline Friendly: Handles connectivity changes gracefully, so you stay in control.\n',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              '💡 Why WallEdge?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'WallEdge isn’t just another wallpaper app — it’s a carefully crafted experience focused on usability, performance, and aesthetic balance. '
                  'Whether you prefer minimalist designs, vivid art, or nature photography, WallEdge gives your device a fresh, personalized look every day.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '📱 Made with ❤️ By Pranto Baidya',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

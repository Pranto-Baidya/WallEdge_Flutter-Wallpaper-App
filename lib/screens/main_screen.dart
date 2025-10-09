import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/screens/category_screen.dart';
import 'package:learning_riverpod/screens/favorite_screen.dart';
import 'package:learning_riverpod/screens/home.dart';

final countProvider = StateProvider<int>((ref)=>0);

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {

    final count = ref.watch(countProvider);

    return Scaffold(
      body: IndexedStack(
        index: count,
        children: [
          Home(),
          CategoryScreen(),
          FavoriteScreen()
        ],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).dividerColor,
                  spreadRadius: 0,
                  blurRadius: 2,
                  offset: Offset(0, -1)
              )
            ]
        ),
        child: NavigationBar(
            labelPadding: EdgeInsets.zero,
            labelTextStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.labelMedium!),
            maintainBottomViewPadding: true,
            height: 55,
            backgroundColor: Theme.of(context).cardColor,
            selectedIndex: count,
            indicatorColor: Colors.transparent,
            onDestinationSelected: (value){
              ref.read(countProvider.notifier).state = value;
            },
            destinations: [
              NavigationDestination(
                  selectedIcon: Icon(Icons.grid_view_rounded,color: Theme.of(context).colorScheme.onPrimary,),
                  icon: Icon(Icons.grid_view,color: Theme.of(context).colorScheme.onPrimary,),
                  label: 'Wallpapers'
              ),
              NavigationDestination(
                  selectedIcon: Icon(Icons.category,color: Theme.of(context).colorScheme.onPrimary,),
                  icon: Icon(Icons.category_outlined,color: Theme.of(context).colorScheme.onPrimary,),
                  label: 'Categories'
              ),
              NavigationDestination(
                  selectedIcon: Icon(Icons.favorite,color: Theme.of(context).colorScheme.onPrimary,),
                  icon: Icon(Icons.favorite_border,color: Theme.of(context).colorScheme.onPrimary,),
                  label: 'Favorites'
              ),
            ]
        ),
      ),
    );
  }
}
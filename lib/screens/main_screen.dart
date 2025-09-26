
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
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 0,
                  blurRadius: 3,
                  offset: Offset(0, -1)
              )
            ]
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          selectedIndex: count,
          indicatorColor: Colors.grey.shade200,
          onDestinationSelected: (value){
            ref.read(countProvider.notifier).state = value;
          },
            destinations: [
              NavigationDestination(
                  selectedIcon: Icon(Icons.grid_view_rounded,color: Colors.black,),
                  icon: Icon(Icons.grid_view,color: Colors.black,),
                  label: 'Wallpapers'
              ),
              NavigationDestination(
                  selectedIcon: Icon(Icons.dashboard,color: Colors.black,),
                  icon: Icon(Icons.dashboard_outlined,color: Colors.black,),
                  label: 'Categories'
              ),
              NavigationDestination(
                  selectedIcon: Icon(Icons.favorite,color: Colors.black,),
                  icon: Icon(Icons.favorite_border,color: Colors.black,),
                  label: 'Favorites'
              ),
            ]
        ),
      ),
    );
  }
}

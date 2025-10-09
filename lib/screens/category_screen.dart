import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/screens/specific_category_screen.dart';

import '../riverpod/theme_riverpod.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  List<String> categories = [
    'Abstract',
    'Animal',
    'Building',
    'Car',
    'Cute',
    'Gradient',
    'Galaxy',
    'Logo',
    'Minimal',
    'Mountain',
    'Nature',
    'Quote',
    'Sea',
    'Sport',
    'TextTile',
    '3D'
  ];

  List<String> urls = [
    'https://images.pexels.com/photos/3780104/pexels-photo-3780104.png',
    'https://images.pexels.com/photos/45170/kittens-cat-cat-puppy-rush-45170.jpeg',
    'https://images.pexels.com/photos/1722183/pexels-photo-1722183.jpeg',
    'https://images.pexels.com/photos/164634/pexels-photo-164634.jpeg',
    'https://images.pexels.com/photos/1767434/pexels-photo-1767434.jpeg',
    'https://images.pexels.com/photos/281260/pexels-photo-281260.jpeg',
    'https://images.pexels.com/photos/4994765/pexels-photo-4994765.png',
    'https://images.pexels.com/photos/2417848/pexels-photo-2417848.jpeg',
    'https://images.pexels.com/photos/62693/pexels-photo-62693.jpeg',
    'https://images.pexels.com/photos/9754/mountains-clouds-forest-fog.jpg',
    'https://images.pexels.com/photos/2325447/pexels-photo-2325447.jpeg',
    'https://images.pexels.com/photos/2681319/pexels-photo-2681319.jpeg',
    'https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg',
    'https://images.pexels.com/photos/46798/the-ball-stadion-football-the-pitch-46798.jpeg',
    'https://images.pexels.com/photos/276267/pexels-photo-276267.jpeg',
    'https://images.pexels.com/photos/5011647/pexels-photo-5011647.jpeg'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider)==ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 60,
        title: Text(
          'Categories',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: isDark? Brightness.light: Brightness.dark,
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: isDark? Colors.black:Colors.white,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).dividerColor,
                spreadRadius: 0,
                blurRadius: 3,
                offset: Offset(0, 1),
              )
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.01,),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 10,
                childAspectRatio: 2,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final data = urls[index];
                return GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SpecificCategoryScreen(
                        categoryName: categories[index]))
                    );
                  },
                  child: Card(
                    shadowColor: isDark? Colors.white12 : Colors.black54,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: data,
                            fadeInDuration: const Duration(milliseconds: 500),
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary),
                            ),
                            errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                        Center(
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
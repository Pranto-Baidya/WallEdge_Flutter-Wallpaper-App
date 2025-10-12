import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/riverpod/favorite_riverpod.dart';
import 'package:learning_riverpod/widgets/animated_view.dart';
import '../riverpod/theme_riverpod.dart';
import 'image_screen.dart';

final searchFavProvider = StateProvider<bool>((ref)=> false);
final showSearchedResultsForBody = StateProvider<bool>((ref)=>false);

class FavoriteScreen extends ConsumerStatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends ConsumerState<FavoriteScreen> {

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      ref.read(favPhotoNotifier.notifier).getAllPhotos();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final favState = ref.watch(favPhotoNotifier);
    final favNotifier = ref.read(favPhotoNotifier.notifier);

    final isSearching = ref.watch(searchFavProvider);
    final isShowingSearchedResults = ref.watch(showSearchedResultsForBody);

    final isDark = ref.watch(themeProvider)==ThemeMode.dark;

    final showData = isShowingSearchedResults? favState.searchFavPhotos : favState.favPhotos;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 60,
        title: isSearching?
        TextField(
          autofocus: true,
          controller: _searchController,
          cursorColor: Theme.of(context).colorScheme.onPrimary,
          decoration: InputDecoration(
              prefixIcon: IconButton(
                  onPressed:(){
                    ref.read(searchFavProvider.notifier).state = false;
                    ref.read(showSearchedResultsForBody.notifier).state=false;
                    _searchController.clear();
                  },
                  icon: Icon(Icons.arrow_back,color: Theme.of(context).colorScheme.onPrimary,)
              ),
              hintText: 'Find in favorites',
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none
              )
          ),
          onChanged: (value){
            ref.read(showSearchedResultsForBody.notifier).state=true;
            favNotifier.getSearchedPhotos(value);
          },
        )
            :Text(
          'Favorites',
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
        actions: [
          Visibility(
            visible: !isSearching,
            replacement: SizedBox.shrink(),
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                  onPressed: (){
                    ref.read(searchFavProvider.notifier).state = true;
                  },
                  icon: Icon(Icons.search,color: Theme.of(context).colorScheme.onPrimary,)
              ),
            ),
          )
        ],
      ),
      body:  showData.isEmpty
          ? Center(
        child: Text(
          !isSearching ? "No favorites yet" : _searchController.text.isEmpty ? "" : "No results found",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      )
          : CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.03, vertical: height * 0.02),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {

                final data = showData[index];

                return Card(
                  color: Theme.of(context).cardColor,
                  shadowColor: isDark? Colors.white12 : Colors.black54,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageScreen(photo: data,heroTag: data.id.toString(),),
                        ),
                      );
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimatedScrollItem(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Hero(
                              tag: data.id.toString(),
                              child: CachedNetworkImage(
                                imageUrl: data.srcOriginal ?? "",
                                fadeInDuration:
                                const Duration(milliseconds: 500),
                                fit: BoxFit.cover,
                                placeholder: (context, url) {
                                  return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary,));
                                },
                                errorWidget: (context, error, st) =>
                                const Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: IconButton(
                            onPressed: () async {
                              await favNotifier.toggleFavPhoto(data);
                            },
                            icon: Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
                childCount: showData.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 10,
                childAspectRatio: 0.58,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
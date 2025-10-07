
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/riverpod/favorite_riverpod.dart';
import 'image_screen.dart';

final searchFavProvider = StateProvider<bool>((ref)=> false);

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

    final showData = isSearching? favState.searchFavPhotos : favState.favPhotos;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 50,
        title: isSearching?
            TextField(
              autofocus: true,
              controller: _searchController,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                  prefixIcon: IconButton(
                      onPressed:(){
                        ref.read(searchFavProvider.notifier).state = false;
                        _searchController.clear();
                        favState.searchFavPhotos.clear();
                      },
                      icon: Icon(Icons.arrow_back,color: Colors.black,)
                  ),
                  hintText: 'Find in favorites',
                  hintStyle: TextStyle(color: Colors.black87),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none
                  )
              ),
              onChanged: (value){
                favNotifier.getSearchedPhotos(value);
              },
            )
        :Text(
          'Favorites',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
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
                  icon: Icon(Icons.search,color: Colors.black,)
              ),
            ),
          )
        ],
      ),
      body:  showData.isEmpty
          ? Center(
        child: Text(
          !isSearching ? "No favorites yet" : _searchController.text.isEmpty ? "" : "No results found",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      )
          : CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.03, vertical: height * 0.02),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {

                  final data = showData[index];

                  return Card(
                    color: Colors.white,
                    shadowColor: Colors.black54,
                    elevation: 5,
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Hero(
                              tag: data.id.toString(),
                              child: CachedNetworkImage(
                                imageUrl: data.srcOriginal ?? "",
                                fadeInDuration:
                                const Duration(milliseconds: 500),
                                fit: BoxFit.cover,
                                placeholder: (context, url) {
                                  return CachedNetworkImage(
                                    imageUrl : data.srcMedium ?? "",
                                    fit: BoxFit.cover,
                                  );
                                },
                                errorWidget: (context, error, st) =>
                                const Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
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
                childAspectRatio: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

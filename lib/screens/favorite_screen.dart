
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/models/photo_model.dart';
import 'package:learning_riverpod/riverpod/favorite_riverpod.dart';

import '../widgets/dialogue helper.dart';
import 'image_screen.dart';

class FavoriteScreen extends ConsumerStatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends ConsumerState<FavoriteScreen> {

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 50,
        title: Text(
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
          PopupMenuButton(
             popUpAnimationStyle: AnimationStyle(
               curve: Curves.decelerate
             ),
              icon: Icon(Icons.more_vert,color: Colors.black,),
              menuPadding: EdgeInsets.only(left: 10,right: 20,top: 10,bottom: 10),
              color: Colors.black,
              itemBuilder: (context){
                return [
                  PopupMenuItem(
                      onTap: (){
                        Alert.dialogue(context, 'Coming Soon!', 'Change log will appear soon, Stay tuned.',null);
                      },
                      child: Text('Change Log',style: TextStyle(fontSize: 16,color: Colors.white))
                  ),
                  PopupMenuItem(
                      onTap: (){

                      },
                      child: Text('Future updates',style: TextStyle(fontSize: 16,color: Colors.white))
                  ),
                ];
              }
          )

        ],
      ),
      body: favState.favPhotos.isEmpty
          ? Center(
        child: Text(
          "No favorites yet",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      )
          : CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.02, vertical: height * 0.02),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final data = favState.favPhotos[index];
                  return Card(
                    color: Colors.white,
                    shadowColor: Colors.black45,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                            borderRadius: BorderRadius.circular(10),
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
                            top: 5,
                            right: 5,
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
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: Text(
                              'By : ${data.photographer}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: favState.favPhotos.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.65,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

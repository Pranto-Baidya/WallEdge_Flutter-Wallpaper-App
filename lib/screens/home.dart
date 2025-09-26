import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/models/photo_model.dart';
import 'package:learning_riverpod/riverpod/favorite_riverpod.dart';
import 'package:learning_riverpod/screens/image_screen.dart';
import 'package:learning_riverpod/riverpod/photo_riverpod.dart';
import 'package:learning_riverpod/widgets/dialogue%20helper.dart';

final searchProvider = StateProvider<bool>((ref)=>false);

final searchWallpaperProvider = StateNotifierProvider<PhotoNotifier,PhotoState>((ref)=>PhotoNotifier());

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  _HomeState  createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(mounted){
        ref.read(photoNotifierProvider.notifier).fetchInitialPhotos();
      }
    });
    super.initState();
  }

  final TextEditingController _searchController = TextEditingController();


  List<String> futureUpdates = [
    '•  More polished UI and UX',
    '•  Watch videos and download',
    '•  Improved searching',
    '•  Filtering options',
    '•  Bug fixes',
    '& many more...'
  ];

  @override
  Widget build(BuildContext context) {

    final isSearching = ref.watch(searchProvider);

    final photoState = ref.watch(photoNotifierProvider);

    final photoNotifier = ref.read(photoNotifierProvider.notifier);

    final searchState = ref.watch(searchWallpaperProvider);

    final searchNotifier = ref.read(searchWallpaperProvider.notifier);

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;


    return Scaffold(
      backgroundColor: Colors.white,
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
                    ref.read(searchProvider.notifier).state = false;
                    _searchController.clear();
                  },
                  icon: Icon(Icons.arrow_back,color: Colors.black,)
              ),
              hintText: 'Search for wallpapers',
              hintStyle: TextStyle(color: Colors.black87),
              border: OutlineInputBorder(
                borderSide: BorderSide.none
              ),
             enabledBorder: OutlineInputBorder(
               borderSide: BorderSide.none
             )
          ),
          onChanged: (value){
            ref.read(searchWallpaperProvider.notifier).searchWallpapers(value);
          },
        ):Text('WallEdge',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 28,color: Colors.black),),
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
                offset: Offset(0, 1)
              )
            ]
          ),
        ),
        actions: [
          isSearching?SizedBox.shrink():
          IconButton(
              onPressed: (){
                ref.read(searchProvider.notifier).state = true;
              }, 
              icon: Icon(Icons.search,color: Colors.black,)
          ),
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
                          Alert.dialogue(context, 'Future updates', futureUpdates.map((i)=>i).join('\n\n').toString(),10);

                      },
                      child: Text('Future updates',style: TextStyle(fontSize: 16,color: Colors.white))
                  ),
                ];
              }
          )

        ],
      ),
      body: RefreshIndicator(
        onRefresh: ()async{
          await photoNotifier.fetchInitialPhotos();
        },
        backgroundColor: Colors.black,
        color: Colors.white,
        child: Builder(
          builder: (context) {
            final showData = isSearching? searchState : photoState;

              if (showData.inProgress) {
                return const Center(child: CircularProgressIndicator(color: Colors.black,));
              }
              if (showData.error != null) {
                return Center(child: Text(photoState.error!));
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100 && !photoState.isLoadingMore) {
                    isSearching? searchNotifier.getMoreSearchedPhotos(_searchController.text) : photoNotifier.fetchMorePhotos();
                  }
                  return false;
                },
                child: CustomScrollView(
                  physics: ClampingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.02, vertical: height*0.02),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final data = showData.photos[index];
                            final heroTag = isSearching ? 'search-${data.id}_$index' : 'home-${data.id}_$index';

                            return Card(
                              color: Colors.white,
                              shadowColor: Colors.black45,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageScreen(
                                      photo: data,
                                      heroTag: heroTag,
                                  )));
                                },
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Hero(
                                        tag: heroTag,
                                        child: CachedNetworkImage(
                                          imageUrl : data.srcPortrait ?? '',
                                          fadeInDuration: const Duration(milliseconds: 500),
                                          fit: BoxFit.cover,
                                          placeholder: (context,url){
                                            return CachedNetworkImage(imageUrl : data.srcMedium ?? '',fit: BoxFit.cover,);
                                            },
                                          errorWidget: (context,error,st)=> const Icon(Icons.broken_image_outlined),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Consumer(
                                        builder: (context, ref, _) {
                                          final favState = ref.watch(favPhotoNotifier);
                                          final favNotifier = ref.read(favPhotoNotifier.notifier);

                                          final isFav = favState.favPhotos.any((p) => p.id == data.id);

                                          return IconButton(
                                            onPressed: () async {
                                              await favNotifier.toggleFavPhoto(data);
                                            },
                                            icon: AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 250),
                                              transitionBuilder: (child, anim) =>
                                                  ScaleTransition(scale: anim, child: child),
                                              child: Icon(
                                                isFav ? Icons.favorite : Icons.favorite_border,
                                                key: ValueKey(isFav),
                                                color: isFav ? Colors.white: Colors.white,
                                                size: isFav? 28:28,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    Positioned(
                                      bottom: 10,
                                        left: 10,
                                        child: Text('By : ${data.photographer}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,)
                                    )
                                  ]
                                ),
                              ),
                            );
                          },
                          childCount: showData.photos.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.65
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: showData.isLoadingMore
                          ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator(color: Colors.black,)),
                      )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
              },
        ),
      ),

    );
  }
}

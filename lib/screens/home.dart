import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/riverpod/favorite_riverpod.dart';
import 'package:learning_riverpod/riverpod/internet_connectivity_riverpod.dart';
import 'package:learning_riverpod/screens/image_screen.dart';
import 'package:learning_riverpod/riverpod/photo_riverpod.dart';
import 'package:learning_riverpod/screens/video_screen.dart';
import 'package:learning_riverpod/widgets/dialogue%20helper.dart';
import 'package:learning_riverpod/widgets/url_herlper.dart';

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
    '•  Light and Dark mode support',
    '•  Bug fixes',
    '& many more...'
  ];

  @override
  Widget build(BuildContext context) {

    ref.listen<InternetState>(internetProvider, (prev,next){
      if(next.isConnected){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              content: Text('Internet connection restored',style: TextStyle(color: Colors.white),)
          ),
        );
      }
    });

    final isSearching = ref.watch(searchProvider);

    final photoState = ref.watch(photoNotifierProvider);

    final photoNotifier = ref.read(photoNotifierProvider.notifier);

    final searchState = ref.watch(searchWallpaperProvider);

    final searchNotifier = ref.read(searchWallpaperProvider.notifier);

    final width = MediaQuery.of(context).size.width;

    final height = MediaQuery.of(context).size.height;

    final connectionState = ref.watch(internetProvider);

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
                    ref.read(searchProvider.notifier).state = false;
                    _searchController.clear();
                    searchState.photos.clear();
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
        ):Text('WallEdge',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 30,color: Colors.black),),
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
                          Alert.dialogue(context, 'Future updates', futureUpdates.join('\n\n'),10);
                          },
                      child: Text('Future updates',style: TextStyle(fontSize: 16,color: Colors.white))
                  ),
                ];
              }
          )

        ],
      ),
      body: !connectionState.isConnected?
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/no_internet.png',fit: BoxFit.contain,width: 100,height: 100,),
                SizedBox(height: 20,),
                Text('No internet connection',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),
                SizedBox(height: 10,),
                Text('Check your network and try again',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),
              ],
            ),
          )
      :RefreshIndicator(
        onRefresh: ()async{
          await photoNotifier.fetchInitialPhotos();
        },
        backgroundColor: Colors.black,
        color: Colors.white,
        child: Builder(
          builder: (context) {
            final showData = isSearching? searchState : photoState;

              if (showData.inProgress) {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     const Center(child: CircularProgressIndicator(color: Colors.black,)),
                      SizedBox(height: 15,),
                      const Text('Loading...',style: TextStyle(color: Colors.black,fontSize: 15),)
                    ],
                  ),
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100 && !showData.isLoadingMore) {
                    isSearching? searchNotifier.getMoreSearchedPhotos(_searchController.text) : photoNotifier.fetchMorePhotos();
                  }
                  return false;
                },
                child: CustomScrollView(
                  physics: ClampingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.03, vertical: height*0.02),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {

                            final data = showData.photos[index];
                            final heroTag = isSearching ? 'search-${data.id}' : 'home-${data.id}';

                            return Card(
                              color: Colors.white,
                              shadowColor: Colors.black54,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
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
                                      borderRadius: BorderRadius.circular(20),
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
                                      top: 6,
                                      right: 6,
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

                                  ]
                                ),
                              ),
                            );
                          },
                          childCount: showData.photos.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.6
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

      floatingActionButton: Container(
        margin: EdgeInsets.only(right: 10,bottom: 10),
        child: FloatingActionButton(
            onPressed: (){
             Navigator.push(context, MaterialPageRoute(builder: (context)=>VideoFeedScreen()));
            },
          child: Icon(Icons.play_arrow,color: Colors.black,size: 35,),
          backgroundColor: Colors.white,
        ),
      ),

    );
  }
}

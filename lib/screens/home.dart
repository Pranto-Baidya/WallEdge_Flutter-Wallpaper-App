import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/riverpod/favorite_riverpod.dart';
import 'package:learning_riverpod/riverpod/internet_connectivity_riverpod.dart';
import 'package:learning_riverpod/riverpod/theme_riverpod.dart';
import 'package:learning_riverpod/screens/about_app.dart';
import 'package:learning_riverpod/screens/image_screen.dart';
import 'package:learning_riverpod/riverpod/photo_riverpod.dart';
import 'package:learning_riverpod/screens/video_screen.dart';
import 'package:learning_riverpod/widgets/animated_view.dart';
import 'package:learning_riverpod/widgets/dialogue%20helper.dart';

final searchProvider = StateProvider<bool>((ref)=>false);
final searchForBodyProvider = StateProvider<bool>((ref)=>false);

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

  @override
  Widget build(BuildContext context) {

    ref.listen<InternetState>(internetProvider, (prev,next){
      if(next.isConnected){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              content: Text('Internet connection restored',style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),)
          ),
        );
      }
    });

    final isSearching = ref.watch(searchProvider);

    final isSearchingForBody = ref.watch(searchForBodyProvider);

    final photoState = ref.watch(photoNotifierProvider);

    final photoNotifier = ref.read(photoNotifierProvider.notifier);

    final searchState = ref.watch(searchWallpaperProvider);

    final searchNotifier = ref.read(searchWallpaperProvider.notifier);

    final width = MediaQuery.of(context).size.width;

    final height = MediaQuery.of(context).size.height;

    final connectionState = ref.watch(internetProvider);

    final isDark = ref.watch(themeProvider)==ThemeMode.dark;

    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 60,
        title: isSearching?
        TextField(
          autofocus: true,
          controller: _searchController,
          cursorColor: theme.colorScheme.onPrimary,
          decoration: InputDecoration(
              prefixIcon: IconButton(
                  onPressed: (){
                    ref.read(searchProvider.notifier).state = false;
                    ref.read(searchForBodyProvider.notifier).state = false;
                    _searchController.clear();
                  },
                  icon: Icon(Icons.arrow_back,color: theme.colorScheme.onPrimary,)
              ),
              hintText: 'Search for wallpapers',
              hintStyle: TextStyle(color: theme.colorScheme.onPrimary.withOpacity(0.7)),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none
              )
          ),
          onChanged: (value) async {
            if (value.trim().isEmpty) {
              ref.read(searchForBodyProvider.notifier).state = false;
              return;
            }

            ref.read(searchForBodyProvider.notifier).state = true;
            await ref.read(searchWallpaperProvider.notifier).searchWallpapers(value);
          },

        ):Row(
          children: [
            isDark?ClipOval(
                child: Image.asset('assets/wIcon.png',fit: BoxFit.cover,height: 43,width: 43,))
                :ClipOval(child: Image.asset('assets/icon.png',fit: BoxFit.cover,height: 43,width: 43,)),
            SizedBox(width: 12,),
            Text('WallEdge',style: theme.textTheme.titleLarge),
          ],
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
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                    color: theme.dividerColor,
                    spreadRadius: 0,
                    blurRadius: 3,
                    offset: Offset(0, 1)
                )
              ]
          ),
        ),
        actions: [
          !isSearching?IconButton(
              onPressed: (){
                ref.read(themeProvider.notifier).setTheme(!isDark);
              },
              icon: isDark? Icon(Icons.wb_sunny_outlined,color: theme.iconTheme.color,) : Icon(Icons.dark_mode_outlined,color: theme.iconTheme.color)
          ):SizedBox.shrink(),
          isSearching?SizedBox.shrink():
          IconButton(
              onPressed: (){
                ref.read(searchProvider.notifier).state = true;
              },
              icon: Icon(Icons.search,color: theme.iconTheme.color)
          ),
          PopupMenuButton(
              popUpAnimationStyle: AnimationStyle(
                  curve: Curves.decelerate
              ),
              icon: Icon(Icons.more_vert,color: theme.iconTheme.color),
              menuPadding: EdgeInsets.only(left: 10,right: 20,top: 10,bottom: 10),
              color: theme.cardColor,
              itemBuilder: (context){
                return [
                  PopupMenuItem(
                      onTap: (){
                        Alert.dialogue(context, 'Coming Soon!', 'Change log will appear soon, Stay tuned.',null);
                      },
                      child: Text('Change log',style: TextStyle(fontSize: 16,color: theme.colorScheme.onPrimary))
                  ),
                  PopupMenuItem(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>AboutApp()));
                      },
                      child: Text('About app',style: TextStyle(fontSize: 16,color: theme.colorScheme.onPrimary))
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
            isDark? Image.asset('assets/noIn.png',fit: BoxFit.contain,width: 100,height: 100,)
            :Image.asset('assets/no_internet.png',fit: BoxFit.contain,width: 100,height: 100,),
            SizedBox(height: 20,),
            Text('No internet connection',style: theme.textTheme.bodyLarge,),
            SizedBox(height: 10,),
            Text('Check your network and try again',style: theme.textTheme.bodyLarge,),
          ],
        ),
      )
          :RefreshIndicator(
        onRefresh: ()async{
          await photoNotifier.fetchInitialPhotos();
        },
        backgroundColor: isDark? Colors.white:Colors.black,
        color: isDark? Colors.black:Colors.white,
        child: Builder(
          builder: (context) {
            final showData = isSearchingForBody? searchState : photoState;

            if (showData.inProgress) {
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(child: CircularProgressIndicator(color: theme.colorScheme.onPrimary,)),
                    SizedBox(height: 15,),
                    Text('Loading...',style: theme.textTheme.bodyMedium,)
                  ],
                ),
              );
            }

            if(showData.error!=null){
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off,color: Theme.of(context).iconTheme.color,size: 50,),
                    SizedBox(height: 15,),
                    Text(showData.error!.contains('timeout')?
                    'Connection time out' :'Something went wrong',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 20,),
                    InkWell(
                      onTap: ()async{
                        if(isSearchingForBody){
                          await searchNotifier.searchWallpapers(showData.query);
                        }
                        await photoNotifier.fetchInitialPhotos();
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        width: 160,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isDark? Colors.white : Colors.black
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Retry',style: Theme.of(context).textTheme.titleLarge?.copyWith(color: isDark?Colors.black:Colors.white),),
                            SizedBox(width: 5,),
                            Icon(Icons.refresh,color: isDark? Colors.black : Colors.white,)
                          ],
                        ),
                      ),
                    )
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
                          final heroTag = isSearchingForBody? 'search-${data.id}' : 'home-${data.id}';

                          return Card(
                            color: theme.cardColor,
                            shadowColor: isDark? Colors.white12 : Colors.black54,
                            elevation: 8,
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
                                    AnimatedScrollItem(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Hero(
                                          tag: heroTag,
                                          child: CachedNetworkImage(
                                            imageUrl : data.srcPortrait ?? '',
                                            fadeInDuration: const Duration(milliseconds: 500),
                                            fit: BoxFit.cover,
                                            placeholder: (context,url){
                                              return Center(child: CircularProgressIndicator(color: theme.colorScheme.onPrimary,));
                                            },
                                            errorWidget: (context,error,st)=> const Icon(Icons.broken_image_outlined),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
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
                                                color: Colors.white,
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
                          childAspectRatio: 0.58
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: showData.isLoadingMore
                        ? Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator(color: theme.colorScheme.onPrimary,)),
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
          child: Icon(Icons.play_arrow,color: isDark? Colors.white:Colors.black,size: 35,),
          backgroundColor: isDark? Colors.black:Colors.white,
          elevation: 8,

        ),
      ),

    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/riverpod/favorite_riverpod.dart';
import 'package:learning_riverpod/riverpod/photo_riverpod.dart';
import 'package:learning_riverpod/screens/image_screen.dart';
import 'package:learning_riverpod/widgets/animated_view.dart';

import '../riverpod/theme_riverpod.dart';

final categoryPhotos =
StateNotifierProvider<PhotoNotifier, PhotoState>((ref) => PhotoNotifier());

class SpecificCategoryScreen extends ConsumerStatefulWidget {
  final String categoryName;
  const SpecificCategoryScreen({required this.categoryName, super.key});

  @override
  _SpecificCategoryScreenState createState() => _SpecificCategoryScreenState();
}

class _SpecificCategoryScreenState
    extends ConsumerState<SpecificCategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(categoryPhotos.notifier).fetchCategory(widget.categoryName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final photoState = ref.watch(categoryPhotos);
    final photoNotifier = ref.read(categoryPhotos.notifier);

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final isDark = ref.watch(themeProvider)==ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          '${widget.categoryName} wallpapers',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
        ),
        backgroundColor: Theme.of(context).cardColor,
        scrolledUnderElevation: 0,
        systemOverlayStyle:  SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: isDark? Colors.black:Colors.white,
            systemNavigationBarDividerColor: Colors.transparent,
            statusBarIconBrightness: isDark? Brightness.light: Brightness.dark
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
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent - 100 &&
              !photoState.isLoadingMore) {
            photoNotifier.fetchMoreCategoryPhotos(widget.categoryName);
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: ()async{
            await photoNotifier.fetchCategory(widget.categoryName);
          },
          backgroundColor: isDark? Colors.white:Colors.black,
          color: isDark? Colors.black:Colors.white,
          child: CustomScrollView(
            physics: ClampingScrollPhysics(),
            slivers: [
              if (photoState.inProgress)
                SliverFillRemaining(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary,)),
                          SizedBox(height: 15,),
                          Text('Loading...',style: Theme.of(context).textTheme.bodyMedium,)
                        ],
                      ),
                    )
                )

              else if (photoState.photos.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('No wallpapers to show')),
                )
                
                else if(photoState.error!=null)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off,color: Theme.of(context).iconTheme.color,size: 50,),
                        SizedBox(height: 15,),
                        Text(photoState.error!.contains('timeout')?
                        'Connection time out' :'Something went wrong',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 20,),
                        InkWell(
                          onTap: ()async{
                            await photoNotifier.fetchCategory(photoState.query);
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
                  )

              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: width*0.03, vertical: height*0.02),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.58,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final data = photoState.photos[index];
                        return Card(
                          color: Theme.of(context).cardColor,
                          shadowColor: isDark? Colors.white12 : Colors.black54,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageScreen(
                                        photo: data,
                                        heroTag: data.id.toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: AnimatedScrollItem(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Hero(
                                      tag: data.id.toString(),
                                      child: CachedNetworkImage(
                                        imageUrl: data.srcOriginal ?? '',
                                        fit: BoxFit.cover,
                                        fadeInDuration:
                                        const Duration(milliseconds: 500),
                                        placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary,)),
                                        errorWidget: (context, error, st) =>
                                        const Icon(Icons.broken_image),
                                      ),
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

                                    final isFav = favState.favPhotos.any((i) => i.id == data.id);

                                    return AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      transitionBuilder: (child, animation) =>
                                          ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          ),
                                      child: IconButton(
                                        key: ValueKey(isFav),
                                        onPressed: () {
                                          favNotifier.toggleFavPhoto(data);
                                        },
                                        icon: isFav ? Icon(
                                          Icons.favorite,
                                          color: Colors.white,
                                          size: 28,
                                        )
                                            : Icon(
                                          Icons.favorite_outline,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: photoState.photos.length,
                    ),
                  ),
                ),

              if (photoState.isLoadingMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
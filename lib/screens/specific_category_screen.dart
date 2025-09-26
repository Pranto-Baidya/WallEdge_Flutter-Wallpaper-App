import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/riverpod/favorite_riverpod.dart';
import 'package:learning_riverpod/riverpod/photo_riverpod.dart';
import 'package:learning_riverpod/screens/image_screen.dart';

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '${widget.categoryName} wallpapers',
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
          backgroundColor: Colors.black,
          color: Colors.white,
          child: CustomScrollView(
            slivers: [
              if (photoState.inProgress)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                )

              else if (photoState.photos.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('No wallpapers to show')),
                )

              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: width*0.02, vertical: height*0.02),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final data = photoState.photos[index];
                        return Card(
                          color: Colors.white,
                          shadowColor: Colors.black45,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Hero(
                                    tag: data.id.toString(),
                                    child: CachedNetworkImage(
                                      imageUrl: data.srcOriginal ?? '',
                                      fit: BoxFit.cover,
                                      fadeInDuration:
                                      const Duration(milliseconds: 500),
                                      placeholder: (context, url) => CachedNetworkImage(
                                        imageUrl : data.srcMedium ?? '',
                                        fit: BoxFit.cover,
                                      ),
                                      errorWidget: (context, error, st) =>
                                      const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    final favState = ref.watch(favPhotoNotifier);
                                    final favNotifier =
                                    ref.read(favPhotoNotifier.notifier);

                                    final isFav = favState.favPhotos.any((i) => i.id == data.id);

                                    return AnimatedSwitcher(
                                      duration:
                                      const Duration(milliseconds: 300),
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
                                        icon: isFav
                                            ? const Icon(
                                          Icons.favorite,
                                          color: Colors.white,
                                          size: 28,
                                        )
                                            : const Icon(
                                          Icons.favorite_outline,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                left: 10,
                                bottom: 10,
                                child: Text(
                                  'By : ${data.photographer}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      childCount: photoState.photos.length,
                    ),
                  ),
                ),

              if (photoState.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.black),
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

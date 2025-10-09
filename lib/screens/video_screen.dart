import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/riverpod/internet_connectivity_riverpod.dart';
import 'package:learning_riverpod/riverpod/video_riverpod.dart';
import 'package:learning_riverpod/widgets/video_player.dart';
import '../riverpod/theme_riverpod.dart';

final searchVideoProvider = StateNotifierProvider<VideoNotifier, VideoState>((ref) => VideoNotifier());

final isSearchingProvider = StateProvider<bool>((ref) => false);

class VideoFeedScreen extends ConsumerStatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  _VideoFeedScreenState createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends ConsumerState<VideoFeedScreen> {

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videoProvider.notifier).fetchInitialVideos();
    });
  }

  @override
  Widget build(BuildContext context) {

    final videoState = ref.watch(videoProvider);
    final videoNotifier = ref.read(videoProvider.notifier);

    final searchVidState = ref.watch(searchVideoProvider);
    final searchVidNotifier = ref.read(searchVideoProvider.notifier);

    final isSearching = ref.watch(isSearchingProvider);

    final currentState = isSearching ? searchVidState : videoState;
    final currentNotifier = isSearching ? searchVidNotifier : videoNotifier;

    final isDark = ref.watch(themeProvider)==ThemeMode.dark;

    final internetState = ref.watch(internetProvider);

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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          'WallEdge Videos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
        ),
        backgroundColor: Theme.of(context).cardColor,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
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
      body: !internetState.isConnected?
      Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isDark? Image.asset('assets/no_internet.png',fit: BoxFit.contain,width: 100,height: 100,)
                :Image.asset('assets/noIn.png',fit: BoxFit.contain,width: 100,height: 100,),
            SizedBox(height: 20,),
            Text('No internet connection',style: Theme.of(context).textTheme.bodyLarge,),
            SizedBox(height: 10,),
            Text('Check your network and try again',style: Theme.of(context).textTheme.bodyLarge,),
          ],
        ),
      )
      :RefreshIndicator(
        onRefresh: ()async{
          await currentNotifier.fetchInitialVideos();
        },
        backgroundColor: isDark? Colors.white:Colors.black,
        color: isDark? Colors.black:Colors.white,
        child: Builder(
          builder: (context) {
            return currentState.isLoading
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary),
                  SizedBox(height: 15),
                  Text(
                    'Loading...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                ],
              ),
            )
                : NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100 && !currentState.isLoadingMore) {
                  if (isSearching) {
                    searchVidNotifier.fetchMoreSearchedVideos();
                  } else {
                    videoNotifier.fetchMoreVideos();
                  }
                }
                return false;
              },
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: SearchBar(
                      controller: _searchController,
                      backgroundColor: WidgetStatePropertyAll(Theme.of(context).cardColor),
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(Icons.search,
                            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)),
                      ),
                      hintText: 'Search for videos...',
                      elevation: WidgetStatePropertyAll(3) ,
                      onSubmitted: (value) async {
                        final query = value.trim();
                        if (query.isEmpty) {
                          ref.read(isSearchingProvider.notifier).state = false;
                          await videoNotifier.fetchInitialVideos();
                        } else {
                          ref.read(isSearchingProvider.notifier).state = true;
                          await searchVidNotifier.fetchSearchedVideo(query);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      itemCount: currentState.videos.length + (currentState.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < currentState.videos.length) {
                          final data = currentState.videos[index];
                          return Padding(
                            padding:
                            const EdgeInsets.only(bottom: 16.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                VideoPlayerWidget(
                                  videoUrl: data.videoFiles.firstWhere(
                                        (i) => i.quality == 'hd',
                                    orElse: () => data.videoFiles.first,
                                  ).link,
                                  videoId: data.id,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          );
                        }
                      },
                    ),
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
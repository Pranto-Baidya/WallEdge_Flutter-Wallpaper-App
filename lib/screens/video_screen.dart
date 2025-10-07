import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/riverpod/video_riverpod.dart';
import 'package:learning_riverpod/widgets/video_player.dart';

import '../riverpod/download_videos_riverpod.dart';

class VideoFeedScreen extends ConsumerStatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  _VideoFeedScreenState createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends ConsumerState<VideoFeedScreen> {
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

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'WallEdge Videos',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark
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
      body: videoState.isLoading
          ? const Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(child: CircularProgressIndicator(color: Colors.black,)),
            SizedBox(height: 15,),
            const Text('Loading...',style: TextStyle(color: Colors.black,fontSize: 15),)
          ],
        ),
      )
          : NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent - 100 &&
              !videoState.isLoadingMore) {
            videoNotifier.fetchMoreVideos();
          }
          return false;
        },
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          itemCount:
          videoState.videos.length + (videoState.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < videoState.videos.length) {
              final data = videoState.videos[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VideoPlayerWidget(
                      videoUrl: data.videoFiles.firstWhere(
                            (i) => i.quality == 'hd',
                        orElse: () => data.videoFiles.first,
                      ).link,
                    ),
                  ],
                ),
              );
            } else {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

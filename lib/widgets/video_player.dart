import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/riverpod/download_videos_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends ConsumerStatefulWidget {
  final int videoId;
  final String videoUrl;
  const VideoPlayerWidget({required this.videoId, required this.videoUrl, super.key});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget> {

  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  void showDownloadDialogue(BuildContext context){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context){
          return Consumer(
              builder: (context,ref,_){
                final progressState = ref.watch(downloadVideoProvider);
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text('Downloading video',style: TextStyle(color: Colors.black),),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey,
                          color: Colors.black,
                          value: progressState.progress,
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text('${(progressState.progress*100).toStringAsFixed(0)}%',style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.w400),)
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: (){
                          ref.read(downloadVideoProvider.notifier).cancelDownload();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            minimumSize: Size(double.infinity, 50)
                        ),
                        child: Text('Cancel download',style: TextStyle(color: Colors.white),)
                    )
                  ],
                );
              }
          );
        }
    );
  }

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: false,
          looping: false,
          zoomAndPan: true,
          allowFullScreen: true,
          allowPlaybackSpeedChanging: true,
          materialProgressColors: ChewieProgressColors(
            bufferedColor: Colors.blue.shade50,
            handleColor: Colors.white,
            playedColor: Colors.blue,
            backgroundColor: Colors.grey,
          ),
          additionalOptions: (context) => [
            !ref.read(downloadVideoProvider.notifier).isVideoSaved(widget.videoId)?
            OptionItem(
              onTap: (context) {
                if(!ref.read(downloadVideoProvider).isDownloading) {
                  final downloadNotifier = ref.read(downloadVideoProvider.notifier);
                  downloadNotifier.downloadVideo(widget.videoUrl,widget.videoId);
                  showDownloadDialogue(context);
                }
              },
              iconData: Icons.download,
              title: 'Download video',
            ): OptionItem(
                onTap: (context)=>null,
                iconData: Icons.download_done,
                title: 'Video saved to gallery'
            ),

            OptionItem(
              onTap: (context)async{
                final file = await _cacheManager.getSingleFile(widget.videoUrl);
                SharePlus.instance.share(
                    ShareParams(
                        text: 'Check out this awesome video from WallEdge',
                        files: [
                          XFile(file.path)
                        ]
                    )
                );
              },
              iconData: Icons.share,
              title: 'Share video',
            ),
          ],
        );
        setState(() {});
      });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController != null && _videoPlayerController.value.isInitialized) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 2),
                  spreadRadius: 0,
                  color: Theme.of(context).dividerColor,
                  blurRadius: 8
              )
            ]
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Theme(
              data: ThemeData(
                  listTileTheme: ListTileThemeData(
                      iconColor: Theme.of(context).colorScheme.onPrimary,
                      textColor: Theme.of(context).colorScheme.onPrimary,
                      titleTextStyle: TextStyle(fontWeight: FontWeight.w400,fontSize: 16)
                  ),
                  dividerTheme: DividerThemeData(
                      color: Theme.of(context).colorScheme.onPrimary
                  ),
                  bottomSheetTheme: BottomSheetThemeData(
                      dragHandleColor: Theme.of(context).colorScheme.onPrimary,
                      showDragHandle: true,
                      modalBackgroundColor: Theme.of(context).cardColor
                  )
              ),
              child: Consumer(
                  builder: (context,ref,_) {
                    ref.watch(downloadVideoProvider);
                    return Chewie(controller: _chewieController!);
                  }
              )
          ),
        ),
      );
    } else {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Center(
          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary),
        ),
      );
    }
  }
}
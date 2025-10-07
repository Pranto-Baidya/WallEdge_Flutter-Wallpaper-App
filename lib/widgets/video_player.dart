import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/riverpod/download_videos_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../riverpod/dowload_image_riverpod.dart';

class VideoPlayerWidget extends ConsumerStatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({required this.videoUrl, super.key});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget> {

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
                      SizedBox(height: 5,),
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
            bufferedColor: Colors.grey,
            handleColor: Colors.white,
            playedColor: Colors.black,
            backgroundColor: Colors.white,
          ),
          additionalOptions: (context) => [
            OptionItem(
              onTap: (context) {
                if(!ref.watch(downloadVideoProvider).isDownloading) {
                  final downloadNotifier = ref.read(downloadVideoProvider.notifier);
                  downloadNotifier.downloadVideo(widget.videoUrl);
                  showDownloadDialogue(context);
                }
              },
              iconData: Icons.download,
              title: 'Download video',
            ),

            OptionItem(
              onTap: (context){

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
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Theme(
              data: ThemeData(
                listTileTheme: ListTileThemeData(
                  iconColor: Colors.black,
                  textColor: Colors.black,
                  titleTextStyle: TextStyle(fontWeight: FontWeight.w400,fontSize: 16)
                ),
                dividerTheme: DividerThemeData(
                  color: Colors.black
                ),
                bottomSheetTheme: BottomSheetThemeData(
                  dragHandleColor: Colors.black,
                  showDragHandle: true,
                  modalBackgroundColor: Colors.white
                )
              ),
              child: Chewie(controller: _chewieController!)
          ),
        ),
      );
    } else {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.black,
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
  }
}

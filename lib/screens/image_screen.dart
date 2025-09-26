import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/riverpod/favorite_riverpod.dart';
import 'package:learning_riverpod/riverpod/photo_riverpod.dart';
import '../models/photo_model.dart';
import '../riverpod/dowload_image_riverpod.dart';

class ImageScreen extends ConsumerStatefulWidget {
  final PhotoModel photo;
  final String heroTag;
  const ImageScreen({required this.heroTag,required this.photo, super.key});

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends ConsumerState<ImageScreen> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(photoNotifierProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (imageState.inProgress)
              const Center(child: CircularProgressIndicator()),
            Hero(
              tag: widget.heroTag,
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: widget.photo.srcOriginal??'',
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 500),
                  placeholder: (context, url) {
                    return CachedNetworkImage(imageUrl : widget.photo.srcMedium ?? '', fit: BoxFit.cover);
                  },
                  errorWidget: (context, url, st) =>
                  const Icon(Icons.broken_image_outlined, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 10,
              right: 10,
              left: 10,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildColumn(Icons.info_outline, 'Info', () {
                      showModalBottomSheet(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                        backgroundColor: Colors.white,
                        showDragHandle: true,
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: 300,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Text(
                                      'Image Info',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Card(
                                    shadowColor: Colors.black54,
                                    elevation: 6,
                                    color: Colors.black,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 10),
                                          _infoRow('Image width', '${widget.photo.width} px'),
                                          _infoRow('Image height', '${widget.photo.height} px'),
                                          _infoRow('Photographer', widget.photo.photographer),
                                          Row(
                                            children: [
                                              const Text(
                                                'About photographer',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const Spacer(),
                                              TextButton(
                                                onPressed: () {},
                                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                                child: const Text(
                                                  'Click here',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                    color: Colors.blue,
                                                    decoration: TextDecoration.underline,
                                                    decorationColor: Colors.blue,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          _infoRow('Average Color', widget.photo.avgColor ?? 'N/A'),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),

                    Consumer(
                      builder: (context, ref, _) {

                        final downloadState = ref.watch(downloadNotifierProvider);
                        final downloadNotifier = ref.read(downloadNotifierProvider.notifier);
                        final photoId = widget.photo.id;

                        final isSaved = downloadNotifier.isPhotoSaved(photoId);

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            downloadState.isDownloading
                                ? Column(
                                  children: [
                                    CircularProgressIndicator(value: downloadState.progress, color: Colors.white),
                                    SizedBox(height: 10,)
                                  ],
                                ) : isSaved ? IconButton(onPressed: null, icon: Icon(Icons.download_done, color: Colors.white))
                                : IconButton(
                              onPressed: () {
                                if (!downloadState.isDownloading) {
                                  downloadNotifier.downloadPhoto(widget.photo.srcOriginal ?? '', photoId);
                                }
                              },
                              style: IconButton.styleFrom(padding: EdgeInsets.zero),
                              icon: Icon(Icons.file_download_outlined, color: Colors.white),
                            ),
                            Text(
                              downloadState.isDownloading
                                  ? '${(downloadState.progress * 100).toInt()}%' : isSaved ? 'Saved' : 'Save',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    ),

                    _buildColumn(Icons.check_circle_outline, 'Apply', () {}),
                    Consumer(
                        builder: (context,ref,_){
                          final favState = ref.watch(favPhotoNotifier);
                          final favNotifier = ref.read(favPhotoNotifier.notifier);

                          final isFav = favState.favPhotos.any((i)=>i.id==widget.photo.id);

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  onPressed: (){
                                     favNotifier.toggleFavPhoto(widget.photo);
                                  },
                                  style: IconButton.styleFrom(padding: EdgeInsets.zero),
                                  icon: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      transitionBuilder: (child,anim)=>ScaleTransition(scale: anim,child: child,),
                                      child : Icon(
                                       isFav ? Icons.favorite : Icons.favorite_border,
                                       key: ValueKey(isFav),
                                       color: isFav ? Colors.white: Colors.white,
                                       size: isFav? 28:28,
                                     ),
                                  )
                              ),
                              Text('Favorite', style: const TextStyle(color: Colors.white, fontSize: 14)),
                              const SizedBox(height: 10)
                            ],
                          );
                        }
                    )

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(IconData icon, String title, VoidCallback onTap) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: onTap,
            style: IconButton.styleFrom(padding: EdgeInsets.zero),
            icon: Icon(
              icon,
              color: Colors.white,
            )),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 10)
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

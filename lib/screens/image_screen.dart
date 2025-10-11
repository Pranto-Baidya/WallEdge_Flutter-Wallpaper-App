import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/riverpod/favorite_riverpod.dart';
import 'package:learning_riverpod/riverpod/photo_riverpod.dart';
import 'package:learning_riverpod/widgets/url_herlper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
import '../models/photo_model.dart';
import '../riverpod/dowload_image_riverpod.dart';

enum WallpaperOptions {Home, Lock, Both}

final selectedItemProvider = StateProvider<WallpaperOptions>((ref)=>WallpaperOptions.Home);

class ImageScreen extends ConsumerStatefulWidget {

  final PhotoModel photo;
  final String heroTag;

  const ImageScreen({required this.heroTag,required this.photo, super.key});

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends ConsumerState<ImageScreen> {

  final DefaultCacheManager cacheManager = DefaultCacheManager();
  final WallpaperManagerPlus wallpaperManagerPlus = WallpaperManagerPlus();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.initState();
  }


  Future<void> _setWallpaper(int location)async{
    try {
      final file = await cacheManager.getSingleFile(widget.photo.srcOriginal ?? '');

      final result = await wallpaperManagerPlus.setWallpaper(file, location);

      if (location == WallpaperManagerPlus.lockScreen || location == WallpaperManagerPlus.bothScreens) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            content: Text("Changing the lock screen wallpaper might not be supported on this device. You can still set the wallpaper for your home screen.",style: TextStyle(color: Colors.white),),
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            content: Text(result ?? 'Wallpaper set successfully!',style: TextStyle(color: Colors.white),)
        ),
      );

    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            content: Text('Error setting wallpaper',style: TextStyle(color: Colors.white))
        ),
      );
    }
  }

  void showSetWallpaperDialogue(){
   showDialog(
       context: context,
       builder: (BuildContext context){
         return Consumer(
             builder: (context,ref,_){

               final selectState = ref.watch(selectedItemProvider);
               final selectNotifier = ref.read(selectedItemProvider.notifier);

               return AlertDialog(
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 backgroundColor: Colors.white,
                 contentPadding: EdgeInsets.zero,
                 title: Text('Set Wallpaper',style: TextStyle(color: Colors.black,fontSize: 25,fontWeight: FontWeight.w500),),
                 content: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     SizedBox(height: 15,),
                     ...WallpaperOptions.values.map((wallpaper){
                       return RadioListTile(
                           fillColor: WidgetStatePropertyAll(Colors.black),
                           title: wallpaper.name == 'Home'?
                            Text('Home Screen',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),)

                           :wallpaper.name=='Lock'?
                            Text('Lock Screen',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),)

                           :Text('Both',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),

                           value: wallpaper,
                           groupValue: selectState,
                           onChanged: (value){
                             if(value!=null) {
                               selectNotifier.state = value;
                             }
                           }
                       );
                     })
                   ],
                 ),
                 actions: [
                   SizedBox(height: 15,),
                   TextButton(
                       onPressed: (){
                         Navigator.pop(context);
                       },
                       child: Text('Cancel',style: TextStyle(color: Colors.black),)
                   ),
                   TextButton(
                       onPressed: (){
                         switch(selectState){
                           case WallpaperOptions.Home :
                             _setWallpaper(WallpaperManagerPlus.homeScreen);
                             break;
                           case WallpaperOptions.Lock :
                             _setWallpaper(WallpaperManagerPlus.lockScreen);
                             break;
                           case WallpaperOptions.Both :
                             _setWallpaper(WallpaperManagerPlus.bothScreens);
                             break;
                           }
                         Navigator.pop(context);
                       },
                       child: Text('Set wallpaper',style: TextStyle(color: Colors.black),)
                   ),
                 ],
               );
             }
         );
       }
   );
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
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Hero(
                  tag: widget.heroTag,
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
              bottom: MediaQuery.of(context).padding.bottom + 8,
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
                                                onPressed: ()async {
                                                 await UrlHelper.openUrl(widget.photo.photographerUrl??'');
                                                },
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
                                    SizedBox(height: 10,),
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        value: downloadState.progress,
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    ),
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
                              icon: Icon(Icons.file_download_outlined, color: Colors.white,size: 28,),
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

                    _buildColumn(Icons.collections_outlined, 'Apply', () {
                      showSetWallpaperDialogue();
                    }),
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
                    ),
                    _buildColumn(Icons.share, 'Share', ()async{
                      final file = await cacheManager.getSingleFile(widget.photo.srcOriginal ?? '');
                       SharePlus.instance.share(
                         ShareParams(
                           text: 'Check out this awesome wallpaper from WallEdge!',
                           files: [
                             XFile(file.path),
                           ]
                         )
                       );
                    })

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
          SelectableText(
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

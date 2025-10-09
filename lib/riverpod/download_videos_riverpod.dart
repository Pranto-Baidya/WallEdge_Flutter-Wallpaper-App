
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

final downloadVideoProvider = StateNotifierProvider<DownloadVideoNotifier,DownloadVideoState>((ref){
  return DownloadVideoNotifier();
});

class DownloadVideoState{
  final bool isDownloading;
  final double progress;
  final bool isDownloadCancelled;
  final Map<int,String> savedVideos;

  DownloadVideoState({
    this.isDownloading = false,
    this.progress = 0.0,
    this.isDownloadCancelled = false,
    this.savedVideos = const <int,String>{}
  });

  DownloadVideoState copyWith({
    bool? isDownloading,
    double? progress,
    bool? isDownloadCancelled,
    Map<int,String>? savedVideos
  }){
    return DownloadVideoState(
        isDownloading: isDownloading ?? this.isDownloading,
        progress: progress ?? this.progress,
        isDownloadCancelled: isDownloadCancelled ?? this.isDownloadCancelled,
        savedVideos: savedVideos ?? this.savedVideos
    );
  }
}

class DownloadVideoNotifier extends StateNotifier<DownloadVideoState>{

  final Dio _dio = Dio();
  CancelToken? _cancelToken;

  DownloadVideoNotifier() : super(DownloadVideoState()){
    _loadSavedVideos();
  }

  Future<void> _loadSavedVideos()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final data = preferences.getString('video');
    if(data!=null){
      final value = jsonDecode(data) as Map<String,dynamic>;
      Map<int,String> videos = value.map((key,value)=>MapEntry(int.parse(key), value.toString()));
      state = state.copyWith(savedVideos: videos);
    }
  }

  Future<void> _trackSavedVideos(Map<int,String> videos)async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map<String,String> data = videos.map((key,value)=>MapEntry(key.toString(), value));
    await preferences.setString('video', jsonEncode(data));
  }

  Future<void> downloadVideo(String videoUrl, int videoId) async {
    try {
      var videoStatus = await Permission.storage.request();
      if (!videoStatus.isGranted) {
        print('Video permission not granted');
        return;
      }

      Directory dir = Directory('/storage/emulated/0/Movies/WallEdge');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final filePath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      _cancelToken = CancelToken();

      state = state.copyWith(isDownloading: true, progress: 0.0, isDownloadCancelled: false);

      await _dio.download(
        videoUrl,
        filePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            state = state.copyWith(progress: received / total);
          }
        },
      );

      if (state.isDownloadCancelled) return;

         MethodChannel _methodChannel = MethodChannel('gallery_scanner');
         await _methodChannel.invokeMethod('scanFile',{'path' : filePath});

         Map<int, String> getData = Map<int, String>.from(state.savedVideos);
         getData[videoId] = filePath;

         state = state.copyWith(isDownloading: false, progress: 1.0, savedVideos: getData);

         await _trackSavedVideos(getData);
         await OpenFile.open(filePath);

    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        print('Download cancelled');
      } else {
        print('Download failed: $e');
      }
    } catch (e) {
      print('Download failed: $e');
    } finally {
      state = state.copyWith(isDownloading: false);
    }
  }

  void cancelDownload(){
    if(_cancelToken!=null && !_cancelToken!.isCancelled){
      _cancelToken!.cancel();
      state = state.copyWith(isDownloadCancelled: true,isDownloading: false,);
    }
  }

  bool isVideoSaved(int id){

    final path = state.savedVideos[id];

    if(path==null){
      return false;
    }
    final file = File(path);
    final exists = file.existsSync();

    if(!exists){
      Future.microtask(()async{
        Map<int, String> updated = Map<int, String>.from(state.savedVideos);
        updated.remove(id);
        await _trackSavedVideos(updated);
        state = state.copyWith(savedVideos: updated);
      });
      return false;
    }
    return true;
  }
}
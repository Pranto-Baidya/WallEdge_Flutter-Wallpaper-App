
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

final downloadVideoProvider = StateNotifierProvider<DownloadVideoNotifier,DownloadVideoState>((ref){
  return DownloadVideoNotifier();
});

class DownloadVideoState{
  final bool isDownloading;
  final double progress;
  final String filePath;
  final bool isDownloadCancelled;

  DownloadVideoState({
    this.isDownloading = false,
    this.progress = 0.0,
    this.filePath = '',
    this.isDownloadCancelled = false
  });

  DownloadVideoState copyWith({
    bool? isDownloading,
    double? progress,
    String? filePath,
    bool? isDownloadCancelled
  }){
    return DownloadVideoState(
        isDownloading: isDownloading ?? this.isDownloading,
        progress: progress ?? this.progress,
        filePath: filePath ?? this.filePath,
        isDownloadCancelled: isDownloadCancelled ?? this.isDownloadCancelled
    );
  }
}

class DownloadVideoNotifier extends StateNotifier<DownloadVideoState>{

  final Dio _dio = Dio();
  CancelToken? _cancelToken;

  DownloadVideoNotifier() : super(DownloadVideoState());

  Future<void> downloadVideo(String videoUrl) async {
    try {

      var videoStatus = await Permission.storage.request();
      if (!videoStatus.isGranted) {
        print('Video permission not granted');
        return;
      }

      Directory dir = await getTemporaryDirectory();

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      final filePath = '${dir.path}/$fileName';

      _cancelToken = CancelToken();

      state = state.copyWith(isDownloading: true, progress: 0.0,isDownloadCancelled: false);

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

      if(state.isDownloadCancelled){
        return;
      }

      final saved = await GallerySaver.saveVideo(filePath, albumName: 'WallEdge');

      if (saved == true) {
        await OpenFile.open(filePath);
      }
    }
    on DioException catch(e){
      if(CancelToken.isCancel(e)){
        print('Download cancelled');
      }
      else{
        print('Download failed: $e');
      }
    }
    catch (e) {
      print('Download failed: $e');
    }
    finally {
      state = state.copyWith(isDownloading: false);
    }
  }

  void cancelDownload(){
    if(_cancelToken!=null && !_cancelToken!.isCancelled){
      _cancelToken!.cancel();
      state = state.copyWith(isDownloadCancelled: true,isDownloading: false);
    }
  }
}


import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

final downloadNotifierProvider = StateNotifierProvider<DownloadNotifier,DownloadState>((ref)=>DownloadNotifier());

class DownloadState{
  final bool isDownloading;
  final double progress;
  final String filePath;
  final Map<int,String> savedPhotos;

  DownloadState({
    this.isDownloading = false,
    this.progress = 0.0,
    this.filePath = '',
    this.savedPhotos = const <int,String>{}
  });

  DownloadState copyWith({
    bool? isDownloading,
    double? progress,
    String? filePath,
    Map<int,String>? savedPhotos
  }){
    return DownloadState(
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
      filePath: filePath ?? this.filePath,
      savedPhotos: savedPhotos ?? this.savedPhotos
    );
  }
}

class DownloadNotifier extends StateNotifier<DownloadState>{

  Dio _dio = Dio();

  DownloadNotifier() : super(DownloadState());

  Future<void> downloadPhoto(String url,int photoId)async{

    try {
      var status = await Permission.storage.request();

      if (!status.isGranted) {
        return;
      }

      Directory dir = Directory('/storage/emulated/0/Pictures/WallEdge');

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      String fileName = 'WallEdgeImage_${DateTime.now().millisecondsSinceEpoch}.png';
      String filePath = '${dir.path}/$fileName';

      state = state.copyWith(isDownloading: true, progress: 0.0);

      await _dio.download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              double progress = received / total;
              state = state.copyWith(progress: progress);
            }
          }
      );
      
      MethodChannel _methodChannel = MethodChannel('gallery_scanner');
      await _methodChannel.invokeMethod('scanFile',{'path' : filePath});

      Map<int,String> updated = Map<int,String>.from(state.savedPhotos);
      updated[photoId] = filePath;

      state = state.copyWith(
          isDownloading: false,
          progress: 1.0,
          filePath: filePath,
          savedPhotos: updated
      );

      await OpenFile.open(filePath);

    }
    catch(e){
      state = state.copyWith(isDownloading: false);
    }
  }

  bool isPhotoSaved(int id){

    final path = state.savedPhotos[id];

    if(path==null){
      return false;
    }

    File file = File(path);
    final exists = file.existsSync();

    if(!exists){
      Future.microtask(() {
        final updated = Map<int,String>.from(state.savedPhotos);
        updated.remove(id);
        state = state.copyWith(savedPhotos: updated);
      });
      return false;
    }
    return true;
  }

}


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/api_service/api_service.dart';
import 'package:learning_riverpod/models/video_model.dart';

final videoProvider = StateNotifierProvider<VideoNotifier,VideoState>((ref)=>VideoNotifier());

class VideoState{
  final List<VideoModel> videos;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String? nextPage;

  VideoState({
    this.videos = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.nextPage
  });

  VideoState copyWith({
    List<VideoModel>? videos,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? nextPage
  }){
    return VideoState(
        videos: videos ?? this.videos,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: error ?? this.error,
        nextPage: nextPage ?? this.nextPage
    );
  }
}

class VideoNotifier extends StateNotifier<VideoState>{

  ApiService apiService = ApiService();

  VideoNotifier() : super(VideoState());

  Future<void> fetchInitialVideos()async{
    try {

      state = state.copyWith(videos: [], isLoading: true, isLoadingMore: false,);

      final data = await apiService.fetchVideos();

      state = state.copyWith(
          videos: data.videos,
          nextPage: data.nextPage,
          isLoading: false
      );
    }catch(e){
      state = state.copyWith(isLoading: false,error: e.toString());
    }
  }

  Future<void> fetchMoreVideos()async {

    if (state.nextPage == null || state.isLoadingMore) {
      return;
    }
    try {
      state = state.copyWith(isLoadingMore: true, error: null);

      final newData = await apiService.fetchMoreVideos(state.nextPage ?? '');

      state = state.copyWith(
        videos: [...state.videos, ...newData.videos],
        nextPage: newData.nextPage,
        isLoadingMore: false,
      );
    }catch(e){
      state = state.copyWith(isLoadingMore: false,error: e.toString());
    }
  }
}
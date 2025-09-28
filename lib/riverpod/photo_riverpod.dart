import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/api_service/api_service.dart';
import 'package:learning_riverpod/models/photo_model.dart';

final photoNotifierProvider = StateNotifierProvider<PhotoNotifier, PhotoState>((ref) => PhotoNotifier());

class PhotoState {
  final List<PhotoModel> photos;
  final bool inProgress;
  final bool isLoadingMore;
  final String? error;
  final String? nextPage;
  final String category;
  final String query;

  PhotoState({
    this.photos = const [],
    this.inProgress = false,
    this.isLoadingMore = false,
    this.error,
    this.nextPage,
    this.category = '',
    this.query = ''
  });

  PhotoState copyWith({
    List<PhotoModel>? photos,
    bool? inProgress,
    bool? isLoadingMore,
    String? error,
    String? nextPage,
    String? category,
    String? query
  }) {
    return PhotoState(
      photos: photos ?? this.photos,
      inProgress: inProgress ?? this.inProgress,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      nextPage: nextPage ?? this.nextPage,
      category: category ?? this.category,
      query: query ?? this.query
    );
  }
}

class PhotoNotifier extends StateNotifier<PhotoState> {

  final ApiService apiService = ApiService();

  PhotoNotifier() : super(PhotoState());

  Future<void> fetchInitialPhotos() async {
    try {
      state = state.copyWith(
        inProgress: true,
        isLoadingMore: false,
        error: null,
        photos: [],
      );

      final data = await apiService.fetchPhotos();

      state = state.copyWith(
        photos: data.photos,
        nextPage: data.nextPage,
        inProgress: false,
        isLoadingMore: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        inProgress: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> fetchMorePhotos() async {
    if (state.nextPage == null || state.isLoadingMore) return;

    try {
      state = state.copyWith(
        isLoadingMore: true,
        error: null,
      );

      final newData = await apiService.fetchNextPage(state.nextPage ?? '');

      state = state.copyWith(
        photos: [...state.photos, ...newData.photos],
        nextPage: newData.nextPage,
        isLoadingMore: false,
        error: null,
      );
    }
    catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> fetchCategory(String category)async{

    try {
      state = state.copyWith(
          inProgress: true,
          isLoadingMore: false,
          category: category,
          query: '',
          photos: [],
          error: null
      );

      final data = await apiService.getCategoryPhotos(state.category);

      state = state.copyWith(
          photos: data.photos,
          nextPage: data.nextPage,
          inProgress: false,
          isLoadingMore: false,
          query: '',
          error: null
      );
    }catch(e){
      state = state.copyWith(inProgress: false, error: e.toString());
    }
  }

  Future<void> fetchMoreCategoryPhotos(String category)async{
    if(state.nextPage==null || state.isLoadingMore){
      return;
    }

    try {
      state = state.copyWith(isLoadingMore: true,
          inProgress: false,
          error: null,
          query: '',
          category: category
      );

      final data = await apiService.getMoreCategoryPhotos(state.nextPage??'');

      state = state.copyWith(
          photos: [...state.photos, ...data.photos],
          nextPage: data.nextPage,
          isLoadingMore: false,
          error: null
      );
    }
    catch(e){
      state = state.copyWith(isLoadingMore: false,error: e.toString());
    }
  }

  Future<void> searchWallpapers(String query)async{
    if(query.trim().isEmpty){
      return;
    }
    try{
      state = state.copyWith(inProgress: true,photos: [],error: null,query: query);

      final data = await apiService.searchPhotos(state.query);

      state = state.copyWith(
        photos: data.photos,
        nextPage: data.nextPage,
        inProgress: false,
        error: null
      );
    }
    catch(e){
      state = state.copyWith(inProgress: false,error: e.toString());
    }
  }

  Future<void> getMoreSearchedPhotos(String query)async{
    if(state.nextPage==null || state.isLoadingMore) {
      return;
    }

    try{
      state = state.copyWith(isLoadingMore: true,query: query,category: '',error: null);

      final data = await apiService.searchMorePhotos(state.nextPage??'');

      state = state.copyWith(
        photos: [...state.photos,...data.photos],
        nextPage: data.nextPage,
        isLoadingMore: false,
        error: null
      );
    }
    catch(e){
      state = state.copyWith(inProgress: false,error: e.toString());
    }
  }

}



import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_riverpod/db_service/db_helper.dart';
import 'package:learning_riverpod/models/photo_model.dart';

final favPhotoNotifier = StateNotifierProvider<FavPhotoNotifier,FavPhotoState>((ref)=>FavPhotoNotifier());

class FavPhotoState{
  final List<PhotoModel> favPhotos;
  final List<PhotoModel> searchFavPhotos;

  FavPhotoState({
    this.favPhotos = const [],
    this.searchFavPhotos = const []
  });

  FavPhotoState copyWith({
    List<PhotoModel>? favPhotos,
    List<PhotoModel>? searchFavPhotos
  }){
    return FavPhotoState(
        favPhotos: favPhotos ?? this.favPhotos,
        searchFavPhotos: searchFavPhotos ?? this.searchFavPhotos
    );
  }
}

class FavPhotoNotifier extends StateNotifier<FavPhotoState>{

  DBHelper dbHelper = DBHelper();

  FavPhotoNotifier() : super(FavPhotoState());

  Future<void> getAllPhotos()async{
    final data = await dbHelper.getAllPhotos();

    state = state.copyWith(
      favPhotos: data,
    );
  }

  Future<void> addToFav(PhotoModel photo)async{
    await dbHelper.insertPhoto(photo);
    await getAllPhotos();
  }

  Future<void> deleteFromFav(int id)async{
    await dbHelper.removeFromFavorite(id);
    await getAllPhotos();
  }

  Future<bool> isFavorite(int id)async{
   return await dbHelper.hasPhoto(id);
  }

  Future<void> toggleFavPhoto(PhotoModel photo)async{
    if(await isFavorite(photo.id)){
      await deleteFromFav(photo.id);
    }
    else{
      await addToFav(photo);
    }
  }
}
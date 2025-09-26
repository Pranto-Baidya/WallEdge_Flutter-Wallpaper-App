

import 'package:learning_riverpod/models/photo_model.dart';

class PaginationModel{
  final int page;
  final int perPage;
  final List<PhotoModel> photos;
  final String? nextPage;

  PaginationModel({
    required this.page,
    required this.perPage,
    required this.photos,
    required this.nextPage
  });

  factory PaginationModel.fromJson(Map<String,dynamic> json){
    return PaginationModel(
        page: (json['page'] as num).toInt(),
        perPage: (json['per_page'] as num).toInt(),
        photos: (json['photos'] as List).map((i)=>PhotoModel.fromJson(i)).toList(),
        nextPage: json['next_page']?.toString()
    );
  }
}
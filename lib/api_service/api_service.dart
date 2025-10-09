import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:learning_riverpod/models/pagination_model.dart';
import 'package:learning_riverpod/models/video_model.dart';

class ApiService {
  static final apiKey = dotenv.env['ApiKey'];
  static const String baseUrl = 'https://api.pexels.com/v1/curated';
  static const String vidBaseUrl = 'https://api.pexels.com/videos';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: vidBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Authorization': apiKey},
    ),
  );

  Future<PaginationModel> fetchPhotos({int page = 1, int perPage = 20}) async {
    final url = '$baseUrl?page=$page&per_page=$perPage';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': apiKey!},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PaginationModel.fromJson(json);
      } else {
        throw Exception('Failed to fetch photos: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<PaginationModel> fetchNextPage(String nextPageUrl) async {
    try {
      final response = await http.get(
        Uri.parse(nextPageUrl),
        headers: {'Authorization': apiKey!},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PaginationModel.fromJson(json);
      } else {
        throw Exception('Failed to fetch next page: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<PaginationModel> getCategoryPhotos(
    String category, {
    int page = 1,
    int limit = 20,
  }) async {
    String url =
        'https://api.pexels.com/v1/search?query=$category&page=$page&per_page=$limit';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': apiKey!},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PaginationModel.fromJson(json);
      } else {
        throw Exception('Something went wrong, ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<PaginationModel> getMoreCategoryPhotos(String nextPage) async {
    try {
      final response = await http.get(
        Uri.parse(nextPage),
        headers: {'Authorization': apiKey!},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PaginationModel.fromJson(json);
      } else {
        throw Exception('Something went wrong, ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<PaginationModel> searchPhotos(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    final url =
        'https://api.pexels.com/v1/search?query=$query&page=$page&per_page=$limit';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': apiKey!},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PaginationModel.fromJson(json);
      } else {
        throw Exception('Something went wrong, ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<PaginationModel> searchMorePhotos(String nextPage) async {
    try {
      final response = await http.get(
        Uri.parse(nextPage),
        headers: {'Authorization': apiKey!},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PaginationModel.fromJson(json);
      } else {
        throw Exception('Something went wrong, ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<PaginatedVideoModel> fetchVideos({int perPage = 10, int page = 1}) async {
    try {
      final response = await _dio.get(
        '/popular',
        queryParameters: {'per_page': perPage, 'page': page},
      );
      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        return PaginatedVideoModel.fromJson(json);
      } else {
        throw Exception('Failed to fetch videos, ${response.data}');
      }
    } on DioException catch (e) {
      String message = 'Something went wrong';
      if (e.type == DioExceptionType.connectionTimeout) {
        message = 'Connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        message = 'Receive timeout';
      } else if (e.response != null) {
        message = 'Error: ${e.response?.data ?? e.message}';
      }
      throw Exception(message);
    } catch (e) {
      rethrow;
    }
  }

  Future<PaginatedVideoModel> fetchMoreVideos(String nextPage)async{
    try {
      final response = await _dio.getUri(Uri.parse(nextPage));

      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        return PaginatedVideoModel.fromJson(json);
      }
      else {
        throw Exception('Something went wrong');
      }
    } on DioException catch(e){
      if(e.type==DioExceptionType.connectionTimeout){
        throw Exception('Connection time out');
      }
      else{
        throw Exception('Failed to fetch');
      }
    }
    catch(e){
      rethrow;
    }
  }

  Future<PaginatedVideoModel> searchForVideos(String query,{int page = 1, int perPage = 10})async{
    try {
      final response = await _dio.get(
          '/search',
          queryParameters: {
            'query': query,
            'page': page,
            'per_page': perPage
          }
      );
      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        return PaginatedVideoModel.fromJson(json);
      }
      else {
        throw Exception('Failed to fetch data: ${response.data}');
      }
    }
    on DioException catch(e){
      if(e.type==DioExceptionType.connectionTimeout){
        throw Exception('Connection timeout');
      }
      throw e.toString();
    }
    catch(e){
      rethrow;
    }
  }

  Future<PaginatedVideoModel> fetchMoreSearchedVideos(String nextPageUrl)async{
    try {
      final response = await _dio.getUri(Uri.parse(nextPageUrl));

      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        return PaginatedVideoModel.fromJson(json);
      }
      else {
        throw Exception('Failed to fetch more videos: ${response.data}');
      }
    }
    on DioException catch(e){
      if(e.type==DioExceptionType.connectionTimeout){
        throw Exception('Connection timeout');
      }
      throw e.toString();
    }
    catch(e){
      rethrow;
    }
  }
}

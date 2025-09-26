import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learning_riverpod/models/pagination_model.dart';

class ApiService {

  static const String apiKey = 'zfHJHKlR0IdkBiz6iiY9nyadPf4uFggIUIkHFy1HYoA8bwyffBkdV9MV';
  static const String baseUrl = 'https://api.pexels.com/v1/curated';

  Future<PaginationModel> fetchPhotos({int page = 1, int perPage = 20}) async {
    final url = '$baseUrl?page=$page&per_page=$perPage';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': apiKey},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PaginationModel.fromJson(json);
      }
      else {
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
        headers: {'Authorization': apiKey},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PaginationModel.fromJson(json);
      }
      else {
        throw Exception('Failed to fetch next page: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<PaginationModel> getCategoryPhotos(String category, {int page = 1, int limit = 20})async{

    String url = 'https://api.pexels.com/v1/search?query=$category&page=$page&per_page=$limit';

    try {
      final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': apiKey
          }
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PaginationModel.fromJson(json);
      }
      else {
        throw Exception('Something went wrong, ${response.body}');
      }
    }
    catch(e){
      rethrow;
    }
  }

  Future<PaginationModel> getMoreCategoryPhotos(String nextPage)async{
    try {
      final response = await http.get(
          Uri.parse(nextPage),
          headers: {
            'Authorization': apiKey
          }
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PaginationModel.fromJson(json);
      }
      else {
        throw Exception('Something went wrong, ${response.body}');
      }
    }
    catch(e){
      rethrow;
    }
  }

  Future<PaginationModel> searchPhotos(String query, {int page = 1, int limit = 20}) async {
    final url = 'https://api.pexels.com/v1/search?query=$query&page=$page&per_page=$limit';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': apiKey},
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


  Future<PaginationModel> searchMorePhotos(String nextPage)async{

    try {
      final response = await http.get(
          Uri.parse(nextPage),
          headers: {
            'Authorization': apiKey
          }
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PaginationModel.fromJson(json);
      }
      else {
        throw Exception('Something went wrong, ${response.body}');
      }
    }
    catch(e){
      rethrow;
    }
  }
}

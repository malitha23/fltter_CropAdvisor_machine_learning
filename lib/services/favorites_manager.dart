import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agriculture/screens/getCropsWithSimilarSoilType.dart';

class FavoritesManager {
  static const String _baseUrl =
      'http://10.0.2.2:8000/api'; // Replace with your API base URL

  /// Saves the favorite status of a crop.
  static Future<void> saveFavorite(
      Crop crop, bool isFavorite, String token) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({'crop_id': crop.id});
    final url = Uri.parse('$_baseUrl/favorites');

    try {
      if (isFavorite) {
        final response = await http.post(url, headers: headers, body: body);
        if (response.statusCode != 200) {
          throw Exception('Failed to add crop to favorites: ${response.body}');
        }
      } else {
        final request = http.Request('DELETE', url)
          ..headers.addAll(headers)
          ..body = body;
        final response = await http.Client().send(request);
        if (response.statusCode != 200) {
          final responseBody = await response.stream.bytesToString();
          throw Exception(
              'Failed to remove crop from favorites: $responseBody');
        }
      }
    } catch (e) {
      print('Error saving favorite status: $e');
    }
  }

  /// Loads the list of favorite crop objects.
  static Future<List<Crop>> loadFavorites(String token) async {
    final url = Uri.parse('$_baseUrl/favorites');
    final headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          final cropJson = item['crop'];
          return Crop.fromJson(cropJson);
        }).toList();
      } else {
        throw Exception('Failed to load favorites: ${response.body}');
      }
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }
}

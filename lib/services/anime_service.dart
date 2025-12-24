import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime.dart';

class AnimeService {
  static const String baseUrl = 'https://api.jikan.moe/v4';

  // Add delay to respect API rate limits
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<List<Anime>> getTopAnime({String type = 'movie'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/top/anime?type=$type&limit=20'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List animeList = data['data'] ?? [];
        return animeList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load anime');
      }
    } catch (e) {
      print('Error fetching top anime: $e');
      return [];
    }
  }

  Future<List<Anime>> getTrendingAnime() async {
    try {
      await _delay();
      final response = await http.get(
        Uri.parse('$baseUrl/top/anime?filter=airing&limit=15'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List animeList = data['data'] ?? [];
        return animeList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trending anime');
      }
    } catch (e) {
      print('Error fetching trending anime: $e');
      return [];
    }
  }

  Future<List<Anime>> getUpcomingAnime() async {
    try {
      await _delay();
      final response = await http.get(
        Uri.parse('$baseUrl/seasons/upcoming?limit=15'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List animeList = data['data'] ?? [];
        return animeList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load upcoming anime');
      }
    } catch (e) {
      print('Error fetching upcoming anime: $e');
      return [];
    }
  }

  Future<List<Anime>> searchAnime(String query) async {
    try {
      if (query.isEmpty) return [];

      await _delay();
      final response = await http.get(
        Uri.parse('$baseUrl/anime?q=$query&limit=20'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List animeList = data['data'] ?? [];
        return animeList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search anime');
      }
    } catch (e) {
      print('Error searching anime: $e');
      return [];
    }
  }

  Future<Anime?> getAnimeById(int id) async {
    try {
      await _delay();
      final response = await http.get(
        Uri.parse('$baseUrl/anime/$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Anime.fromJson(data['data']);
      } else {
        throw Exception('Failed to load anime details');
      }
    } catch (e) {
      print('Error fetching anime details: $e');
      return null;
    }
  }

  Future<List<Anime>> getRecommendations(int animeId) async {
    try {
      await _delay();
      final response = await http.get(
        Uri.parse('$baseUrl/anime/$animeId/recommendations'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List recommendations = data['data'] ?? [];
        return recommendations
            .take(10)
            .map((rec) => Anime.fromJson(rec['entry']))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching recommendations: $e');
      return [];
    }
  }
}
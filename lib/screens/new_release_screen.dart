import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/anime.dart';
import '../services/anime_service.dart';
import '../screens/anime_detail_screen.dart';

class NewReleasesScreen extends StatefulWidget {
  const NewReleasesScreen({super.key});

  @override
  State<NewReleasesScreen> createState() => _NewReleasesScreenState();
}

class _NewReleasesScreenState extends State<NewReleasesScreen> {
  final AnimeService _animeService = AnimeService();

  List<Anime> upcomingAnime = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUpcomingAnime();
  }

  Future<void> _fetchUpcomingAnime() async {
    final result = await _animeService.getUpcomingAnime();

    if (!mounted) return;

    setState(() {
      upcomingAnime = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : upcomingAnime.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _fetchUpcomingAnime,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: upcomingAnime.length,
          itemBuilder: (context, index) {
            return _AnimeListItem(anime: upcomingAnime[index]);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upcoming, size: 80, color: Colors.grey[600]),
          const SizedBox(height: 16),
          const Text(
            'No upcoming anime',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check back later',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// =================== LIST ITEM WIDGET =====================
// ==========================================================

class _AnimeListItem extends StatelessWidget {
  final Anime anime;

  const _AnimeListItem({required this.anime});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnimeDetailScreen(anime: anime),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPoster(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // POSTER
  Widget _buildPoster() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      child: CachedNetworkImage(
        imageUrl: anime.imageUrl ?? '',
        width: 100,
        height: 140,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: 100,
          height: 140,
          color: Colors.grey[800],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => Container(
          width: 100,
          height: 140,
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.white),
        ),
      ),
    );
  }

  // CONTENT
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            anime.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // Release date
          if (anime.aired != null)
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    anime.aired!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 6),

          // Rating + Type
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 14),
              const SizedBox(width: 4),
              Text(
                anime.scoreString,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
              if (anime.type != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    anime.type!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Synopsis
          if (anime.synopsis != null)
            Text(
              anime.synopsis!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
        ],
      ),
    );
  }
}

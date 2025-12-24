import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../widgets/anime_card.dart';
import 'anime_detail_screen.dart';

class ViewAllScreen extends StatelessWidget {
  final String title;
  final List<Anime> animeList;

  const ViewAllScreen({
    super.key,
    required this.title,
    required this.animeList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: animeList.isEmpty
          ? Center(
        child: Text(
          'No anime available',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.55,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: animeList.length,
        itemBuilder: (context, index) {
          return _buildAnimeCard(context, animeList[index]);
        },
      ),
    );
  }

  Widget _buildAnimeCard(BuildContext context, Anime anime) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnimeDetailScreen(anime: anime),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                anime.imageUrl ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.error, color: Colors.white),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            anime.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 12),
              const SizedBox(width: 2),
              Text(
                anime.scoreString,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
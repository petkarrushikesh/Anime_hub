import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/anime.dart';
import '../services/anime_service.dart';
import '../widgets/anime_card.dart';

class AnimeDetailScreen extends StatefulWidget {
  final Anime anime;

  const AnimeDetailScreen({super.key, required this.anime});

  @override
  State<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen> {
  final AnimeService _animeService = AnimeService();

  List<Anime> relatedAnime = [];
  bool isLoadingRelated = true;

  @override
  void initState() {
    super.initState();
    _loadRelatedAnime();
  }

  Future<void> _loadRelatedAnime() async {
    final result =
    await _animeService.getRecommendations(widget.anime.malId);

    if (!mounted) return;

    setState(() {
      relatedAnime = result;
      isLoadingRelated = false;
    });
  }

  // ================= TRAILER =================
  Future<void> _openTrailer() async {
    final String? trailerUrl = widget.anime.trailerUrl;

    if (trailerUrl == null || trailerUrl.isEmpty) {
      _showSnackBar('Trailer not available for this anime');
      return;
    }

    final Uri uri = Uri.parse(trailerUrl);

    if (!await canLaunchUrl(uri)) {
      _showSnackBar('Unable to open trailer');
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Synopsis
                  const Text(
                    'Synopsis',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.anime.synopsis ?? 'No synopsis available.',
                    style: TextStyle(
                      color: Colors.grey[400],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildInfoSection(),

                  const SizedBox(height: 24),

                  // Related Anime
                  if (isLoadingRelated)
                    const Center(child: CircularProgressIndicator())
                  else if (relatedAnime.isNotEmpty) ...[
                    const Text(
                      'Related Anime',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 230,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedAnime.length,
                        itemBuilder: (context, index) =>
                            AnimeCard(anime: relatedAnime[index]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    String? thumbnailUrl;

    if (widget.anime.trailerUrl != null) {
      final id = _extractYoutubeId(widget.anime.trailerUrl!);
      if (id != null) {
        thumbnailUrl = 'https://img.youtube.com/vi/$id/hqdefault.jpg';
      }
    }

    return Stack(
      children: [
        SizedBox(
          height: 400,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: thumbnailUrl ?? widget.anime.imageUrl ?? '',
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.grey[800]),
            errorWidget: (_, __, ___) =>
            const Icon(Icons.broken_image, size: 40),
          ),
        ),
        Container(
          height: 400,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.9),
              ],
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 16,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: widget.anime.imageUrl ?? '',
                  width: 120,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.anime.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(widget.anime.scoreString),
                        const SizedBox(width: 12),
                        Text(widget.anime.yearString,
                            style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (widget.anime.genres.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        children:
                        widget.anime.genres.take(3).map((genre) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              genre,
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openTrailer,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  // INFO
  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (widget.anime.type != null)
            _infoRow('Type', widget.anime.type!),
          if (widget.anime.episodes != null)
            _infoRow('Episodes', widget.anime.episodes.toString()),
          if (widget.anime.status != null)
            _infoRow('Status', widget.anime.status!),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500])),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String? _extractYoutubeId(String url) {
    final regExp = RegExp(
      r'(?:v=|\/)([0-9A-Za-z_-]{11}).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
}

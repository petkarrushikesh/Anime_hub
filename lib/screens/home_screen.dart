import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/anime.dart';
import '../services/anime_service.dart';
import '../widgets/anime_card.dart';
import '../widgets/shrimmer_loading.dart';
import '../screens/anime_detail_screen.dart';
import '../screens/view_all_screen.dart';
import 'my_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AnimeService _animeService = AnimeService();

  Anime? randomAnime;
  List<Anime> trendingAnime = [];
  List<Anime> upcomingAnime = [];

  bool isLoadingRandom = true;
  bool isLoadingTrending = true;
  bool isLoadingUpcoming = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadRandomAnime(),
      _loadTrendingAnime(),
      _loadUpcomingAnime(),
    ]);
  }

  Future<void> _loadRandomAnime() async {
    final list = await _animeService.getTopAnime();
    if (list.isNotEmpty) {
      randomAnime = list[Random().nextInt(list.length)];
    }
    setState(() => isLoadingRandom = false);
  }

  Future<void> _loadTrendingAnime() async {
    trendingAnime = await _animeService.getTrendingAnime();
    setState(() => isLoadingTrending = false);
  }

  Future<void> _loadUpcomingAnime() async {
    upcomingAnime = await _animeService.getUpcomingAnime();
    setState(() => isLoadingUpcoming = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRandomAnime(),
              const SizedBox(height: 24),
              _buildSection('Trending Anime', trendingAnime, isLoadingTrending),
              const SizedBox(height: 24),
              _buildSection('Upcoming Anime', upcomingAnime, isLoadingUpcoming),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  //  RANDOM
  Widget _buildRandomAnime() {
    if (isLoadingRandom) {
      return const ShimmerLoading(
        width: double.infinity,
        height: 400,
        borderRadius: BorderRadius.zero,
      );
    }

    if (randomAnime == null) {
      return const SizedBox(
        height: 400,
        child: Center(child: Text('No anime available')),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnimeDetailScreen(anime: randomAnime!),
        ),
      ),
      child: SizedBox(
        height: 400,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: randomAnime!.imageUrl ?? '',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    randomAnime!.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(randomAnime!.scoreString),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _openTrailer(randomAnime!.trailerUrl),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MyListScreen()),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('My List'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // SECTION
  Widget _buildSection(
      String title, List<Anime> list, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ViewAllScreen(title: title, animeList: list),
                  ),
                ),
                child: const Text('View All',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: isLoading
              ? ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (_, __) => const AnimeCardShimmer(),
          )
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (_, i) => AnimeCard(anime: list[i]),
          ),
        ),
      ],
    );
  }

  // TRAILER
  Future<void> _openTrailer(String? url) async {
    if (url == null) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

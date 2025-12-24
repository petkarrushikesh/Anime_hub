import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/anime.dart';
import '../services/anime_service.dart';
import '../widgets/anime_card.dart';
import '../widgets/shrimmer_loading.dart';
import 'anime_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AnimeService _animeService = AnimeService();
  final TextEditingController _searchController = TextEditingController();

  List<Anime> searchResults = [];
  bool isLoading = false;
  bool hasSearched = false;
  bool isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // SEARCH
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults.clear();
        hasSearched = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    final result = await _animeService.searchAnime(query);

    if (!mounted) return;

    setState(() {
      searchResults = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // SEARCH BAR
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onSubmitted: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search anime...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon:
                const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear,
                      color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                    setState(() {});
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                isGridView ? Icons.view_list : Icons.grid_view,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() => isGridView = !isGridView);
              },
            ),
          ),
        ],
      ),
    );
  }

  // BODY
  Widget _buildBody() {
    if (isLoading) {
      return isGridView ? const GridShimmer() : _buildListShimmer();
    }

    if (!hasSearched) {
      return _buildInitialState();
    }

    if (searchResults.isEmpty) {
      return _buildEmptyState();
    }

    return isGridView ? _buildGridView() : _buildListView();
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'Search for your favorite anime',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied,
              size: 80, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // GRID
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: searchResults.length,
      itemBuilder: (_, index) =>
          AnimeGridCard(anime: searchResults[index]),
    );
  }

  // LIST
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchResults.length,
      itemBuilder: (_, index) =>
          _SearchListItem(anime: searchResults[index]),
    );
  }

  Widget _buildListShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerLoading(
              width: double.infinity,
              height: 200,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading(width: 200, height: 16),
                  SizedBox(height: 8),
                  ShimmerLoading(width: 150, height: 12),
                  SizedBox(height: 8),
                  ShimmerLoading(width: double.infinity, height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// LIST ITEM WIDGET

class _SearchListItem extends StatelessWidget {
  final Anime anime;

  const _SearchListItem({required this.anime});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: CachedNetworkImage(
        imageUrl: anime.imageUrl ?? '',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: 200,
          color: Colors.grey[800],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => Container(
          height: 200,
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Row(
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(anime.scoreString,
                style: TextStyle(color: Colors.grey[400])),
            const SizedBox(width: 12),
            Text(anime.yearString,
                style: TextStyle(color: Colors.grey[400])),
          ],
        ),
        if (anime.genres.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: anime.genres.take(3).map((genre) {
              return Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  genre,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        if (anime.synopsis != null) ...[
          const SizedBox(height: 8),
          Text(
            anime.synopsis!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

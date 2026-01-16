import 'package:flutter/material.dart';
import 'package:flutter_movie_clean_architecture/core/config/app_constant.dart';
import 'package:flutter_movie_clean_architecture/core/hive/favorite_model.dart';
import 'package:flutter_movie_clean_architecture/core/hive/hive_helper.dart';
import 'package:flutter_movie_clean_architecture/core/localization/localization_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  int _currentIndex = 0;
  late Future<List<Favorite>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _favoritesFuture = _getFavoritesByType();
    });
  }

  Future<List<Favorite>> _getFavoritesByType() async {
    switch (_currentIndex) {
      case 0:
        return await HiveHelper.getFavoritesByType('movie');
      case 1:
        return await HiveHelper.getFavoritesByType('tv');
      case 2:
        return await HiveHelper.getFavoritesByType('celebrity');
      default:
        return await HiveHelper.getAllFavorites();
    }
  }

  Future<void> _refreshFavorites() async {
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Favorite>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(context.translate('error_loading_favorites', args: [snapshot.error.toString()])),
            );
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    context.translate('no_favorites_yet'),
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.translate('start_adding_favorites'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshFavorites,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      switch (favorite.type) {
                        case 'movie':
                          context.push('/movie/${favorite.itemId}');
                          break;
                        case 'tv':
                          context.push('/tv/${favorite.itemId}');
                          break;
                        case 'celebrity':
                          context.push('/artistId/${favorite.itemId}');
                          break;
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: favorite.posterPath.isNotEmpty
                                ? Image.network(
                                    '$IMAGE_URL${favorite.posterPath}',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) =>
                                        _buildPlaceholderImage(),
                                  )
                                : _buildPlaceholderImage(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                favorite.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    favorite.type.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 10,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    padding: EdgeInsets.zero,
                                    onPressed: () async {
                                      await HiveHelper.deleteFavorite(
                                          favorite.itemId, favorite.type);
                                      _refreshFavorites();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          _loadFavorites();
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.movie),
          label: context.translate('movies'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.tv),
          label: context.translate('tv_series'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people),
          label: context.translate('celebrities'),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}
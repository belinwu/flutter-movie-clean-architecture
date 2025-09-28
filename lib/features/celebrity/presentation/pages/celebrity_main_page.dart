import 'package:flutter/material.dart';
import 'package:flutter_movie_clean_architecture/core/localization/localization_helper.dart';
import 'package:flutter_movie_clean_architecture/features/celebrity/presentation/pages/popular_persons_page.dart';
import 'package:flutter_movie_clean_architecture/features/celebrity/presentation/pages/trending_persons_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CelebrityMainPage extends ConsumerStatefulWidget {
  const CelebrityMainPage({super.key});

  @override
  ConsumerState<CelebrityMainPage> createState() => _CelebrityMainPageState();
}

class _CelebrityMainPageState extends ConsumerState<CelebrityMainPage> {
  int _selectedIndex = 0;

  final _pages = [
    const PopularPersonsPage(),
    const TrendingPersonsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: context.translate('popular'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up),
            label: context.translate('trending'),
          ),
        ],
      ),
    );
  }
}
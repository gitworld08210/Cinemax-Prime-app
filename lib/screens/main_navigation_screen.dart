import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'browse_screen.dart';
import 'request_screen.dart';
import 'series_screen.dart';
import 'live_sports_screen.dart';

const Color kAccent = Color(0xFFE11D48);

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  List<Movie> _allMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies({bool forceRefresh = false}) async {
    final movies = await ApiService.fetchMovies(forceRefresh: forceRefresh);
    if (mounted) {
      setState(() {
        _allMovies = movies;
        _isLoading = false;
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: kAccent),
              SizedBox(height: 16),
              Text(
                "Loading Cinemax Prime...",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final pages = [
      HomeScreenContent(movies: _allMovies, onRefresh: () => _loadMovies(forceRefresh: true)),
      BrowseScreen(movies: _allMovies),
      RequestScreen(existingMovies: _allMovies),
      SeriesScreen(movies: _allMovies),
      LiveSportsScreen(movies: _allMovies),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F0F0F),
          border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kAccent,
          unselectedItemColor: const Color(0xFF8A8F98),
          selectedFontSize: 11,
          unselectedFontSize: 10,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          elevation: 10,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Browse',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _currentIndex == 2 ? kAccent.withOpacity(0.2) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  color: _currentIndex == 2 ? kAccent : const Color(0xFFEF4444),
                  size: 24,
                ),
              ),
              label: 'Request',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.tv_rounded),
              label: 'Series',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.live_tv_rounded),
              label: 'Live',
            ),
          ],
        ),
      ),
    );
  }
}

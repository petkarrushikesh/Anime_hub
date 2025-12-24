import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/new_release_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AnimeHubApp());
}

class AnimeHubApp extends StatelessWidget {
  const AnimeHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    NewReleasesScreen(),
  ];

  final List<String> _titles = const [
    'Anime Hub',
    'Search Anime',
    'New Releases',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _currentIndex == 0 ? _buildDrawer() : null,
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // APP BAR
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        _titles[_currentIndex],
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      actions: [
        if (_currentIndex == 0)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _changeTab(1),
          ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _showSettingsDialog,
        ),
      ],
    );
  }

  // BOTTOM NAV
  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _changeTab,
      backgroundColor: Colors.black,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
            icon: Icon(Icons.new_releases), label: 'Releases'),
      ],
    );
  }

  void _changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  // DRAWER
  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.2)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.movie, size: 48, color: Colors.red),
                SizedBox(height: 10),
                Text(
                  'Anime Hub',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _drawerItem(Icons.home, 'Home', 0),
          _drawerItem(Icons.search, 'Search', 1),
          _drawerItem(Icons.new_releases, 'New Releases', 2),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('My List'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('My List coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        _changeTab(index);
      },
    );
  }

  // DIALOGS
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Settings'),
        content: const Text(
          'Settings will be added in future versions.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('About Anime Hub'),
        content: const Text(
          'Anime Hub is a Flutter application built using Jikan API '
              'to explore trending, upcoming, and popular anime.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

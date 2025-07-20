

import 'package:flutter/material.dart';
import 'theme.dart';
import 'pages/home_page_new.dart';
import 'pages/calendar_page.dart';
import 'pages/trends_page.dart';
import 'pages/rankings_page.dart';
import 'pages/profile_page.dart';
import 'widgets/bottom_navigation.dart';
import 'services/hybrid_data_service.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser le service de données hybride
  await HybridDataService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hockey Français - HF',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
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

  final List<Widget> _pages = [
    const HomePage(),
    const CalendarPage(),
    const TrendsPage(),
    const RankingsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
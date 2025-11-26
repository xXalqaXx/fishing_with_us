import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FishingWithUsApp());
}

class FishingWithUsApp extends StatelessWidget {
  const FishingWithUsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fishing With Us',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4B72FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF05071A),
      ),
      home: const RootNavigation(),
    );
  }
}

/// Główny „kontener” z dolnym menu
class RootNavigation extends StatefulWidget {
  const RootNavigation({super.key});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation> {
  int _currentIndex = 0;

  // Tu definiujemy ekrany dla zakładek
  final List<Widget> _pages = const [
    FishingHomeScreen(),
    FishingMapScreen(),
    FishingCatchesScreen(),
    FishingProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Połowy',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Ekran startowy – to co już miałaś
class FishingHomeScreen extends StatelessWidget {
  const FishingHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fishing With Us'), centerTitle: false),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF05071A), Color(0xFF15163A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Witaj w dzienniku wędkarza 🎣',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tu później dodamy:\n'
              '• mapę z łowiskami\n'
              '• listę Twoich połowów\n'
              '• prosty profil użytkownika',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Na razie nic – mapa będzie w osobnej zakładce
                },
                child: const Text('Przejdź do mapy (placeholder)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder – przyszła mapa łowisk
class FishingMapScreen extends StatelessWidget {
  const FishingMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa łowisk')),
      body: const Center(
        child: Text(
          'Tu będzie mapa (Google Maps)\n'
          'z zaznaczonymi łowiskami 🎯',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Placeholder – lista połowów
class FishingCatchesScreen extends StatelessWidget {
  const FishingCatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Twoje połowy')),
      body: const Center(
        child: Text(
          'Tu będzie lista zapisanych połowów 🐟',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Placeholder – prosty profil
class FishingProfileScreen extends StatelessWidget {
  const FishingProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const Center(
        child: Text(
          'Tu będzie prosty profil użytkownika 👤',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

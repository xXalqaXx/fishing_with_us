import 'package:flutter/material.dart';

void main() {
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
      home: const FishingHomeScreen(),
    );
  }
}

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
                  // TODO: tu później przejście do ekranu mapy
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

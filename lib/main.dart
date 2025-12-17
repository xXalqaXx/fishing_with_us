import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
      theme: _appTheme(),
      home: const AuthGate(),
    );
  }

  ThemeData _appTheme() {
    const bg = Color(0xFF05071A);
    const surface = Color(0xFF0B1030);
    const brand = Color(0xFF4B72FF);
    const brand2 = Color(0xFF7A3CFF);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brand,
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface.withOpacity(0.75),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF0B1030),
      ),
      dialogTheme: const DialogThemeData(backgroundColor: surface),
      extensions: const <ThemeExtension<dynamic>>[
        _BrandPalette(bg: bg, surface: surface, brand: brand, brand2: brand2),
      ],
    );
  }
}

@immutable
class _BrandPalette extends ThemeExtension<_BrandPalette> {
  final Color bg;
  final Color surface;
  final Color brand;
  final Color brand2;

  const _BrandPalette({
    required this.bg,
    required this.surface,
    required this.brand,
    required this.brand2,
  });

  @override
  _BrandPalette copyWith({
    Color? bg,
    Color? surface,
    Color? brand,
    Color? brand2,
  }) {
    return _BrandPalette(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      brand: brand ?? this.brand,
      brand2: brand2 ?? this.brand2,
    );
  }

  @override
  _BrandPalette lerp(ThemeExtension<_BrandPalette>? other, double t) {
    if (other is! _BrandPalette) return this;
    return _BrandPalette(
      bg: Color.lerp(bg, other.bg, t) ?? bg,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      brand: Color.lerp(brand, other.brand, t) ?? brand,
      brand2: Color.lerp(brand2, other.brand2, t) ?? brand2,
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }
        if (snapshot.hasData) return const RootShell();
        return const AuthScreen();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final pass = _pass.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _toast('Podaj e-mail i hasło');
      return;
    }

    setState(() => _loading = true);

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: pass,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: pass,
        );
      }
    } on FirebaseAuthException catch (e) {
      _toast(e.message ?? 'Błąd logowania');
    } catch (_) {
      _toast('Nieznany błąd');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<_BrandPalette>()!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.bg, palette.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          'Fishing With Us',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isLogin
                              ? 'Zaloguj się i wracaj do połowów.'
                              : 'Załóż konto i zacznij zapisywać połowy.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pass,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Hasło'),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            child: Text(_isLogin ? 'Zaloguj' : 'Zarejestruj'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _loading
                                ? null
                                : () => setState(() => _isLogin = !_isLogin),
                            child: Text(
                              _isLogin
                                  ? 'Nie masz konta? Rejestracja'
                                  : 'Masz konto? Logowanie',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 1;

  final _pages = const [
    HomeScreen(),
    MapScreen(),
    CatchesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth >= 900;

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (v) => setState(() => _index = v),
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: IconButton(
                      tooltip: 'Wyloguj',
                      onPressed: () => FirebaseAuth.instance.signOut(),
                      icon: const Icon(Icons.logout),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.map_outlined),
                      selectedIcon: Icon(Icons.map),
                      label: Text('Mapa'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.timeline_outlined),
                      selectedIcon: Icon(Icons.timeline),
                      label: Text('Połowy'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Profil'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _pages[_index]),
              ],
            ),
          );
        }

        return Scaffold(
          body: _pages[_index],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (v) => setState(() => _index = v),
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
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<_BrandPalette>()!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fishing With Us'),
        actions: [
          IconButton(
            tooltip: 'Wyloguj',
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.bg, palette.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dziennik wędkarza',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Zapisuj połowy, dodawaj pinezki na mapie i trzymaj wszystko w jednym miejscu.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          const Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _InfoChip(icon: Icons.map, text: 'Mapa łowisk'),
                              _InfoChip(
                                icon: Icons.timeline,
                                text: 'Historia połowów',
                              ),
                              _InfoChip(icon: Icons.comment, text: 'Notatki'),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.map),
                              label: const Text('Przejdź do mapy'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(text));
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _uid = FirebaseAuth.instance.currentUser?.uid;

  final _center = const LatLng(51.1079, 17.0385);

  CollectionReference<Map<String, dynamic>> get _pinsCol => FirebaseFirestore
      .instance
      .collection('users')
      .doc(_uid)
      .collection('pins');

  Future<void> _addPinAt(LatLng latLng) async {
    final pin = await showModalBottomSheet<_PinDraft>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _AddPinSheet(initialLatLng: latLng),
    );

    if (pin == null) return;

    await _pinsCol.add({
      'species': pin.species,
      'spot': pin.spot,
      'note': pin.note,
      'lat': pin.latLng.latitude,
      'lng': pin.latLng.longitude,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _openPinDetails(Map<String, dynamic> data) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final species = (data['species'] ?? '').toString();
        final spot = (data['spot'] ?? '').toString();
        final note = (data['note'] ?? '').toString();
        final lat = (data['lat'] as num?)?.toDouble();
        final lng = (data['lng'] as num?)?.toDouble();

        return AlertDialog(
          title: Text(species.isEmpty ? 'Szczegóły pinezki' : species),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (spot.isNotEmpty) Text('Miejsce: $spot'),
              if (note.isNotEmpty) Text('Notatka: $note'),
              const SizedBox(height: 10),
              if (lat != null && lng != null)
                Text(
                  'Lokalizacja: ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Zamknij'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<_BrandPalette>()!;
    if (_uid == null) return const _LoadingScreen();

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa łowisk')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.bg, palette.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _pinsCol.orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snap) {
            final docs = snap.data?.docs ?? [];

            return FlutterMap(
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 12,
                onLongPress: (tapPos, latLng) => _addPinAt(latLng),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.fishing_with_us',
                ),
                MarkerLayer(
                  markers: docs.map((d) {
                    final data = d.data();
                    final lat =
                        (data['lat'] as num?)?.toDouble() ?? _center.latitude;
                    final lng =
                        (data['lng'] as num?)?.toDouble() ?? _center.longitude;
                    final pos = LatLng(lat, lng);

                    return Marker(
                      point: pos,
                      width: 44,
                      height: 44,
                      child: GestureDetector(
                        onTap: () => _openPinDetails(data),
                        child: _PinIcon(seed: d.id),
                      ),
                    );
                  }).toList(),
                ),
                const Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: _GlassCard(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.touch_app, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Przytrzymaj palcem / myszką na mapie, żeby dodać pinezkę.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PinIcon extends StatelessWidget {
  final String seed;
  const _PinIcon({required this.seed});

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<_BrandPalette>()!;
    final hash = seed.codeUnits.fold<int>(0, (p, c) => p + c);
    final mix = (hash % 100) / 100.0;
    final color =
        Color.lerp(palette.brand, palette.brand2, mix) ?? palette.brand;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.18),
        border: Border.all(color: color.withOpacity(0.7)),
      ),
      child: const Center(child: Icon(Icons.location_on, size: 22)),
    );
  }
}

class _PinDraft {
  final String species;
  final String spot;
  final String note;
  final LatLng latLng;

  _PinDraft({
    required this.species,
    required this.spot,
    required this.note,
    required this.latLng,
  });
}

class _AddPinSheet extends StatefulWidget {
  final LatLng initialLatLng;
  const _AddPinSheet({required this.initialLatLng});

  @override
  State<_AddPinSheet> createState() => _AddPinSheetState();
}

class _AddPinSheetState extends State<_AddPinSheet> {
  final _species = TextEditingController();
  final _spot = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _species.dispose();
    _spot.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final species = _species.text.trim();
    final spot = _spot.text.trim();
    final note = _note.text.trim();

    if (species.isEmpty && spot.isEmpty && note.isEmpty) {
      Navigator.pop(context);
      return;
    }

    Navigator.pop(
      context,
      _PinDraft(
        species: species,
        spot: spot,
        note: note,
        latLng: widget.initialLatLng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: 16 + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          Text(
            'Nowa pinezka',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _species,
            decoration: const InputDecoration(labelText: 'Gatunek'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _spot,
            decoration: const InputDecoration(labelText: 'Miejsce'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _note,
            decoration: const InputDecoration(labelText: 'Notatka'),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Lokalizacja: ${widget.initialLatLng.latitude.toStringAsFixed(5)}, '
              '${widget.initialLatLng.longitude.toStringAsFixed(5)}',
              style: const TextStyle(color: Colors.white60),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Zapisz pinezkę'),
            ),
          ),
        ],
      ),
    );
  }
}

class CatchesScreen extends StatefulWidget {
  const CatchesScreen({super.key});

  @override
  State<CatchesScreen> createState() => _CatchesScreenState();
}

class _CatchesScreenState extends State<CatchesScreen> {
  final _uid = FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _catchesCol => FirebaseFirestore
      .instance
      .collection('users')
      .doc(_uid)
      .collection('catches');

  Future<void> _addCatch() async {
    final draft = await showDialog<_CatchDraft>(
      context: context,
      builder: (context) => const _AddCatchDialog(),
    );

    if (draft == null || _uid == null) return;

    await _catchesCol.add({
      'species': draft.species,
      'spot': draft.spot,
      'weightG': draft.weightG,
      'lengthCm': draft.lengthCm,
      'released': draft.released,
      'note': draft.note,
      'lat': draft.lat,
      'lng': draft.lng,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteDoc(String id) async {
    await _catchesCol.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<_BrandPalette>()!;
    if (_uid == null) return const _LoadingScreen();

    return Scaffold(
      appBar: AppBar(title: const Text('Twoje połowy')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCatch,
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.bg, palette.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _catchesCol
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snap) {
            final docs = snap.data?.docs ?? [];

            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  'Na razie brak połowów.\nDodaj pierwszy przyciskiem +',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final doc = docs[i];
                final d = doc.data();

                final species = (d['species'] ?? '').toString();
                final spot = (d['spot'] ?? '').toString();
                final weightG = (d['weightG'] as num?)?.toInt() ?? 0;
                final lengthCm = (d['lengthCm'] as num?)?.toInt() ?? 0;
                final released = (d['released'] as bool?) ?? true;

                return _GlassCard(
                  child: ListTile(
                    leading: const Icon(Icons.water),
                    title: Text(species.isEmpty ? 'Połów' : species),
                    subtitle: Text(
                      '$spot • $lengthCm cm • $weightG g • ${released ? 'wypuszczona' : 'zabrana'}',
                    ),
                    trailing: IconButton(
                      tooltip: 'Usuń',
                      onPressed: () => _deleteDoc(doc.id),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CatchDraft {
  final String species;
  final String spot;
  final int weightG;
  final int lengthCm;
  final bool released;
  final String note;
  final double? lat;
  final double? lng;

  _CatchDraft({
    required this.species,
    required this.spot,
    required this.weightG,
    required this.lengthCm,
    required this.released,
    required this.note,
    this.lat,
    this.lng,
  });
}

class _AddCatchDialog extends StatefulWidget {
  const _AddCatchDialog({super.key});

  @override
  State<_AddCatchDialog> createState() => _AddCatchDialogState();
}

class _AddCatchDialogState extends State<_AddCatchDialog> {
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _spotController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  bool _released = true;

  @override
  void dispose() {
    _speciesController.dispose();
    _spotController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _noteController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _save() {
    final species = _speciesController.text.trim();
    final spot = _spotController.text.trim();
    final weight = int.tryParse(_weightController.text.trim());
    final length = int.tryParse(_lengthController.text.trim());
    final note = _noteController.text.trim();

    if (species.isEmpty || spot.isEmpty || weight == null || length == null) {
      return;
    }

    double? lat;
    double? lng;
    if (_latController.text.isNotEmpty && _lngController.text.isNotEmpty) {
      lat = double.tryParse(_latController.text.replaceAll(',', '.'));
      lng = double.tryParse(_lngController.text.replaceAll(',', '.'));
    }

    Navigator.pop(
      context,
      _CatchDraft(
        species: species,
        spot: spot,
        weightG: weight,
        lengthCm: length,
        released: _released,
        note: note,
        lat: lat,
        lng: lng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nowy połów'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _speciesController,
              decoration: const InputDecoration(labelText: 'Gatunek'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _spotController,
              decoration: const InputDecoration(labelText: 'Miejsce'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Waga [g]'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lengthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Długość [cm]'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Notatka'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _latController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Szerokość (lat)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lngController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Długość (lng)'),
            ),
            const SizedBox(height: 14),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Co z rybą?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            RadioListTile<bool>(
              title: const Text('Wróciła do wody'),
              value: true,
              groupValue: _released,
              onChanged: (v) => setState(() => _released = v ?? true),
            ),
            RadioListTile<bool>(
              title: const Text('Zabieram ze sobą'),
              value: false,
              groupValue: _released,
              onChanged: (v) => setState(() => _released = v ?? true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Zapisz')),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<_BrandPalette>()!;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.bg, palette.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 6),
                    const Icon(Icons.person, size: 74),
                    const SizedBox(height: 12),
                    Text(user?.email ?? 'Brak e-maila'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        icon: const Icon(Icons.logout),
                        label: const Text('Wyloguj'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<_BrandPalette>()!;
    return Container(
      decoration: BoxDecoration(
        color: palette.surface.withOpacity(0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            spreadRadius: 2,
            color: Colors.black.withOpacity(0.35),
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }
}

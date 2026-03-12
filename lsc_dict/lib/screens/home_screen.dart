import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lsc_dict/screens/entry_view_oyentes.dart';
import 'package:lsc_dict/screens/temas.dart';
import 'package:lsc_dict/widgets/daily_sign_card.dart';
import 'package:lsc_dict/widgets/nav_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Map<String, String> aliases = {};
  bool isLoadingAliases = true;

  List<String> _allKeys = [];
  List<String> suggestions = [];
  static const int maxSuggestions = 4;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadAliases();

    searchController.addListener(_updateSuggestions);

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      } else {
        _updateSuggestions();
      }
    });
  }

  Future<void> _loadAliases() async {
    final raw = await rootBundle.loadString('assets/data/aliases.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;

    final loaded = <String, String>{};
    for (final entry in decoded.entries) {
      final key = entry.key.toString();
      if (key.startsWith('_')) continue;
      loaded[key] = entry.value.toString();
    }

    final keys = loaded.keys.toList()..sort();

    if (!mounted) return;
    setState(() {
      aliases = loaded;
      _allKeys = keys;
      isLoadingAliases = false;
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  String normalizeEs(String input) {
    final s = input.trim().toLowerCase();
    return s
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _removeOverlay();

    if (!_focusNode.hasFocus || suggestions.isEmpty) return;

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 320,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 56),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final s in suggestions) ...[
                      InkWell(
                        onTap: () {
                          searchController.text = s;
                          searchController.selection =
                              TextSelection.fromPosition(
                            TextPosition(offset: s.length),
                          );
                          _removeOverlay();
                          _searchAndOpen(s);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (s != suggestions.last)
                        const Divider(height: 1, thickness: 1),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _updateSuggestions() {
    if (!_focusNode.hasFocus) {
      suggestions = [];
      _removeOverlay();
      return;
    }

    final q = normalizeEs(searchController.text);

    if (q.isEmpty) {
      suggestions = [];
      _removeOverlay();
      return;
    }

    final matches = <String>[];
    for (final k in _allKeys) {
      if (k.startsWith(q)) {
        matches.add(k);
        if (matches.length >= maxSuggestions) break;
      }
    }

    suggestions = matches;

    if (suggestions.isEmpty) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  Future<void> _searchAndOpen(String rawQuery) async {
    final q = normalizeEs(rawQuery);
    if (q.isEmpty) return;

    final canonical = aliases[q];
    if (canonical == null) {
      _removeOverlay();
      _showNotFound(q);
      return;
    }

    _removeOverlay();
    FocusScope.of(context).unfocus();

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EntryView(id: canonical)),
    );

    if (!mounted) return;
    searchController.clear();
    suggestions = [];
    _removeOverlay();
    setState(() {});
  }

  void _showNotFound(String q) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('No encontrado'),
        content: Text('No encontré "$q" en el diccionario todavía.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _removeOverlay();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Diccionario LSC',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 240, 244, 252),
                Color.fromARGB(255, 224, 231, 252),
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                        child: DailySignCard(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const EntryView(id: 'prueba'),
                              ),
                            );
                          },
                        ),
                      ),
                      CompositedTransformTarget(
                        link: _layerLink,
                        child: SizedBox(
                          width: 340,
                          child: TextField(
                            controller: searchController,
                            focusNode: _focusNode,
                            enabled: !isLoadingAliases,
                            textInputAction: TextInputAction.search,
                            onSubmitted: _searchAndOpen,
                            decoration: InputDecoration(
                              hintText: isLoadingAliases
                                  ? 'Cargando...'
                                  : 'Buscar seña',
                              hintStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 20,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: const BorderSide(
                                  color: Color(0xFFBDBDBD),
                                  width: 0.8,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: const BorderSide(
                                  color: Color(0xFFBDBDBD),
                                  width: 0.8,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: const BorderSide(
                                  color: Color(0xFF9E9E9E),
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 30, 0, 10),
                          child: Text(
                            'Explorar señas',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade900,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            NavCard(
                              title: 'Configuración manual',
                              assetPath: 'assets/images/hand_config.png',
                              onTap: () {},
                            ),
                            NavCard(
                              title: 'Lugar de la seña',
                              assetPath: 'assets/images/hand_place.png',
                              onTap: () {},
                            ),
                            NavCard(
                              title: 'Movimiento',
                              assetPath: 'assets/images/hand_move.png',
                              onTap: () {},
                            ),
                            NavCard(
                              title: 'Temas',
                              assetPath: 'assets/images/categories.png',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const TemasScreen(),
                                  ),
                                );
                              },
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
        ),
      ),
    );
  }
}
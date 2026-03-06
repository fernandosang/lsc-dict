import 'dart:convert';
import 'package:flutter/cupertino.dart';
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
            offset: Offset(0, 52),
            child: CupertinoPopupSurface(
              isSurfacePainted: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final s in suggestions) ...[
                      CupertinoButton(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        alignment: Alignment.centerLeft,
                        onPressed: () {
                          searchController.text = s;
                          searchController.selection =
                              TextSelection.fromPosition(
                                TextPosition(offset: s.length),
                              );
                          _removeOverlay();
                          _searchAndOpen(s);
                        },
                        child: Text(
                          s,
                          style: TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.label,
                          ),
                        ),
                      ),
                      if (s != suggestions.last)
                        SizedBox(
                          height: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: CupertinoColors.separator,
                            ),
                          ),
                        ),
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

    // Close overlay + keyboard before navigating
    _removeOverlay();
    FocusScope.of(context).unfocus();

    await Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (_) => EntryView(id: canonical)));

    // ✅ When coming back, reset search bar + suggestions
    if (!mounted) return;
    searchController.clear();
    suggestions = [];
    _removeOverlay();
    setState(() {});
  }

  void _showNotFound(String q) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('No encontrado'),
        content: Text('No encontré "$q" en el diccionario todavía.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
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
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              'Diccionario LSC',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
          ),
          backgroundColor: CupertinoColors.transparent,
          automaticBackgroundVisibility: false,
          border: null,
        ),
        child: SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(
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
              bottom: false, // prevents double-padding weirdness with tab bar
              child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
                          child: DailySignCard(
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (_) => EntryView(id: 'prueba'),
                                ),
                              );
                            },
                          ),
                        ),
                        CompositedTransformTarget(
                          link: _layerLink,
                          child: SizedBox(
                            width: 340,
                            child: CupertinoTextField(
                              placeholderStyle: TextStyle(
                                color: CupertinoColors.systemGrey,
                              ),
                              controller: searchController,
                              focusNode: _focusNode,
                              enabled: !isLoadingAliases,
                              textInputAction: TextInputAction.search,
                              onSubmitted: _searchAndOpen,
                              placeholder: isLoadingAliases
                                  ? 'Cargando...'
                                  : 'Buscar seña',
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              prefix: Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Icon(
                                  CupertinoIcons.search,
                                  size: 20,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: CupertinoColors.systemGrey4,
                                  width: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 30, 0, 10),
                            child: Text(
                              'Explorar señas',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: CupertinoColors.darkBackgroundGray,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 0,
                            crossAxisSpacing: 16,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
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
                                    CupertinoPageRoute(
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
      ),
    );
  }
}

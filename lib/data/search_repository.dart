import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:campus_wave/data/campuses.dart';

enum SearchSection { campuses, facilities, professors }

class SearchResultItem {
  final SearchSection section;
  final String title;
  final String subtitle;
  final String? slug;
  const SearchResultItem({
    required this.section,
    required this.title,
    required this.subtitle,
    this.slug,
  });
}

class SearchRepository with ChangeNotifier {
  final List<SearchResultItem> _index = [];
  Timer? _rebuildDebounce;

  List<SearchResultItem> get index => List.unmodifiable(_index);

  void rebuildIndex({Duration debounce = const Duration(milliseconds: 300)}) {
    _rebuildDebounce?.cancel();
    _rebuildDebounce = Timer(debounce, _buildIndex);
  }

  void _buildIndex() {
    _index.clear();
    for (final c in campuses) {
      final slug = _slugForCampus(c.name);
      _index.add(SearchResultItem(
        section: SearchSection.campuses,
        title: c.name,
        subtitle: c.location,
        slug: slug,
      ));
      for (final fh in c.facilityHighlights) {
        _index.add(SearchResultItem(
          section: SearchSection.facilities,
          title: fh,
          subtitle: c.name,
          slug: slug,
        ));
      }
      for (final ah in c.academicHighlights) {
        _index.add(SearchResultItem(
          section: SearchSection.professors,
          title: ah,
          subtitle: c.name,
          slug: slug,
        ));
      }
    }
    notifyListeners();
  }

  List<SearchResultItem> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    // Simple fuzzy: contains or starts-with boost
    int score(String text) {
      final t = text.toLowerCase();
      if (t.startsWith(q)) return 3;
      if (t.contains(q)) return 1;
      return 0;
    }

    final results = _index
        .map((i) => (i: i, s: score(i.title) + score(i.subtitle)))
        .where((e) => e.s > 0)
        .toList()
      ..sort((a, b) => b.s.compareTo(a.s));
    return results.map((e) => e.i).toList();
  }

  String _slugForCampus(String name) {
    var n = name.toLowerCase();
    if (n.startsWith('lgs ')) n = n.substring(4);
    n = n.replaceAll('&', 'and');
    n = n.replaceAll(RegExp(r"[^a-z0-9 ]"), '');
    n = n.trim().replaceAll(RegExp(r"\s+"), '_');
    return n;
  }
}

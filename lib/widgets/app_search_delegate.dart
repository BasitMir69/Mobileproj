import 'package:flutter/material.dart';

class AppSearchItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  AppSearchItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class AppSearchDelegate extends SearchDelegate<String> {
  AppSearchDelegate({required this.items});

  final List<AppSearchItem> items;

  List<AppSearchItem> _filter(String query) {
    if (query.isEmpty) return items;
    final q = query.toLowerCase();
    return items
        .where((i) =>
            i.title.toLowerCase().contains(q) ||
            i.subtitle.toLowerCase().contains(q))
        .toList();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _filter(query);
    return _ListView(results: results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = _filter(query);
    return _ListView(results: results);
  }
}

class _ListView extends StatelessWidget {
  const _ListView({required this.results});

  final List<AppSearchItem> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(child: Text('No matches'));
    }
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: Icon(item.icon),
          title: Text(item.title),
          subtitle: Text(item.subtitle),
          onTap: item.onTap,
        );
      },
    );
  }
}

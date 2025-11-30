import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wave/router.dart' show campusSlug;
import 'package:provider/provider.dart';
import 'package:campus_wave/data/search_repository.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  final TextEditingController _controller = TextEditingController();
  List<SearchResultItem> _results = const [];
  final List<String> _suggestedTags = const ['library', 'sports', 'Phase 5'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Build index shortly after opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = context.read<SearchRepository>();
      repo.rebuildIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Search Campus'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search input field with rounded corners
              TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() => _query = value);
                  final repo = context.read<SearchRepository>();
                  _results = repo.search(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search by name, city, facility...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: primary),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                          child: Icon(Icons.clear, color: Colors.grey[500]),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primary, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 12),
              // Tag suggestions
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestedTags
                    .map((t) => ActionChip(
                          label: Text(t),
                          onPressed: () {
                            _controller.text = t;
                            setState(() => _query = t);
                            final repo = context.read<SearchRepository>();
                            _results = repo.search(t);
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),

              // Results section
              if (_query.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        Icon(Icons.search, size: 48, color: Colors.grey[600]),
                        const SizedBox(height: 12),
                        Text(
                          'Start typing to search',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "No results yet. Try 'library' or 'Phase 5'",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Results for "$_query"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_results.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          "No matches. Try tags: 'library', 'sports', 'Phase 5'",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    _SectionHeader(label: 'Campuses'),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _results
                          .where((r) => r.section == SearchSection.campuses)
                          .length,
                      itemBuilder: (context, i) {
                        final campusesRes = _results
                            .where((r) => r.section == SearchSection.campuses)
                            .toList();
                        final r = campusesRes[i];
                        return GestureDetector(
                          onTap: () {
                            context.pushNamed('campusInfo');
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.location_city,
                                    color: primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        r.subtitle,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    size: 16, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _SectionHeader(label: 'Facilities'),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _results
                          .where((r) => r.section == SearchSection.facilities)
                          .length,
                      itemBuilder: (context, i) {
                        final facRes = _results
                            .where((r) => r.section == SearchSection.facilities)
                            .toList();
                        final r = facRes[i];
                        return ListTile(
                          leading: const Icon(Icons.home_repair_service),
                          title: Text(r.title),
                          subtitle: Text(r.subtitle),
                          onTap: () => context.go('/facilities'),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _SectionHeader(label: 'Professors'),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _results
                          .where((r) => r.section == SearchSection.professors)
                          .length,
                      itemBuilder: (context, i) {
                        final profRes = _results
                            .where((r) => r.section == SearchSection.professors)
                            .toList();
                        final r = profRes[i];
                        return ListTile(
                          leading: const Icon(Icons.person_search),
                          title: Text(r.title),
                          subtitle: Text(r.subtitle),
                          onTap: () => context.push(
                              '/campus/${campusSlug(r.subtitle)}/professors'),
                        );
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // Sleek bottom nav
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          border: const Border(top: BorderSide(color: Color(0x1AFFFFFF))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.home, color: Colors.white70),
              tooltip: 'Home',
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search, color: primary),
              tooltip: 'Search',
            ),
            IconButton(
              onPressed: () => context.pushNamed('profile'),
              icon: const Icon(Icons.person, color: Colors.white70),
              tooltip: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

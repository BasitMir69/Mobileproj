import 'package:flutter/material.dart';
import 'package:campus_wave/widgets/lgs_image.dart';
import 'package:campus_wave/data/campuses.dart';
import 'package:campus_wave/widgets/user_avatar_button.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wave/router.dart' show campusSlug;

String assetCoverForCampus(String name) {
  // New explicit mapping to PNG covers in assets/Lgs Picscampus/
  switch (name.trim()) {
    case 'LGS 1A1':
      return 'assets/Lgs Picscampus/LGS 1A1.png';
    case 'LGS 42 B-III Gulberg':
    case 'LGS 42B Gulberg III': // allow alternate naming
      return 'assets/Lgs Picscampus/LGS 42B Gulberg III.png';
    case 'LGS Gulberg Campus 2':
      return 'assets/Lgs Picscampus/LGS Gulberg Campus 2.png';
    case 'LGS IB PHASE':
    case 'LGS IB Phase':
      return 'assets/Lgs Picscampus/LGS IB Phase.png';
    case 'LGS JT':
    case 'LGS Johar Town':
      return 'assets/Lgs Picscampus/LGS Johar Town.png';
    case 'LGS PARAGON':
    case 'LGS Paragon':
      return 'assets/Lgs Picscampus/LGS Paragon.png';
    default:
      break;
  }
  // Fallback to first photo asset if available
  final match = campuses.where((c) => c.name == name).toList();
  if (match.isNotEmpty && match.first.photoCaptions.isNotEmpty) {
    return match.first.photoCaptions.keys.first;
  }
  return ''; // empty -> LgsImage will use networkUrl
}

// Gallery moved to Facilities screen; no gallery loading here.

class CampusInfoScreen extends StatelessWidget {
  const CampusInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Info'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => context.pushNamed('search'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: UserAvatarButton(
              onTap: () => context.pushNamed('userProfile'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const LgsImage(
                  networkUrl:
                      'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?q=80&w=1400&auto=format&fit=crop&ixlib=rb-4.0.3&s=4',
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.6),
                        theme.colorScheme.surface.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'LGS Campuses',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: campuses.length,
              itemBuilder: (context, index) {
                final campus = campuses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () =>
                        context.push('/campus/${campusSlug(campus.name)}'),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 100,
                          child: LgsImage(
                            assetPath: assetCoverForCampus(campus.name),
                            networkUrl: campus.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  campus.name,
                                  style: theme.textTheme.titleMedium!
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  campus.location,
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  campus.description,
                                  style: theme.textTheme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.chevron_right),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CampusDetailScreen extends StatelessWidget {
  final Campus campus;

  const CampusDetailScreen({super.key, required this.campus});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(campus.name),
          actions: [
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () => context.pushNamed('search'),
            ),
            UserAvatarButton(
              onTap: () => context.pushNamed('userProfile'),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Facilities'),
              Tab(text: 'Staff'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(campus: campus),
            _FacilitiesTab(campus: campus),
            _StaffTab(campus: campus),
            _HistoryTab(campus: campus),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer, size: 14),
          const SizedBox(width: 4),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Campus campus;
  const _OverviewTab({required this.campus});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: false,
          expandedHeight: 220,
          flexibleSpace: FlexibleSpaceBar(
            background: LgsImage(
              assetPath: assetCoverForCampus(campus.name),
              networkUrl: campus.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: const [
                    _Badge(label: 'STEM Focus'),
                    _Badge(label: 'Debate Champion'),
                    _Badge(label: 'Robotics Club'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(campus.location, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                Text(campus.description, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 12),
                // Removed quick actions: Book Appointment, View Library, Message Office
                // per request to declutter Campus Info overview.
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FacilitiesTab extends StatelessWidget {
  final Campus campus;
  const _FacilitiesTab({required this.campus});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Facility Highlights', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3.5,
            ),
            itemCount: campus.facilityHighlights.length,
            itemBuilder: (context, i) {
              final h = campus.facilityHighlights[i];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline),
                      const SizedBox(width: 8),
                      Expanded(child: Text(h)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StaffTab extends StatelessWidget {
  final Campus campus;
  const _StaffTab({required this.campus});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => context.push(
          '/campus/${campusSlug(campus.name)}/professors',
        ),
        icon: const Icon(Icons.person_search),
        label: const Text('Open Professors Directory'),
      ),
    );
  }
}

// Gallery tab removed — gallery now lives in Facilities screen only.

class _HistoryTab extends StatefulWidget {
  final Campus campus;
  const _HistoryTab({required this.campus});
  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = widget.campus.history;
    final preview = text.length > 300 ? text.substring(0, 300) + '…' : text;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('History', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(_expanded ? text : preview, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            label: Text(_expanded ? 'Show Less' : 'Show More'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wave/data/campuses.dart';
import 'package:campus_wave/widgets/lgs_image.dart';
import 'package:campus_wave/widgets/app_search_delegate.dart';
import 'package:campus_wave/widgets/breadcrumbs.dart';
import 'package:campus_wave/router.dart' show campusSlug;
import 'package:campus_wave/widgets/section_header.dart';

String assetCoverForCampus(String name) {
  switch (name.trim()) {
    case 'LGS 1A1':
      return 'assets/Lgs Picscampus/LGS 1A1.png';
    case 'LGS 42 B-III Gulberg':
    case 'LGS 42B Gulberg III':
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
  final match = campuses.where((c) => c.name == name).toList();
  if (match.isNotEmpty && match.first.photoCaptions.isNotEmpty) {
    return match.first.photoCaptions.keys.first;
  }
  return '';
}

List<String> galleryAssetsForCampus(String name) {
  switch (name.trim()) {
    case 'LGS 1A1':
      return const [
        'assets/Lgsgallerypics/1A1/1A1badminton.png',
        'assets/Lgsgallerypics/1A1/1A1cafe.png',
        'assets/Lgsgallerypics/1A1/1A1pool.png',
      ];
    case 'LGS 42 B-III Gulberg':
    case 'LGS 42B Gulberg III':
    case 'LGS 42 BIII gulberg':
      return const [
        'assets/Lgsgallerypics/42 BIII gulberg/42BIIIgulbergbadminton.png',
        'assets/Lgsgallerypics/42 BIII gulberg/42BIIIgulbergcafe.png',
        'assets/Lgsgallerypics/42 BIII gulberg/42BIIIgulbergpool.png',
      ];
    case 'LGS Gulberg Campus 2':
    case 'LGS GULBERG CAMPUS 2':
      return const [
        'assets/Lgsgallerypics/Gulberg Campus 2/GulbergCampus2badminton.png',
        'assets/Lgsgallerypics/Gulberg Campus 2/GulbergCampus2cafe.png',
        'assets/Lgsgallerypics/Gulberg Campus 2/GulbergCampus2pool.png',
      ];
    case 'LGS IB PHASE':
    case 'LGS IB Phase':
      return const [
        'assets/Lgsgallerypics/IB phase/IBcafe.png',
        'assets/Lgsgallerypics/IB phase/IBphasebadminton.png',
        'assets/Lgsgallerypics/IB phase/IBphasepool.png',
      ];
    case 'LGS JT':
    case 'LGS Johar Town':
      return const [
        'assets/Lgsgallerypics/JT/JTbadminton.png',
        'assets/Lgsgallerypics/JT/JTcafe.png',
        'assets/Lgsgallerypics/JT/JTpool.png',
      ];
    case 'LGS PARAGON':
    case 'LGS Paragon':
      return const [
        'assets/Lgsgallerypics/Paragon/Paragonbadminton.png',
        'assets/Lgsgallerypics/Paragon/Paragoncafe.png',
        'assets/Lgsgallerypics/Paragon/Paragonpool.png',
      ];
    default:
      return const [];
  }
}

class FacilitiesScreen extends StatefulWidget {
  const FacilitiesScreen({super.key});

  @override
  State<FacilitiesScreen> createState() => _FacilitiesScreenState();
}

class _FacilitiesScreenState extends State<FacilitiesScreen> {
  List<Campus> get _campuses => campuses;

  @override
  void initState() {
    super.initState();
    // Prefetch campus cover images for offline use
    for (final c in _campuses) {
      LgsImage.cacheImage(c.imageUrl);
      // Assets are bundled; no need to prefetch.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facilities'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () {
              final items = _buildSearchItems(context);
              showSearch(
                context: context,
                delegate: AppSearchDelegate(items: items),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Breadcrumbs(items: [
                BreadcrumbItem(label: 'Home', onTap: () => context.go('/home')),
                BreadcrumbItem(label: 'Facilities'),
              ]),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _campuses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final campus = _campuses[i];
                  return ListTile(
                    tileColor: const Color(0xFF1E1E1E),
                    leading: SizedBox(
                      width: 64,
                      child: LgsImage(
                        assetPath: assetCoverForCampus(campus.name),
                        networkUrl: campus.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(campus.name,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(campus.location,
                        style: TextStyle(color: Colors.grey[400])),
                    onTap: () =>
                        context.push('/facilities/${campusSlug(campus.name)}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AppSearchItem> _buildSearchItems(BuildContext context) {
    return [
      AppSearchItem(
        title: 'Facilities',
        subtitle: 'Browse campus facilities',
        icon: Icons.home_repair_service,
        onTap: () {},
      ),
      AppSearchItem(
        title: 'Campus Info',
        subtitle: 'Explore campuses and details',
        icon: Icons.location_city,
        onTap: () => context.pushNamed('campusInfo'),
      ),
      AppSearchItem(
        title: 'Professors',
        subtitle: 'View faculty directory',
        icon: Icons.person_search,
        onTap: () => context.pushNamed('professors'),
      ),
      AppSearchItem(
        title: 'Appointments',
        subtitle: 'Book and review appointments',
        icon: Icons.event_available,
        onTap: () => context.pushNamed('appointments'),
      ),
    ];
  }
}

class CampusFacilitiesDetail extends StatelessWidget {
  final Campus campus;
  const CampusFacilitiesDetail({super.key, required this.campus});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${campus.name} Facilities')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Breadcrumbs(items: [
                BreadcrumbItem(label: 'Home', onTap: () => context.go('/home')),
                BreadcrumbItem(
                    label: 'Facilities',
                    onTap: () => context.go('/facilities')),
                BreadcrumbItem(label: campus.name),
              ]),
            ),
            SizedBox(
              height: 250,
              child: LgsImage(
                assetPath: assetCoverForCampus(campus.name),
                networkUrl: campus.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(label: 'Facility Highlights'),
                  const SizedBox(height: 16),
                  ...campus.facilityHighlights.map((h) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: const Color(0xFF1E1E1E),
                        child: ListTile(
                          leading: const Icon(Icons.check_circle_outline,
                              color: Colors.blueAccent),
                          title: Text(h,
                              style: const TextStyle(color: Colors.white)),
                        ),
                      )),
                  const SizedBox(height: 24),
                  const SectionHeader(label: 'Gallery'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: PageView.builder(
                      itemCount: galleryAssetsForCampus(campus.name).isNotEmpty
                          ? galleryAssetsForCampus(campus.name).length
                          : campus.photoCaptions.length,
                      controller: PageController(viewportFraction: 0.9),
                      itemBuilder: (context, index) {
                        final hasAssets =
                            galleryAssetsForCampus(campus.name).isNotEmpty;
                        final assetPath = hasAssets
                            ? galleryAssetsForCampus(campus.name)[index]
                            : campus.photoCaptions.keys.elementAt(index);
                        final caption = hasAssets
                            ? campus.name
                            : campus.photoCaptions.values.elementAt(index);
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                LgsImage(
                                  assetPath: assetPath,
                                  networkUrl: campus.imageUrl,
                                  fit: BoxFit.cover,
                                  debugLabel: assetPath,
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    color: Colors.black54,
                                    child: Text(
                                      caption,
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const SectionHeader(label: 'Related'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                          label: const Text('Cafeteria'),
                          onPressed: () => context.go('/cafeteria')),
                      ActionChip(
                          label: const Text('Events'),
                          onPressed: () => context.go('/home')),
                      ActionChip(
                        label: const Text('Campus Info'),
                        onPressed: () =>
                            context.go('/campus/${campusSlug(campus.name)}'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

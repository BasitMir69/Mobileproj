import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wave/data/appointments.dart';
import 'package:campus_wave/data/current_user.dart';
import 'package:campus_wave/l10n/app_localizations.dart';
import 'package:campus_wave/widgets/lgs_image.dart';
import 'package:campus_wave/data/campuses.dart';
// import 'package:campus_wave/screens/campus_info_screen.dart';
import 'package:campus_wave/widgets/app_search_delegate.dart';
import 'package:campus_wave/router.dart' show campusSlug;
import 'package:campus_wave/widgets/spacing.dart';
import 'package:campus_wave/widgets/elevated_action_card.dart';
import 'package:campus_wave/data/admission_form_db.dart';
import 'package:campus_wave/data/admission_form.dart';
import 'package:campus_wave/widgets/hero_header.dart';
import 'package:campus_wave/widgets/section_header.dart';
import 'package:campus_wave/widgets/app_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_wave/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _role = 'student';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final snap =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = snap.data() ?? {};
      final r = (data['role'] as String?) ?? 'student';
      if (mounted) setState(() => _role = r);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.title),
        elevation: 0,
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
      body: SingleChildScrollView(
        child: ReadableWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HeroHeader(
                title: 'Find the right school',
                subtitle: 'Browse campuses, compare, and apply from anywhere',
                assetPath: 'assets/Lgs Picscampus/LGS Johar Town.png',
                networkUrl:
                    'https://images.unsplash.com/photo-1596495578065-8c3d83df9de1?w=1200',
                ctaLabel: 'Start Admission',
                onCta: () => context.push('/admissions/new'),
              ),

              const SizedBox(height: AppSpacing.v12),
              // Section: Campus News (published)
              const SectionHeader(label: 'Campus News'),
              const SizedBox(height: AppSpacing.v8),
              StreamBuilder<QuerySnapshot>(
                stream: FirestoreService.streamPublishedCampusNews(limit: 5),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.campaign_outlined),
                        title: const Text('No published news yet'),
                        subtitle: const Text('Check back soon'),
                      ),
                    );
                  }
                  return Card(
                    child: Column(
                      children: [
                        ...docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          final title = data['title'] ?? 'News';
                          final content = data['content'] ?? '';
                          final campus = data['campus'] ?? 'All Campuses';
                          return ListTile(
                            leading: const Icon(Icons.article_outlined),
                            title: Text(title),
                            subtitle: Text(
                                '$campus • ${content.toString().length > 80 ? content.toString().substring(0, 80) + '…' : content}'),
                            onTap: () => context.pushNamed(
                              'newsDetail',
                              extra: {'title': title, 'body': content},
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.v12),

              // Quick actions grid
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.8,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  if (_role != 'professor')
                    if (_role != 'professor')
                      ElevatedActionCard(
                        icon: Icons.edit,
                        title: 'New Admission',
                        subtitle: 'Start a new application',
                        onTap: () => context.push('/admissions/new'),
                      ),
                  if (_role != 'professor')
                    ElevatedActionCard(
                      icon: Icons.folder,
                      title: 'Saved Forms',
                      subtitle: 'Offline admission drafts',
                      onTap: () => context.push('/admissions/saved'),
                    ),
                  ElevatedActionCard(
                    icon: Icons.map,
                    title: l10n.campusInfo,
                    subtitle: 'Campuses & facilities',
                    onTap: () => context.pushNamed('campusInfo'),
                  ),
                  if (_role != 'professor')
                    ElevatedActionCard(
                      icon: Icons.calendar_today,
                      title: l10n.appointments,
                      subtitle: 'Book & manage meetings',
                      onTap: () => context.pushNamed('appointments'),
                    ),
                  if (_role != 'professor')
                    ElevatedActionCard(
                      icon: Icons.person_search,
                      title: 'Professors',
                      subtitle: 'Browse faculty directory',
                      onTap: () => context.pushNamed('professors'),
                    ),
                  ElevatedActionCard(
                    icon: Icons.smart_toy_outlined,
                    title: l10n.aiChatbot,
                    subtitle: 'Ask campus questions',
                    onTap: () => context.pushNamed('chatbot'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.v12),

              // Section: Your Admissions (preview) — hidden for professors
              if (_role != 'professor') ...[
                const SectionHeader(label: 'Your Admissions'),
                const SizedBox(height: AppSpacing.v8),
                FutureBuilder<List<AdmissionForm>>(
                  future: AdmissionFormDb.instance.all(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final items = snap.data ?? const [];
                    if (items.isEmpty) {
                      return Card(
                        child: ListTile(
                          title: const Text('No saved forms yet'),
                          subtitle: const Text('Start a new admission form'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => context.push('/admissions/new'),
                        ),
                      );
                    }
                    final preview = items.take(2).toList();
                    return Card(
                      child: Column(
                        children: [
                          ...preview.map((f) => ListTile(
                                leading: const Icon(Icons.description_outlined),
                                title:
                                    Text('${f.childName} • ${f.gradeApplying}'),
                                subtitle: Text(
                                    'Campus: ${f.campus}  •  Parent: ${f.parentName}'),
                              )),
                          const Divider(height: 1),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () =>
                                  context.push('/admissions/saved'),
                              icon: const Icon(Icons.folder_open),
                              label: const Text('View all saved forms'),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
              // Section: Explore Campuses
              const SizedBox(height: AppSpacing.v12),
              Container(
                height: 1,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.06),
              ),
              const SectionHeader(label: 'Explore Campuses'),
              const SizedBox(height: AppSpacing.v8),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: campuses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final c = campuses[i];
                    String? asset;
                    switch (c.name.trim()) {
                      case 'LGS 1A1':
                        asset = 'assets/Lgs Picscampus/LGS 1A1.png';
                        break;
                      case 'LGS 42 B-III Gulberg':
                      case 'LGS 42B Gulberg III':
                        asset = 'assets/Lgs Picscampus/LGS 42B Gulberg III.png';
                        break;
                      case 'LGS Gulberg Campus 2':
                        asset =
                            'assets/Lgs Picscampus/LGS Gulberg Campus 2.png';
                        break;
                      case 'LGS IB PHASE':
                      case 'LGS IB Phase':
                        asset = 'assets/Lgs Picscampus/LGS IB Phase.png';
                        break;
                      case 'LGS JT':
                      case 'LGS Johar Town':
                        asset = 'assets/Lgs Picscampus/LGS Johar Town.png';
                        break;
                      case 'LGS PARAGON':
                      case 'LGS Paragon':
                        asset = 'assets/Lgs Picscampus/LGS Paragon.png';
                        break;
                      default:
                        if (c.photoCaptions.isNotEmpty) {
                          asset = c.photoCaptions.keys.first;
                        }
                    }
                    final slug = campusSlug(c.name);
                    return _CampusShortcutCard(
                      title: c.name,
                      imageUrl: c.imageUrl,
                      assetPath: asset,
                      onTap: () => context.push('/campus/$slug'),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.v12),
              _InfoCard(
                imageUrl:
                    'https://images.unsplash.com/photo-1519452575417-564c1401ecc0?w=1200',
                title: l10n.campusNews,
                body: 'Ranked #1 nationally for innovation in latest survey.',
                buttonLabel: l10n.readMore,
                primary: primary,
                onPressed: () {
                  context.pushNamed(
                    'newsDetail',
                    extra: {
                      'title': 'Campus News',
                      'body':
                          'Ranked #1 nationally for innovation in latest survey.',
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.v12),
              // Integrated next appointment into button label
              FutureBuilder<String?>(
                future: _loadNextAppointment(),
                builder: (context, snap) {
                  final nextLabel = snap.data;
                  final base = l10n.myAppointments;
                  final label = nextLabel != null
                      ? '$base • $nextLabel'
                      : '$base • Manage';
                  return Semantics(
                    button: true,
                    label: 'Open your booked appointments list',
                    hint: 'View, manage or cancel professor bookings',
                    child: Tooltip(
                      message: 'Manage your scheduled bookings',
                      child: ElevatedButton.icon(
                        onPressed: () => context.pushNamed('appointments'),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(label),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      // Removed chatbot FAB for a cleaner home screen.
      // If needed later, reintroduce with context.pushNamed('chatbot').
    );
  }

  // Placeholder data loaders; replace with Firestore or local bookings
  Future<String?> _loadNextAppointment() async {
    // Demo: next appointment for current user from sampleAppointments
    final next = sampleAppointments
        .where((a) => a.userId == currentUser.id)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    if (next.isEmpty) return null;
    final a = next.first;
    final when =
        '${a.start.month}/${a.start.day} ${a.start.hour.toString().padLeft(2, '0')}:${a.start.minute.toString().padLeft(2, '0')}';
    return 'With ${a.professorId.toUpperCase()} • $when';
  }

  // _loadUpcomingEvent removed (unused after UI simplification)

  List<AppSearchItem> _buildSearchItems(BuildContext context) {
    return [
      AppSearchItem(
        title: 'Facilities',
        subtitle: 'Browse campus facilities',
        icon: Icons.home_repair_service,
        onTap: () => context.go('/facilities'),
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
      AppSearchItem(
        title: 'AI Chatbot',
        subtitle: 'Ask questions about campuses and facilities',
        icon: Icons.smart_toy_outlined,
        onTap: () => context.pushNamed('chatbot'),
      ),
    ];
  }
}

// Removed unused _NavCard + _QuickActionChip widgets (merged into ElevatedActionCard grid)

class _InfoCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String body;
  final String buttonLabel;
  final Color primary;
  final VoidCallback? onPressed;

  const _InfoCard({
    required this.imageUrl,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.primary,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final bodyColor = theme.colorScheme.onSurface.withValues(alpha: 0.75);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(color: bodyColor),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Semantics(
                    button: true,
                    label: '$buttonLabel for $title section',
                    hint: 'Opens detailed page: $title',
                    child: Tooltip(
                      message: buttonLabel,
                      child: ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text('$buttonLabel • Details'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable section header for consistent style
// _SectionHeader removed; using shared SectionHeader widget

class _CampusShortcutCard extends StatelessWidget {
  final String title;
  final String imageUrl; // remote fallback
  final String? assetPath; // local asset from LGS PICS
  final VoidCallback onTap;

  const _CampusShortcutCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = theme.colorScheme.surface;
    final border = theme.colorScheme.primary.withValues(alpha: 0.12);

    return Semantics(
      button: true,
      label: 'Open campus: $title',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 140,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: LgsImage(
                  assetPath: assetPath,
                  networkUrl: imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

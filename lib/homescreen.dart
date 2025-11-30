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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
              SizedBox(
                height: 220,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    LgsImage(
                      assetPath: 'assets/lgs/campuses/johar_town/cover.jpg',
                      networkUrl:
                          'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=1200',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(170, 0, 0, 0),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Innovate. Learn. Lead.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Your guide to campuses, facilities, and events.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.v12),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.v12),
              // Section: Quick Access
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionHeader(label: 'Quick Access'),
                  const SizedBox(height: AppSpacing.v8),
                  // Streamlined quick access: Campus Info now implicitly includes facilities.
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        SizedBox(
                          width: 180,
                          child: _NavCard(
                            icon: Icons.map,
                            title: l10n.campusInfo,
                            subtitle: 'Campuses & their facilities',
                            color: primary,
                            onTap: () => context.pushNamed('campusInfo'),
                          ),
                        ),
                        // Removed duplicate Professors and Appointments from Discover
                        SizedBox(
                          width: 180,
                          child: _NavCard(
                            icon: Icons.smart_toy_outlined,
                            title: l10n.aiChatbot,
                            subtitle: 'Ask campus questions',
                            color: primary,
                            onTap: () => context.pushNamed('chatbot'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Section: Explore Campuses
              const SizedBox(height: AppSpacing.v12),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.v12),
              const _SectionHeader(label: 'Explore Campuses'),
              const SizedBox(height: AppSpacing.v8),
              SizedBox(
                height: 140,
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
                    return _CampusShortcutCard(
                      title: c.name,
                      imageUrl: c.imageUrl,
                      assetPath: asset,
                      onTap: () =>
                          context.push('/campus/${campusSlug(c.name)}'),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.v24),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.v12),
              const _SectionHeader(label: 'Student Services'),
              const SizedBox(height: AppSpacing.v8),
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    SizedBox(
                      width: 180,
                      child: _NavCard(
                        icon: Icons.person_search,
                        title: 'Professors',
                        subtitle: 'Browse faculty directory',
                        color: primary,
                        onTap: () => context.pushNamed('professors'),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: _NavCard(
                        icon: Icons.calendar_today,
                        title: l10n.appointments,
                        subtitle: 'Book and review appointments',
                        color: primary,
                        onTap: () => context.pushNamed('appointments'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.v24),
              _InfoCard(
                imageUrl:
                    'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?w=1200',
                title: l10n.upcomingEvents,
                body:
                    'Guest lecture by Dr. Riffat – Auditorium A, Oct 28, 2:00 PM',
                buttonLabel: l10n.viewAll,
                primary: primary,
                onPressed: () {
                  context.pushNamed(
                    'eventDetail',
                    extra: {
                      'title': 'Upcoming Events',
                      'body':
                          'Guest lecture by Dr. Riffat – Auditorium A, Oct 28, 2:00 PM',
                    },
                  );
                },
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

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Emerald-tinted cards: dark uses deep emerald, light uses light emerald tint
    final cardColor = isDark
        ? const Color(0xFF0B3B2C) // darkish emerald inside the box
        : const Color(0xFFE6F5F2); // lightish emerald inside the box
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor =
        isDark ? Colors.white70 : Colors.black87.withValues(alpha: 0.7);
    final borderColor = isDark
        ? const Color(0xFF10B981).withValues(alpha: 0.18)
        : const Color(0xFF0F766E).withValues(alpha: 0.20);

    return Semantics(
      button: true,
      label: '$title navigation card',
      hint: 'Opens $title section: $subtitle',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Removed unused _QuickActionChip widget (dead code lint)

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
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark
        ? const Color(0xFF0B3B2C) // dark emerald for card
        : const Color(0xFFE6F5F2); // light emerald for card
    final textColor = isDark ? Colors.white : Colors.black87;
    final bodyColor =
        isDark ? Colors.white70 : Colors.black87.withValues(alpha: 0.75);

    return Card(
      color: cardColor,
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

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
    final bg = isDark ? const Color(0xFF0B3B2C) : const Color(0xFFE6F5F2);
    final border = isDark
        ? const Color(0xFF10B981).withValues(alpha: 0.18)
        : const Color(0xFF0F766E).withValues(alpha: 0.2);

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

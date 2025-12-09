import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
                title: l10n.findRightSchool,
                subtitle: l10n.browseCompareApply,
                assetPath: 'assets/Lgs Picscampus/LGS Johar Town.png',
                networkUrl:
                    'https://images.unsplash.com/photo-1596495578065-8c3d83df9de1?w=1200',
                ctaLabel: l10n.startAdmission,
                onCta: () => context.push('/admissions/new'),
              ),

              // Admin overview: quick stats and shortcuts
              if (_role == 'admin') ...[
                const SizedBox(height: AppSpacing.v12),
                const SectionHeader(label: 'Admin Overview'),
                const SizedBox(height: AppSpacing.v8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: LayoutBuilder(builder: (ctx, cons) {
                      final narrow = cons.maxWidth < 380;
                      if (narrow) {
                        // Use a compact grid on narrow phones (e.g., Galaxy S9)
                        return GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 2.8,
                          ),
                          children: [
                            _AdminStatBox(
                              label: 'Admissions',
                              tooltip: 'Pending admissions to review',
                              stream: FirebaseFirestore.instance
                                  .collection('admission_submissions')
                                  .where('status', isEqualTo: 'pending')
                                  .snapshots()
                                  .map((s) => s.size),
                              onTap: () => context.pushNamed('adminAdmissions'),
                            ),
                            _AdminStatBox(
                              label: 'Draft News',
                              tooltip: 'Unpublished campus news',
                              stream: FirebaseFirestore.instance
                                  .collection('campus_news')
                                  .where('published', isEqualTo: false)
                                  .snapshots()
                                  .map((s) => s.size),
                              onTap: () => context.pushNamed('adminNews'),
                            ),
                            _AdminStatBox(
                              label: 'Pending Appts',
                              tooltip: 'Pending student appointments',
                              stream: FirebaseFirestore.instance
                                  .collection('appointmentID')
                                  .where('status', isEqualTo: 'pending')
                                  .snapshots()
                                  .map((s) => s.size),
                              onTap: () => context.pushNamed('appointments'),
                            ),
                          ],
                        );
                      }
                      // Wide enough: keep the single row with equal spacing
                      return Row(
                        children: [
                          _AdminStat(
                            label: 'Admissions',
                            tooltip: 'Pending admissions to review',
                            stream: FirebaseFirestore.instance
                                .collection('admission_submissions')
                                .where('status', isEqualTo: 'pending')
                                .snapshots()
                                .map((s) => s.size),
                            onTap: () => context.pushNamed('adminAdmissions'),
                          ),
                          const SizedBox(width: 12),
                          _AdminStat(
                            label: 'Draft News',
                            tooltip: 'Unpublished campus news',
                            stream: FirebaseFirestore.instance
                                .collection('campus_news')
                                .where('published', isEqualTo: false)
                                .snapshots()
                                .map((s) => s.size),
                            onTap: () => context.pushNamed('adminNews'),
                          ),
                          const SizedBox(width: 12),
                          _AdminStat(
                            label: 'Pending Appts',
                            tooltip: 'Pending student appointments',
                            stream: FirebaseFirestore.instance
                                .collection('appointmentID')
                                .where('status', isEqualTo: 'pending')
                                .snapshots()
                                .map((s) => s.size),
                            onTap: () => context.pushNamed('appointments'),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: AppSpacing.v8),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ElevatedActionCard(
                      icon: Icons.dashboard_customize,
                      title: 'Admin Dashboard',
                      subtitle: 'Manage all admin tools',
                      onTap: () => context.pushNamed('adminDashboard'),
                    ),
                    ElevatedActionCard(
                      icon: Icons.article_outlined,
                      title: 'Campus News',
                      subtitle: 'Create and publish updates',
                      onTap: () => context.pushNamed('adminNews'),
                    ),
                    ElevatedActionCard(
                      icon: Icons.school_outlined,
                      title: 'Admissions',
                      subtitle: 'Review and update status',
                      onTap: () => context.pushNamed('adminAdmissions'),
                    ),
                    ElevatedActionCard(
                      icon: Icons.info_outline,
                      title: 'Campus Info',
                      subtitle: 'Edit campus pages',
                      onTap: () => context.pushNamed('adminCampusInfo'),
                    ),
                  ],
                ),
              ],

              // Professor overview: today + pending approvals
              if (_role == 'professor') ...[
                const SizedBox(height: AppSpacing.v12),
                SectionHeader(label: l10n.professorOverview),
                const SizedBox(height: AppSpacing.v8),
                FutureBuilder<Map<String, dynamic>?>(
                  future: () async {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid == null) return null;
                    return await FirestoreService.getProfessorByUserId(uid);
                  }(),
                  builder: (context, profSnap) {
                    if (profSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final prof = profSnap.data;
                    if (prof == null) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(l10n.manageAppointments),
                          subtitle: const Text(
                              'Link your profile to manage requests'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () =>
                              context.pushNamed('professorAppointments'),
                        ),
                      );
                    }
                    final profId = prof['id'] as String;
                    return Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.inbox_outlined),
                            title: Text(l10n.pendingApprovals),
                            subtitle: const Text(
                                'Approve or reject student requests'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () =>
                                context.pushNamed('professorAppointments'),
                          ),
                          const Divider(height: 1),
                          StreamBuilder<List<Map<String, dynamic>>>(
                            stream:
                                FirestoreService.streamProfessorAppointments(
                                    profId),
                            builder: (context, apptSnap) {
                              if (!apptSnap.hasData) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final items = apptSnap.data!
                                  .where((a) =>
                                      (a['status'] ?? 'pending') == 'pending')
                                  .take(3)
                                  .toList();
                              if (items.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(l10n.noAppointments),
                                  ),
                                );
                              }
                              return Column(
                                children: [
                                  ...items.map((a) => ListTile(
                                        leading:
                                            const Icon(Icons.schedule_outlined),
                                        title:
                                            Text(a['studentID'] ?? 'Student'),
                                        subtitle: Text(
                                            'Slot: ${a['requestedSlot'] ?? '-'}'),
                                        trailing:
                                            const Icon(Icons.chevron_right),
                                        onTap: () => context
                                            .pushNamed('professorAppointments'),
                                      )),
                                  const Divider(height: 1),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () => context
                                          .pushNamed('professorAppointments'),
                                      icon: const Icon(Icons.inbox),
                                      label: Text(l10n.reviewNow),
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],

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
                        title: Text(l10n.noPublishedNews),
                        subtitle: Text(l10n.checkBackSoon),
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
              LayoutBuilder(builder: (ctx, cons) {
                final w = cons.maxWidth;
                final count = w >= 720
                    ? 4
                    : w >= 520
                        ? 3
                        : 2;
                // Tighter aspect ratio to avoid text clipping on compact phones
                final ratio = w < 360 ? 1.35 : 1.5;
                return GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count,
                    childAspectRatio: ratio,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  children: [
                    if (_role == 'professor')
                      ElevatedActionCard(
                        icon: Icons.assignment_outlined,
                        title: l10n.manageAppointments,
                        subtitle: l10n.reviewNow,
                        onTap: () => context.pushNamed('professorAppointments'),
                      ),
                    if (_role == 'student')
                      ElevatedActionCard(
                        icon: Icons.edit,
                        title: l10n.newAdmission,
                        subtitle: l10n.startAdmission,
                        onTap: () => context.push('/admissions/new'),
                      ),
                    if (_role == 'student')
                      ElevatedActionCard(
                        icon: Icons.folder,
                        title: l10n.savedForms,
                        subtitle: l10n.offlineDrafts,
                        onTap: () => context.push('/admissions/saved'),
                      ),
                    ElevatedActionCard(
                      icon: Icons.map,
                      title: l10n.campusInfo,
                      subtitle: 'Campuses & facilities',
                      onTap: () => context.pushNamed('campusInfo'),
                    ),
                    if (_role == 'student')
                      ElevatedActionCard(
                        icon: Icons.calendar_today,
                        title: l10n.appointments,
                        subtitle: 'Book & manage meetings',
                        onTap: () => context.pushNamed('appointments'),
                      ),
                    if (_role == 'student')
                      ElevatedActionCard(
                        icon: Icons.person_search,
                        title: l10n.professors,
                        subtitle: l10n.browseFaculty,
                        onTap: () => context.pushNamed('professors'),
                      ),
                    ElevatedActionCard(
                      icon: Icons.smart_toy_outlined,
                      title: l10n.aiChatbot,
                      subtitle: 'Ask campus questions',
                      onTap: () => context.pushNamed('chatbot'),
                    ),
                  ],
                );
              }),

              const SizedBox(height: AppSpacing.v12),

              // Student: Upcoming Appointments preview
              if (_role == 'student') ...[
                SectionHeader(label: l10n.upcomingAppointments),
                const SizedBox(height: AppSpacing.v8),
                Card(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: () {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) {
                        return const Stream<List<Map<String, dynamic>>>.empty();
                      }
                      return FirestoreService.streamUserAppointments(uid);
                    }(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final list = snap.data!;
                      if (list.isEmpty) {
                        return ListTile(
                          leading: const Icon(Icons.event_busy),
                          title: Text(l10n.noAppointments),
                          subtitle: Text(l10n.startAdmission),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => context.pushNamed('appointments'),
                        );
                      }
                      final preview = list.take(2).toList();
                      return Column(
                        children: [
                          ...preview.map((a) => ListTile(
                                leading: const Icon(Icons.event_available),
                                title: _ProfessorNameInline(
                                  professorId: a['ProffessorID'] ?? 'Professor',
                                ),
                                subtitle: Text(
                                    'Slot: ${a['requestedSlot'] ?? '-'} • ${a['status'] ?? 'pending'}'),
                              )),
                          const Divider(height: 1),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () =>
                                  context.pushNamed('appointments'),
                              icon: const Icon(Icons.open_in_new),
                              label: Text(l10n.viewAllAppointments),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.v12),

              // Student: Admission Status (latest)
              if (_role == 'student') ...[
                SectionHeader(label: l10n.admissionStatus),
                const SizedBox(height: AppSpacing.v8),
                Card(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: () {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) {
                        return const Stream<QuerySnapshot>.empty();
                      }
                      return FirebaseFirestore.instance
                          .collection('admission_submissions')
                          .where('studentID', isEqualTo: uid)
                          .orderBy('createdAt', descending: true)
                          .limit(1)
                          .snapshots();
                    }(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final docs = snap.data!.docs;
                      if (docs.isEmpty) {
                        return ListTile(
                          leading: const Icon(Icons.pending_actions_outlined),
                          title: Text(l10n.noAdmissionsYet),
                          subtitle: Text(l10n.startNewAdmission),
                          onTap: () => context.push('/admissions/new'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                        );
                      }
                      final data = docs.first.data() as Map<String, dynamic>;
                      final status = data['status'] ?? 'submitted';
                      final campus = data['campus'] ?? '—';
                      return ListTile(
                        leading: const Icon(Icons.fact_check_outlined),
                        title: Text('Status: $status'),
                        subtitle: Text('Campus: $campus'),
                        // For student role, avoid navigating to admin screens.
                        // Show status only.
                      );
                    },
                  ),
                ),
              ],

              // Section: Your Admissions (preview) — hidden for professors
              if (_role == 'student') ...[
                SectionHeader(label: l10n.yourAdmissions),
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
                          title: Text(l10n.noSavedForms),
                          subtitle: Text(l10n.startNewAdmission),
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
                              label: Text(l10n.viewAllSavedForms),
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
              SectionHeader(label: l10n.exploreCampuses),
              const SizedBox(height: AppSpacing.v8),
              SizedBox(
                height: 150,
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
              // Removed standalone My Appointments button per request
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
  // _loadNextAppointment removed with the My Appointments button

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

class _ProfessorNameInline extends StatelessWidget {
  final String professorId;
  const _ProfessorNameInline({required this.professorId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: FirestoreService.getProfessorById(professorId),
      builder: (context, snap) {
        final name = snap.data?['name'] as String?;
        final displayName = name ??
            (professorId == 'demo_professor' ? 'Dr Ayesha Khan' : professorId);
        return Text(displayName);
      },
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

class _AdminStat extends StatelessWidget {
  final String label;
  final String tooltip;
  final Stream<int> stream;
  final VoidCallback onTap;
  const _AdminStat({
    required this.label,
    required this.tooltip,
    required this.stream,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border =
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
    return Expanded(
      child: Semantics(
        button: true,
        label: '$label count',
        child: Tooltip(
          message: tooltip,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  StreamBuilder<int>(
                    stream: stream,
                    builder: (context, snap) {
                      final v = snap.data;
                      return Text(
                        v == null ? '—' : v.toString(),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      );
                    },
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

class _AdminStatBox extends StatelessWidget {
  final String label;
  final String tooltip;
  final Stream<int> stream;
  final VoidCallback onTap;
  const _AdminStatBox({
    required this.label,
    required this.tooltip,
    required this.stream,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border =
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
    return Semantics(
      button: true,
      label: '$label count',
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                StreamBuilder<int>(
                  stream: stream,
                  builder: (context, snap) {
                    final v = snap.data;
                    return Text(
                      v == null ? '—' : v.toString(),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

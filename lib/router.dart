import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wave/loginscreen_new.dart';
import 'package:campus_wave/signup.dart';
import 'package:campus_wave/homescreen.dart';
import 'package:campus_wave/data/campuses.dart';
import 'package:campus_wave/screens/campus_info_screen.dart';
import 'package:campus_wave/screens/campus_professors_screen.dart';
import 'package:campus_wave/screens/facilities_screen.dart';
import 'package:campus_wave/screens/profile_screen.dart';
import 'package:campus_wave/screens/user_profile_screen.dart';
import 'package:campus_wave/screens/professor_detail_screen.dart';
import 'package:campus_wave/models/professor.dart';
import 'package:campus_wave/data/campus_professors.dart';
// import 'package:campus_wave/screens/my_appointments_screen.dart';
import 'package:campus_wave/screens/settings_screen.dart';
import 'package:campus_wave/screens/professors_screen.dart';
import 'package:campus_wave/screens/appointments_screen.dart';
import 'package:campus_wave/screens/search_screen.dart';
import 'package:campus_wave/screens/cafeteria_screen.dart';
import 'package:campus_wave/screens/library_screen.dart';
import 'package:campus_wave/screens/chatbot_screen.dart';
import 'package:campus_wave/screens/event_detail_screen.dart';
import 'package:campus_wave/screens/news_detail_screen.dart';

// Helper to slugify campus names (duplicate of private logic used elsewhere).
String campusSlug(String name) {
  var n = name.toLowerCase();
  if (n.startsWith('lgs ')) n = n.substring(4);
  n = n.replaceAll('&', 'and');
  n = n.replaceAll(RegExp(r"[^a-z0-9 ]"), '');
  n = n.trim().replaceAll(RegExp(r"\s+"), '_');
  return n;
}

Campus? campusBySlug(String slug) {
  for (final c in campuses) {
    if (campusSlug(c.name) == slug) return c;
  }
  return null;
}

Professor? professorById(String id) {
  for (final list in campusProfessors.values) {
    for (final p in list) {
      if (p.id == id) return p;
    }
  }
  return null;
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  final auth = FirebaseAuth.instance;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(auth.authStateChanges()),
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => const LoginScreenNew(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => const SignupScreen(),
      ),
      // Alias route for create account
      GoRoute(
        path: '/createAccount',
        name: 'createAccount',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => const SignupScreen(),
      ),
      // Shell with persistent navigation (BottomNavigationBar / NavigationRail)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return _NavigationScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/campusInfo',
            name: 'campusInfo',
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CampusInfoScreen(),
            ),
          ),
          GoRoute(
            path: '/facilities',
            name: 'facilities',
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const FacilitiesScreen(),
            ),
          ),
          GoRoute(
            path: '/appointments',
            name: 'appointments',
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AppointmentsScreen(),
            ),
          ),
          GoRoute(
            path: '/professors',
            name: 'professors',
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfessorsScreen(),
            ),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/cafeteria',
            name: 'cafeteria',
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CafeteriaScreen(),
            ),
          ),
          GoRoute(
            path: '/library',
            name: 'library',
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const LibraryScreen(),
            ),
          ),
          GoRoute(
            path: '/chatbot',
            name: 'chatbot',
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ChatbotScreen(),
            ),
          ),
          GoRoute(
            path: '/eventDetail',
            name: 'eventDetail',
            pageBuilder: (ctx, state) {
              final extra = state.extra as Map<String, String>?;
              final title = extra?['title'] ?? 'Event';
              final body = extra?['body'] ?? '';
              return NoTransitionPage(
                key: state.pageKey,
                child: EventDetailScreen(title: title, body: body),
              );
            },
          ),
          GoRoute(
            path: '/newsDetail',
            name: 'newsDetail',
            pageBuilder: (ctx, state) {
              final extra = state.extra as Map<String, String>?;
              final title = extra?['title'] ?? 'News';
              final body = extra?['body'] ?? '';
              return NoTransitionPage(
                key: state.pageKey,
                child: NewsDetailScreen(title: title, body: body),
              );
            },
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/userProfile',
            name: 'userProfile',
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const UserProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/facilities/:slug',
            name: 'facilities-detail',
            pageBuilder: (ctx, state) {
              final slug = state.pathParameters['slug']!;
              final c = campusBySlug(slug);
              if (c == null) {
                return NoTransitionPage(
                  key: state.pageKey,
                  child: Scaffold(
                    appBar: AppBar(title: const Text('Campus Not Found')),
                    body: Center(child: Text('No campus for slug: $slug')),
                  ),
                );
              }
              return NoTransitionPage(
                key: state.pageKey,
                child: CampusFacilitiesDetail(campus: c),
              );
            },
          ),
          GoRoute(
            path: '/professor/:id',
            name: 'professorDetail',
            pageBuilder: (ctx, state) {
              final id = state.pathParameters['id']!;
              final p = professorById(id);
              if (p == null) {
                return NoTransitionPage(
                  key: state.pageKey,
                  child: Scaffold(
                    appBar: AppBar(title: const Text('Professor Not Found')),
                    body: Center(child: Text('No professor for id: $id')),
                  ),
                );
              }
              return NoTransitionPage(
                key: state.pageKey,
                child: ProfessorDetailScreen(professor: p),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/campus/:slug',
        name: 'campus-detail',
        builder: (ctx, state) {
          final slug = state.pathParameters['slug']!;
          final c = campusBySlug(slug);
          if (c == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Campus Not Found')),
              body: Center(child: Text('No campus for slug: $slug')),
            );
          }
          return CampusDetailScreen(campus: c);
        },
        routes: [
          GoRoute(
            path: 'professors',
            name: 'campus-professors',
            builder: (ctx, state) {
              final slug = state.pathParameters['slug']!;
              final c = campusBySlug(slug);
              if (c == null) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Campus Not Found')),
                  body: Center(child: Text('No campus for slug: $slug')),
                );
              }
              return CampusProfessorsScreen(campusName: c.name);
            },
          ),
        ],
      ),
    ],
    redirect: (ctx, state) {
      final loggedIn = auth.currentUser != null;
      final loggingIn = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/signup') ||
          state.matchedLocation.startsWith('/createAccount');

      if (!loggedIn && !loggingIn) {
        return '/login';
      }
      if (loggedIn && loggingIn) {
        return '/home';
      }
      return null;
    },
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((event) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Navigation scaffold that shows persistent bottom navigation or rail on wide screens
class _NavigationScaffold extends StatelessWidget {
  final Widget child;
  const _NavigationScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final useRail = width >= 900; // simple heuristic for large screens
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _indexForLocation(location);

    if (useRail) {
      return Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (i) => _goToIndex(context, i),
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.domain),
                selectedIcon: Icon(Icons.domain),
                label: Text('Facilities'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today),
                label: Text('Appointments'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          Expanded(child: child),
        ],
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => _goToIndex(context, i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.domain), label: 'Facilities'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Appointments'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  int _indexForLocation(String loc) {
    if (loc.startsWith('/facilities')) return 1;
    if (loc.startsWith('/appointments')) return 2;
    if (loc.startsWith('/settings')) return 3;
    return 0;
  }

  void _goToIndex(BuildContext context, int i) {
    switch (i) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/facilities');
        break;
      case 2:
        context.go('/appointments');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}

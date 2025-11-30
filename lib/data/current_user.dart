class CurrentUser {
  final String id;
  final String? email;
  const CurrentUser({required this.id, this.email});
}

// Demo fallback user used when FirebaseAuth.currentUser is null
const currentUser = CurrentUser(id: 'demo-user', email: 'user@example.com');

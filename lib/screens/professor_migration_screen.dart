import 'package:flutter/material.dart';
import 'package:campus_wave/data/campus_professors.dart';
import 'package:campus_wave/services/firestore_service.dart';

/// Admin utility screen to migrate static professor data to Firestore.
/// This should only be used once or by administrators.
class ProfessorMigrationScreen extends StatefulWidget {
  const ProfessorMigrationScreen({super.key});

  @override
  State<ProfessorMigrationScreen> createState() =>
      _ProfessorMigrationScreenState();
}

class _ProfessorMigrationScreenState extends State<ProfessorMigrationScreen> {
  bool _isLoading = false;
  String _statusMessage = '';
  int _totalProfessors = 0;
  int _migratedCount = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  void _calculateTotal() {
    int total = 0;
    for (final list in campusProfessors.values) {
      total += list.length;
    }
    setState(() {
      _totalProfessors = total;
    });
  }

  Future<void> _migrateProfessors() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Starting migration...';
      _migratedCount = 0;
    });

    try {
      // Flatten all professors from all campuses
      final List<Map<String, dynamic>> professorsList = [];

      for (final entry in campusProfessors.entries) {
        final campusName = entry.key;
        final professors = entry.value;

        for (final prof in professors) {
          professorsList.add({
            'id': prof.id,
            'name': prof.name,
            'title': prof.title,
            'campus': campusName,
            'department': prof.department,
            'bio': prof.bio,
            'office': prof.office,
            'photoUrl': prof.photoUrl,
            'availableSlots': prof.availableSlots,
          });
        }
      }

      setState(() {
        _statusMessage = 'Uploading ${professorsList.length} professors...';
      });

      // Use the bulk import method
      await FirestoreService.importProfessorsFromStatic(professorsList);

      setState(() {
        _migratedCount = professorsList.length;
        _statusMessage = 'Migration completed successfully!';
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully migrated $_migratedCount professors'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Migration failed: $e';
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Migration failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Professor Data Migration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Database Migration Tool',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This tool will migrate all static professor data from the app to Firestore database.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '⚠️ Warning: This should only be run once by administrators. Running multiple times may create duplicate entries.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Professors:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$_totalProfessors',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (_migratedCount > 0) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Migrated:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$_migratedCount',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_statusMessage.isNotEmpty)
              Card(
                color: _statusMessage.contains('failed')
                    ? Colors.red.shade50
                    : _statusMessage.contains('completed')
                        ? Colors.green.shade50
                        : Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _statusMessage.contains('failed')
                            ? Icons.error_outline
                            : _statusMessage.contains('completed')
                                ? Icons.check_circle_outline
                                : Icons.info_outline,
                        color: _statusMessage.contains('failed')
                            ? Colors.red
                            : _statusMessage.contains('completed')
                                ? Colors.green
                                : Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: TextStyle(
                            color: _statusMessage.contains('failed')
                                ? Colors.red.shade900
                                : _statusMessage.contains('completed')
                                    ? Colors.green.shade900
                                    : Colors.blue.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _migrateProfessors,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.upload),
              label: Text(
                _isLoading ? 'Migrating...' : 'Start Migration',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Close'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

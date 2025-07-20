import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../widgets/match_card.dart';
import '../theme.dart';
import 'match_sheet_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final DataService _dataService = DataService();
  List<Match> _matches = [];
  List<Team> _teams = [];
  String? _selectedTeamId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _dataService.initialize();
    if (mounted) {
      setState(() {
        _matches = _dataService.matches;
        _teams = _dataService.teams;
        _isLoading = false;
      });
    }
  }

  List<Match> get _filteredMatches {
    if (_selectedTeamId == null) return _matches;
    return _matches.where((match) =>
        match.homeTeamId == _selectedTeamId || match.awayTeamId == _selectedTeamId).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with title and filters
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Calendrier',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Team filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedTeamId,
                      hint: Text(
                        'Filtrer par équipe',
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      underline: const SizedBox(),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'Toutes les équipes',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        ..._teams.map((team) => DropdownMenuItem<String>(
                          value: team.id,
                          child: Text(
                            team.name,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        )).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTeamId = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Match status tabs
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatusTab(
                      'En direct',
                      _filteredMatches.where((m) => m.isLive).length,
                      Colors.red,
                      Icons.radio_button_checked,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _buildStatusTab(
                      'À venir',
                      _filteredMatches.where((m) => m.isScheduled).length,
                      Theme.of(context).colorScheme.primary,
                      Icons.schedule,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _buildStatusTab(
                      'Terminés',
                      _filteredMatches.where((m) => m.isFinished).length,
                      Theme.of(context).colorScheme.outline,
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ),

            // Matches list
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: _filteredMatches.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _filteredMatches.length,
                        itemBuilder: (context, index) {
                          final match = _filteredMatches[index];
                          final homeTeam = _dataService.getTeamById(match.homeTeamId);
                          final awayTeam = _dataService.getTeamById(match.awayTeamId);

                          if (homeTeam == null || awayTeam == null) {
                            return const SizedBox.shrink();
                          }

                          return MatchCard(
                            match: match,
                            homeTeam: homeTeam,
                            awayTeam: awayTeam,
                            onTap: () {
                              _showMatchDetails(match, homeTeam, awayTeam);
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTab(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_hockey,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun match trouvé',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedTeamId != null
                ? 'Aucun match pour cette équipe'
                : 'Aucun match programmé',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedTeamId = null;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réinitialiser les filtres'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMatchDetails(Match match, Team homeTeam, Team awayTeam) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Match info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Détails du match',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: match.isLive 
                      ? Colors.red
                      : match.isFinished 
                        ? Theme.of(context).colorScheme.outline
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    match.isLive ? 'EN DIRECT' : match.isFinished ? 'TERMINÉ' : 'À VENIR',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Teams and score
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.sports_hockey,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        homeTeam.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: match.isFinished || match.isLive
                    ? Text(
                        '${match.homeScore} - ${match.awayScore}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Icon(
                        Icons.sports_hockey,
                        color: Colors.white,
                        size: 32,
                      ),
                ),
                
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.sports_hockey,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        awayTeam.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Match details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE dd MMMM yyyy à HH:mm', 'fr_FR').format(match.date),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        match.venue,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (match.attendance > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${match.attendance} spectateurs',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                if (match.isLive || match.isFinished) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToMatchSheet(context, match, homeTeam, awayTeam);
                      },
                      icon: const Icon(Icons.timeline),
                      label: const Text('Feuille de match'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to team detail
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Détails des équipes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: match.isScheduled ? () {
                      Navigator.pop(context);
                      // Navigate to bet page
                    } : null,
                    icon: const Icon(Icons.sports_hockey),
                    label: const Text('Parier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMatchSheet(BuildContext context, Match match, Team homeTeam, Team awayTeam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchSheetPage(
          match: match,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/hybrid_data_service.dart';
import '../models/team.dart';
import '../models/match.dart';
import '../widgets/stat_widget.dart';
import '../widgets/match_card.dart';
import '../widgets/team_card.dart';
import '../theme.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HybridDataService _dataService = HybridDataService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = false;
    });
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

    final userProfile = _dataService.userProfile;
    final upcomingMatches = _dataService.getUpcomingMatches();
    final favoriteTeam = userProfile != null 
      ? _dataService.getTeamById(userProfile.favoriteTeamId) 
      : null;
    final trendingStats = _dataService.getTrendingStats();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with greeting and pucks
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bonjour,',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              Text(
                                userProfile?.username ?? 'HockeyFan',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          PucksWidget(
                            pucks: userProfile?.totalPucks ?? 0,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          StreakWidget(
                            streak: userProfile?.currentStreak ?? 0,
                            label: 'jours',
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Rang #${userProfile?.ranking ?? 0}',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Quote of the day
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _dataService.dailyQuote,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // User statistics
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📊 Mes Statistiques',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatWidget(
                              value: '${userProfile?.successRate.toStringAsFixed(1) ?? '0.0'}%',
                              label: 'Taux de réussite',
                              icon: Icons.trending_up,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatWidget(
                              value: '${userProfile?.totalBets ?? 0}',
                              label: 'Paris placés',
                              icon: Icons.sports_hockey,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Favorite team section
                if (favoriteTeam != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '⭐ Mon Équipe Favorite',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TeamCard(
                    team: favoriteTeam,
                    onTap: () {
                      // Navigate to team detail
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Trending stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔥 Tendances du Jour',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      HorizontalStatWidget(
                        value: trendingStats['mostBettedTeam'] ?? 'Aucune',
                        label: 'Équipe la plus pariée',
                        icon: Icons.trending_up,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      const SizedBox(height: 8),
                      HorizontalStatWidget(
                        value: '${trendingStats['biggestWin'] ?? 0} pucks',
                        label: 'Plus gros gain de la semaine',
                        icon: Icons.star,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 8),
                      HorizontalStatWidget(
                        value: trendingStats['topBettor'] ?? 'Aucun',
                        label: 'Meilleur parieur',
                        icon: Icons.emoji_events,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Upcoming matches
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '🗓️ Prochains Matchs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                if (upcomingMatches.isEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.sports_hockey,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun match programmé',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: upcomingMatches.length,
                      itemBuilder: (context, index) {
                        final match = upcomingMatches[index];
                        final homeTeam = _dataService.getTeamById(match.homeTeamId);
                        final awayTeam = _dataService.getTeamById(match.awayTeamId);
                        
                        if (homeTeam == null || awayTeam == null) {
                          return const SizedBox.shrink();
                        }
                        
                        return SizedBox(
                          width: 300,
                          child: MatchCard(
                            match: match,
                            homeTeam: homeTeam,
                            awayTeam: awayTeam,
                            onTap: () {
                              // Navigate to match detail
                            },
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
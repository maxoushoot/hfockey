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
        backgroundColor: AppColors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryBlue,
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              _buildHeader(),
              _buildQuote(),
              _buildQuickStats(),
              _buildTrendingStats(),
              _buildFavoriteTeam(),
              _buildUpcomingMatches(),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final userProfile = _dataService.userProfile;
    
    return SliverToBoxAdapter(
      child: Container(
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
                        color: Colors.white.withValues(alpha: 0.9),
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
                    color: Colors.white.withValues(alpha: 0.2),
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
    );
  }

  Widget _buildQuickStats() {
    final userProfile = _dataService.userProfile;
    
    return SliverToBoxAdapter(
      child: Padding(
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
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  // Layout pour tablette/desktop
                  return Row(
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
                  );
                } else {
                  // Layout pour mobile
                  return Row(
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
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuote() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingStats() {
    final trendingStats = _dataService.getTrendingStats();
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
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
    );
  }
  
  Widget _buildUpcomingMatches() {
    final upcomingMatches = _dataService.getUpcomingMatches();
    
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
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
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.sports_hockey,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun match programmé',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                double itemWidth = constraints.maxWidth > 600 ? 300 : 280;
                return SizedBox(
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
                        width: itemWidth,
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
                );
              },
            ),
        ],
      ),
    );
  }


  Widget _buildFavoriteTeam() {
    final userProfile = _dataService.userProfile;
    if (userProfile == null) return const SliverToBoxAdapter(child: SizedBox());
    
    final favoriteTeam = _dataService.getTeamById(userProfile.favoriteTeamId);
    if (favoriteTeam == null) return const SliverToBoxAdapter(child: SizedBox());
    
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
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
        ],
      ),
    );
  }

}
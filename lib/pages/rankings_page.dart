import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/team.dart';
import '../models/user_profile.dart';
import '../widgets/team_card.dart';
import '../theme.dart';

class RankingsPage extends StatefulWidget {
  const RankingsPage({super.key});

  @override
  State<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> with SingleTickerProviderStateMixin {
  final DataService _dataService = DataService();
  late TabController _tabController;
  bool _isLoading = true;
  List<Team> _teams = [];
  List<Map<String, dynamic>> _bettors = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _dataService.initialize();
    if (mounted) {
      setState(() {
        _teams = _dataService.teams;
        _teams.sort((a, b) => b.points.compareTo(a.points));
        _bettors = _generateBettorRankings();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _generateBettorRankings() {
    final userProfile = _dataService.userProfile;
    final bettors = <Map<String, dynamic>>[];
    
    // Add current user
    if (userProfile != null) {
      bettors.add({
        'rank': userProfile.ranking,
        'username': userProfile.username,
        'totalPucks': userProfile.totalPucks,
        'successRate': userProfile.successRate,
        'totalBets': userProfile.totalBets,
        'isCurrentUser': true,
      });
    }
    
    // Generate fake bettors for demo
    final usernames = [
      'HockeyMaster', 'IcePro', 'PuckExpert', 'GoalHunter', 'RinkLegend',
      'BladeRunner', 'IceWizard', 'PuckGuru', 'ShotMaster', 'HockeyAce',
      'FrozenFan', 'RinkRider', 'IceCrusher', 'PuckChamp', 'GoalKeeper',
      'HockeyHero', 'IcePhantom', 'PuckNinja', 'SlapShotKing', 'HockeyLord'
    ];
    
    for (int i = 0; i < 20; i++) {
      if (userProfile != null && i + 1 == userProfile.ranking) continue;
      
      final successRate = 45.0 + (i * 2.5);
      final totalPucks = 500 - (i * 20);
      final totalBets = 30 + (i * 5);
      
      bettors.add({
        'rank': i + 1,
        'username': usernames[i % usernames.length] + (i > usernames.length - 1 ? '${i - usernames.length + 1}' : ''),
        'totalPucks': totalPucks,
        'successRate': successRate,
        'totalBets': totalBets,
        'isCurrentUser': false,
      });
    }
    
    bettors.sort((a, b) => (a['rank'] as int).compareTo(b['rank'] as int));
    return bettors;
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
            // Header
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
                        Icons.leaderboard,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Classements',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Suivez les performances des équipes et des parieurs',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.sports_hockey),
                    text: 'Ligue Magnus',
                  ),
                  Tab(
                    icon: Icon(Icons.person),
                    text: 'Parieurs HF',
                  ),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTeamRankings(),
                  _buildBettorRankings(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRankings() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _teams.length,
        itemBuilder: (context, index) {
          final team = _teams[index];
          final position = index + 1;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Position
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getPositionColor(position),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$position',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Team logo
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.sports_hockey,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Team info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${team.wins}V - ${team.losses}D - ${team.overtimeLosses}DP',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Stats
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${team.points}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'pts',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    
                    // Goal difference
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: team.goalDifference >= 0 
                          ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                          : Theme.of(context).colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${team.goalDifference > 0 ? '+' : ''}${team.goalDifference}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: team.goalDifference >= 0 
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBettorRankings() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _bettors.length,
        itemBuilder: (context, index) {
          final bettor = _bettors[index];
          final isCurrentUser = bettor['isCurrentUser'] as bool;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              elevation: isCurrentUser ? 4 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isCurrentUser ? BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ) : BorderSide.none,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: isCurrentUser ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ) : null,
                child: Row(
                  children: [
                    // Position
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getPositionColor(bettor['rank']),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${bettor['rank']}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // User info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  bettor['username'],
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isCurrentUser ? Theme.of(context).colorScheme.primary : null,
                                  ),
                                ),
                              ),
                              if (isCurrentUser)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Vous',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.sports_hockey,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${bettor['totalPucks']} pucks',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.casino,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${bettor['totalBets']} paris',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Success rate
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${bettor['successRate'].toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'réussite',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getPositionColor(int position) {
    if (position == 1) return Colors.amber;
    if (position == 2) return Colors.grey[400]!;
    if (position == 3) return Colors.brown[400]!;
    if (position <= 5) return Theme.of(context).colorScheme.primary;
    if (position <= 10) return Theme.of(context).colorScheme.secondary;
    return Theme.of(context).colorScheme.outline;
  }
}
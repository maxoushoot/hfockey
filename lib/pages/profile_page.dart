import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/user_profile.dart';
import '../models/team.dart';
import '../widgets/stat_widget.dart';
import '../theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DataService _dataService = DataService();
  bool _isLoading = true;
  UserProfile? _userProfile;
  Team? _favoriteTeam;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _dataService.initialize();
    if (mounted) {
      setState(() {
        _userProfile = _dataService.userProfile;
        _favoriteTeam = _userProfile != null 
          ? _dataService.getTeamById(_userProfile!.favoriteTeamId)
          : null;
        _isLoading = false;
      });
    }
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

    if (_userProfile == null) {
      return _buildErrorState();
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header with profile info
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
                    children: [
                      // Profile avatar and name
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userProfile!.username,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _userProfile!.rankingTitle,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Quick stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickStat(
                            '${_userProfile!.totalPucks}',
                            'Pucks',
                            Icons.sports_hockey,
                          ),
                          _buildQuickStat(
                            '#${_userProfile!.ranking}',
                            'Rang',
                            Icons.emoji_events,
                          ),
                          _buildQuickStat(
                            '${_userProfile!.currentStreak}',
                            'Série',
                            Icons.local_fire_department,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Statistics section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📊 Mes Statistiques',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Betting stats
                      Row(
                        children: [
                          Expanded(
                            child: StatWidget(
                              value: '${_userProfile!.successRate.toStringAsFixed(1)}%',
                              label: 'Taux de réussite',
                              icon: Icons.trending_up,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatWidget(
                              value: '${_userProfile!.totalBets}',
                              label: 'Paris placés',
                              icon: Icons.casino,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatWidget(
                              value: '${_userProfile!.successfulBets}',
                              label: 'Paris gagnés',
                              icon: Icons.check_circle,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatWidget(
                              value: '${_userProfile!.totalLoginDays}',
                              label: 'Jours de connexion',
                              icon: Icons.calendar_today,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Favorite team section
                if (_favoriteTeam != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⭐ Mon Équipe Favorite',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
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
                                        Icons.sports_hockey,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _favoriteTeam!.name,
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _favoriteTeam!.city,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildTeamStat(
                                      '${_favoriteTeam!.points}',
                                      'Points',
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                    _buildTeamStat(
                                      '${_favoriteTeam!.wins}',
                                      'Victoires',
                                      Theme.of(context).colorScheme.secondary,
                                    ),
                                    _buildTeamStat(
                                      '${_favoriteTeam!.goalDifference > 0 ? '+' : ''}${_favoriteTeam!.goalDifference}',
                                      'Diff',
                                      _favoriteTeam!.goalDifference > 0 
                                        ? Theme.of(context).colorScheme.secondary
                                        : Theme.of(context).colorScheme.error,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Achievements section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🏆 Mes Réalisations',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAchievementsList(),
                    ],
                  ),
                ),

                // Settings section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚙️ Paramètres',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSettingsCard(),
                    ],
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

  Widget _buildQuickStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsList() {
    final achievements = [
      {
        'title': 'Premier pari',
        'description': 'Vous avez placé votre premier pari !',
        'icon': Icons.star,
        'unlocked': _userProfile!.totalBets > 0,
      },
      {
        'title': 'Parieur régulier',
        'description': 'Vous avez placé 10 paris',
        'icon': Icons.casino,
        'unlocked': _userProfile!.totalBets >= 10,
      },
      {
        'title': 'Série de victoires',
        'description': 'Vous avez une série de 5 connexions',
        'icon': Icons.local_fire_department,
        'unlocked': _userProfile!.currentStreak >= 5,
      },
      {
        'title': 'Expert du hockey',
        'description': 'Vous avez un taux de réussite de 70%',
        'icon': Icons.school,
        'unlocked': _userProfile!.successRate >= 70,
      },
    ];

    return Column(
      children: achievements.map((achievement) => _buildAchievementCard(achievement)).toList(),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final isUnlocked = achievement['unlocked'] as bool;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isUnlocked 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              child: Icon(
                achievement['icon'],
                color: isUnlocked ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement['title'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isUnlocked 
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement['description'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isUnlocked 
                        ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (isUnlocked)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Modifier le profil'),
            subtitle: const Text('Changer votre nom d\'utilisateur et équipe favorite'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showEditProfileDialog();
            },
          ),
          Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            height: 1,
          ),
          ListTile(
            leading: Icon(
              Icons.palette,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: const Text('Thème'),
            subtitle: const Text('Clair, sombre ou automatique'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Fonctionnalité bientôt disponible'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
          Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            height: 1,
          ),
          ListTile(
            leading: Icon(
              Icons.info,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            title: const Text('À propos'),
            subtitle: const Text('Version 1.0.0 - Hockey Français'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Hockey Français',
                applicationVersion: '1.0.0',
                applicationIcon: Icon(
                  Icons.sports_hockey,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: [
                  const Text('L\'application communautaire du hockey français.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Impossible de charger les données du profil',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final TextEditingController usernameController = TextEditingController(text: _userProfile!.username);
    String? selectedTeamId = _userProfile!.favoriteTeamId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nom d\'utilisateur'),
            const SizedBox(height: 8),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                hintText: 'Entrez votre nom d\'utilisateur',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Équipe favorite'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedTeamId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: _dataService.teams.map((team) => DropdownMenuItem(
                value: team.id,
                child: Text(team.name),
              )).toList(),
              onChanged: (value) {
                selectedTeamId = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (usernameController.text.isNotEmpty && selectedTeamId != null) {
                final updatedProfile = _userProfile!.copyWith(
                  username: usernameController.text,
                  favoriteTeamId: selectedTeamId,
                );
                _dataService.updateUserProfile(updatedProfile);
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profil mis à jour avec succès'),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                );
              }
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }
}
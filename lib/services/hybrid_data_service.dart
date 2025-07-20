import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/team.dart';
import '../models/match.dart';
import '../models/user_profile.dart';
import '../models/bet.dart';
import '../models/match_event.dart';
import '../models/event_reaction.dart';
import 'supabase_service.dart';

class HybridDataService {
  static final HybridDataService _instance = HybridDataService._internal();
  factory HybridDataService() => _instance;
  HybridDataService._internal();

  final SupabaseService _supabaseService = SupabaseService();
  
  static const String _teamsKey = 'teams_data';
  static const String _matchesKey = 'matches_data';
  static const String _userProfileKey = 'user_profile_data';
  static const String _betsKey = 'bets_data';
  static const String _dailyQuoteKey = 'daily_quote';
  static const String _lastQuoteDate = 'last_quote_date';
  static const String _offlineModeKey = 'offline_mode';
  static const String _matchEventsKey = 'match_events_data';
  static const String _eventReactionsKey = 'event_reactions_data';

  List<Team> _teams = [];
  List<Match> _matches = [];
  UserProfile? _userProfile;
  List<Bet> _bets = [];
  String _dailyQuote = '';
  bool _isOfflineMode = false;
  Map<String, List<MatchEvent>> _matchEvents = {};
  Map<String, List<EventReaction>> _eventReactions = {};

  final List<String> _hockeyQuotes = [
    'Le hockey, c\'est de la poésie en mouvement sur la glace.',
    'Un match de hockey se gagne avec le cœur, pas seulement avec les jambes.',
    'La glace révèle le caractère des joueurs.',
    'En hockey, chaque seconde compte, chaque passe est décisive.',
    'Le vrai hockey français commence dans les petites patinoires.',
    'La Ligue Magnus, c\'est l\'excellence du hockey français.',
    'Un gardien de but, c\'est le dernier rempart de l\'équipe.',
    'Le hockey sur glace unit les générations autour d\'une passion.',
    'Dans le hockey, la vitesse se marie avec la stratégie.',
    'Chaque but marqué est une victoire collective.',
  ];

  Future<void> initialize() async {
    await _loadOfflineMode();
    
    // Essayer d'initialiser Supabase
    try {
      await _supabaseService.initialize();
      _isOfflineMode = false;
      await _saveOfflineMode();
    } catch (e) {
      print('Supabase non disponible, mode hors ligne activé: $e');
      _isOfflineMode = true;
    }
    
    // Charger les données locales
    await _loadLocalData();
    
    // Si en ligne, synchroniser avec Supabase
    if (!_isOfflineMode) {
      await _syncWithSupabase();
    }
    
    // Initialiser les données si nécessaire
    if (_teams.isEmpty) {
      await _initializeTeams();
    }
    if (_matches.isEmpty) {
      await _initializeMatches();
    }
    if (_userProfile == null) {
      await _initializeUserProfile();
    }
    
    await _loadDailyQuote();
  }

  Future<void> _loadOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isOfflineMode = prefs.getBool(_offlineModeKey) ?? false;
  }

  Future<void> _saveOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineModeKey, _isOfflineMode);
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Charger les équipes
    final teamsJson = prefs.getString(_teamsKey);
    if (teamsJson != null) {
      final List<dynamic> teamsList = json.decode(teamsJson);
      _teams = teamsList.map((team) => Team.fromJson(team)).toList();
    }
    
    // Charger les matchs
    final matchesJson = prefs.getString(_matchesKey);
    if (matchesJson != null) {
      final List<dynamic> matchesList = json.decode(matchesJson);
      _matches = matchesList.map((match) => Match.fromJson(match)).toList();
    }
    
    // Charger le profil utilisateur
    final userProfileJson = prefs.getString(_userProfileKey);
    if (userProfileJson != null) {
      _userProfile = UserProfile.fromJson(json.decode(userProfileJson));
    }
    
    // Charger les paris
    final betsJson = prefs.getString(_betsKey);
    if (betsJson != null) {
      final List<dynamic> betsList = json.decode(betsJson);
      _bets = betsList.map((bet) => Bet.fromJson(bet)).toList();
    }
  }

  Future<void> _saveLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Sauvegarder les équipes
    await prefs.setString(_teamsKey, json.encode(_teams.map((team) => team.toJson()).toList()));
    
    // Sauvegarder les matchs
    await prefs.setString(_matchesKey, json.encode(_matches.map((match) => match.toJson()).toList()));
    
    // Sauvegarder le profil utilisateur
    if (_userProfile != null) {
      await prefs.setString(_userProfileKey, json.encode(_userProfile!.toJson()));
    }
    
    // Sauvegarder les paris
    await prefs.setString(_betsKey, json.encode(_bets.map((bet) => bet.toJson()).toList()));
  }

  Future<void> _syncWithSupabase() async {
    if (_isOfflineMode) return;
    
    try {
      // Synchroniser les équipes
      final supabaseTeams = await _supabaseService.getTeams();
      if (supabaseTeams.isNotEmpty) {
        _teams = supabaseTeams;
      }
      
      // Synchroniser les matchs
      final supabaseMatches = await _supabaseService.getMatches();
      if (supabaseMatches.isNotEmpty) {
        _matches = supabaseMatches;
      }
      
      // Synchroniser le profil utilisateur
      if (_supabaseService.currentUser != null) {
        final userProfile = await _supabaseService.getUserProfile(_supabaseService.currentUser!.id);
        if (userProfile != null) {
          _userProfile = userProfile;
        }
      }
      
      // Sauvegarder localement
      await _saveLocalData();
    } catch (e) {
      print('Erreur lors de la synchronisation: $e');
      _isOfflineMode = true;
      await _saveOfflineMode();
    }
  }

  // Méthodes pour les équipes
  List<Team> get teams => _teams;
  
  Team? getTeamById(String id) {
    try {
      return _teams.firstWhere((team) => team.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _initializeTeams() async {
    if (_teams.isNotEmpty) return;
    
    final teamNames = [
      ['Grenoble', 'Brûleurs de Loups'],
      ['Rouen', 'Dragons'],
      ['Amiens', 'Gothiques'],
      ['Angers', 'Ducs'],
      ['Bordeaux', 'Boxers'],
      ['Briançon', 'Diables Rouges'],
      ['Chamonix', 'Pionniers'],
      ['Cergy-Pontoise', 'Jokers'],
      ['Gap', 'Rapaces'],
      ['Mulhouse', 'Scorpions'],
      ['Nice', 'Aigles'],
      ['Strasbourg', 'Étoile Noire'],
      ['Anglet', 'Hormadi'],
      ['Mont-Blanc', 'Yétis'],
    ];

    _teams = teamNames.map((team) {
      final random = Random();
      final wins = random.nextInt(25) + 5;
      final losses = random.nextInt(15) + 3;
      final overtimeLosses = random.nextInt(8) + 1;
      final goalsFor = random.nextInt(80) + 60;
      final goalsAgainst = random.nextInt(70) + 45;
      
      return Team(
        id: const Uuid().v4(),
        name: team[1],
        city: team[0],
        arena: 'Patinoire de ${team[0]}',
        logoUrl: 'https://via.placeholder.com/100',
        points: wins * 3 + overtimeLosses,
        wins: wins,
        losses: losses,
        overtimeLosses: overtimeLosses,
        goalsFor: goalsFor,
        goalsAgainst: goalsAgainst,
        players: _generatePlayers(),
        staff: _generateStaff(),
        description: 'Équipe professionnelle de ${team[0]} évoluant en Ligue Magnus.',
      );
    }).toList();

    // Trier par points
    _teams.sort((a, b) => b.points.compareTo(a.points));
    
    await _saveLocalData();
    
    // Synchroniser avec Supabase si possible
    if (!_isOfflineMode) {
      try {
        for (final team in _teams) {
          await _supabaseService.insertTeam(team);
        }
      } catch (e) {
        print('Erreur lors de la synchronisation des équipes: $e');
      }
    }
  }

  List<String> _generatePlayers() {
    final firstNames = ['Pierre', 'Antoine', 'Nicolas', 'Thomas', 'Alexandre', 'Julien', 'Maxime', 'Florian', 'Sébastien', 'Mathieu'];
    final lastNames = ['Dubois', 'Martin', 'Bernard', 'Petit', 'Robert', 'Richard', 'Durand', 'Leroy', 'Moreau', 'Simon'];
    
    return List.generate(22, (index) {
      final firstName = firstNames[Random().nextInt(firstNames.length)];
      final lastName = lastNames[Random().nextInt(lastNames.length)];
      return '$firstName $lastName';
    });
  }

  List<String> _generateStaff() {
    return [
      'Jean-Marc Dupont - Entraîneur principal',
      'Alain Lefebvre - Entraîneur adjoint',
      'Michel Rousseau - Préparateur physique',
      'Sophie Lemoine - Kinésithérapeute',
    ];
  }

  // Méthodes pour les matchs
  List<Match> get matches => _matches;
  
  List<Match> getMatchesByTeam(String teamId) => _matches.where((match) => 
    match.homeTeamId == teamId || match.awayTeamId == teamId
  ).toList();

  List<Match> getUpcomingMatches() => _matches.where((match) => 
    match.status == 'scheduled' && match.date.isAfter(DateTime.now())
  ).take(5).toList();

  Future<void> _initializeMatches() async {
    if (_matches.isNotEmpty || _teams.isEmpty) return;
    
    final random = Random();
    final now = DateTime.now();
    
    // Générer 50 matchs
    for (int i = 0; i < 50; i++) {
      final homeTeam = _teams[random.nextInt(_teams.length)];
      Team awayTeam;
      do {
        awayTeam = _teams[random.nextInt(_teams.length)];
      } while (awayTeam.id == homeTeam.id);
      
      final daysOffset = random.nextInt(60) - 30; // Entre -30 et +30 jours
      final matchDate = now.add(Duration(days: daysOffset));
      
      String status;
      int? homeScore;
      int? awayScore;
      
      if (matchDate.isBefore(now.subtract(const Duration(days: 1)))) {
        status = 'finished';
        homeScore = random.nextInt(6);
        awayScore = random.nextInt(6);
      } else if (matchDate.isBefore(now.add(const Duration(hours: 3))) && 
                 matchDate.isAfter(now.subtract(const Duration(hours: 3)))) {
        status = random.nextBool() ? 'live' : 'scheduled';
        if (status == 'live') {
          homeScore = random.nextInt(4);
          awayScore = random.nextInt(4);
        }
      } else {
        status = 'scheduled';
      }
      
      final match = Match(
        id: const Uuid().v4(),
        homeTeamId: homeTeam.id,
        awayTeamId: awayTeam.id,
        date: matchDate,
        status: status,
        homeScore: homeScore,
        awayScore: awayScore,
        venue: homeTeam.arena,
        period: status == 'live' ? random.nextInt(3) + 1 : null,
        timeRemaining: status == 'live' ? '${random.nextInt(20)}:${random.nextInt(60).toString().padLeft(2, '0')}' : null,
        isPlayoffs: random.nextDouble() < 0.1,
        attendance: random.nextInt(3000) + 1000,
      );
      
      _matches.add(match);
    }
    
    // Trier par date
    _matches.sort((a, b) => a.date.compareTo(b.date));
    
    await _saveLocalData();
    
    // Synchroniser avec Supabase si possible
    if (!_isOfflineMode) {
      try {
        for (final match in _matches) {
          await _supabaseService.insertMatch(match);
        }
      } catch (e) {
        print('Erreur lors de la synchronisation des matchs: $e');
      }
    }
  }

  // Méthodes pour le profil utilisateur
  UserProfile? get userProfile => _userProfile;

  Future<void> _initializeUserProfile() async {
    if (_userProfile != null) return;
    
    _userProfile = UserProfile(
      username: 'HockeyFan',
      favoriteTeamId: _teams.isNotEmpty ? _teams.first.id : '',
      totalPucks: 1000,
      successfulBets: 0,
      totalBets: 0,
      currentStreak: 0,
      ranking: 1,
      avatarUrl: 'https://via.placeholder.com/100',
      lastLoginDate: DateTime.now(),
      totalLoginDays: 1,
    );
    
    await _saveLocalData();
    
    // Synchroniser avec Supabase si possible
    if (!_isOfflineMode && _supabaseService.currentUser != null) {
      try {
        await _supabaseService.insertUserProfile(_userProfile!);
      } catch (e) {
        print('Erreur lors de la synchronisation du profil: $e');
      }
    }
  }

  Future<void> updateUserProfile(UserProfile newProfile) async {
    _userProfile = newProfile;
    await _saveLocalData();
    
    // Synchroniser avec Supabase si possible
    if (!_isOfflineMode) {
      try {
        await _supabaseService.updateUserProfile(newProfile);
      } catch (e) {
        print('Erreur lors de la mise à jour du profil: $e');
      }
    }
  }

  // Méthodes pour les paris
  List<Bet> get bets => _bets;

  Future<void> placeBet(Bet bet) async {
    if (_userProfile == null) return;
    
    // Vérifier si l'utilisateur a assez de pucks
    if (_userProfile!.totalPucks < bet.pucksWagered) {
      throw Exception('Pucks insuffisants');
    }
    
    // Déduire les pucks
    _userProfile = _userProfile!.copyWith(
      totalPucks: _userProfile!.totalPucks - bet.pucksWagered,
      totalBets: _userProfile!.totalBets + 1,
    );
    
    _bets.add(bet);
    await _saveLocalData();
    
    // Synchroniser avec Supabase si possible
    if (!_isOfflineMode && _supabaseService.currentUser != null) {
      try {
        await _supabaseService.placeBet(bet, _supabaseService.currentUser!.id);
        await _supabaseService.updateUserProfile(_userProfile!);
      } catch (e) {
        print('Erreur lors de la synchronisation du pari: $e');
      }
    }
  }

  // Méthodes pour les citations quotidiennes
  Future<void> _loadDailyQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    final lastQuoteDateString = prefs.getString(_lastQuoteDate);
    
    if (lastQuoteDateString != todayString) {
      // Nouvelle citation pour aujourd'hui
      final random = Random();
      _dailyQuote = _hockeyQuotes[random.nextInt(_hockeyQuotes.length)];
      
      await prefs.setString(_dailyQuoteKey, _dailyQuote);
      await prefs.setString(_lastQuoteDate, todayString);
    } else {
      // Charger la citation du jour
      _dailyQuote = prefs.getString(_dailyQuoteKey) ?? _hockeyQuotes[0];
    }
  }

  String get dailyQuote => _dailyQuote;

  // Méthodes pour les statistiques
  List<Team> getTopTeams() {
    final sortedTeams = List<Team>.from(_teams);
    sortedTeams.sort((a, b) => b.points.compareTo(a.points));
    return sortedTeams.take(5).toList();
  }

  Map<String, dynamic> getTrendingStats() {
    final random = Random();
    return {
      'totalMatches': _matches.length,
      'liveMatches': _matches.where((m) => m.status == 'live').length,
      'totalBets': _bets.length,
      'activePlayers': random.nextInt(500) + 100,
      'topTeam': _teams.isNotEmpty ? _teams.first.name : 'Aucune équipe',
      'biggestWin': random.nextInt(500) + 100,
    };
  }

  // Méthodes pour les classements
  List<Map<String, dynamic>> getTopBettors() {
    final random = Random();
    return List.generate(20, (index) {
      final successRate = random.nextDouble() * 100;
      final totalBets = random.nextInt(50) + 10;
      final successfulBets = (totalBets * successRate / 100).round();
      
      return {
        'username': 'Parieur${index + 1}',
        'totalPucks': random.nextInt(5000) + 1000,
        'successfulBets': successfulBets,
        'totalBets': totalBets,
        'successRate': successRate,
        'ranking': index + 1,
        'isCurrentUser': index == 0,
      };
    });
  }

  // Méthodes pour les événements de match
  Future<List<MatchEvent>> getMatchEvents(String matchId) async {
    try {
      if (!_isOfflineMode) {
        final events = await _supabaseService.getMatchEvents(matchId);
        _matchEvents[matchId] = events;
        await _saveMatchEvents();
        return events;
      }
    } catch (e) {
      print('Erreur lors de la récupération des événements: $e');
    }
    
    // Fallback sur les données locales
    await _loadMatchEvents();
    return _matchEvents[matchId] ?? _generateSampleEvents(matchId);
  }

  Future<void> _loadMatchEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString(_matchEventsKey);
    
    if (eventsJson != null) {
      final Map<String, dynamic> eventsMap = json.decode(eventsJson);
      _matchEvents = eventsMap.map((key, value) {
        return MapEntry(key, (value as List).map((e) => MatchEvent.fromJson(e)).toList());
      });
    }
  }

  Future<void> _saveMatchEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsMap = _matchEvents.map((key, value) {
      return MapEntry(key, value.map((e) => e.toJson()).toList());
    });
    await prefs.setString(_matchEventsKey, json.encode(eventsMap));
  }

  List<MatchEvent> _generateSampleEvents(String matchId) {
    final random = Random();
    final events = <MatchEvent>[];
    final uuid = const Uuid();
    
    // Générer des événements d'exemple pour les matchs
    final match = _matches.firstWhere((m) => m.id == matchId, orElse: () => _matches.first);
    
    if (match.isLive || match.isFinished) {
      // Événements de but
      for (int i = 0; i < (match.homeScore ?? 0); i++) {
        events.add(MatchEvent(
          id: uuid.v4(),
          matchId: matchId,
          type: 'goal',
          description: 'But marqué par l\'équipe domicile',
          playerName: 'Joueur ${i + 1}',
          teamId: match.homeTeamId,
          minute: random.nextInt(60) + 1,
          period: random.nextInt(3) + 1,
          timestamp: DateTime.now().subtract(Duration(minutes: random.nextInt(120))),
        ));
      }
      
      for (int i = 0; i < (match.awayScore ?? 0); i++) {
        events.add(MatchEvent(
          id: uuid.v4(),
          matchId: matchId,
          type: 'goal',
          description: 'But marqué par l\'équipe visiteur',
          playerName: 'Joueur ${i + 1}',
          teamId: match.awayTeamId,
          minute: random.nextInt(60) + 1,
          period: random.nextInt(3) + 1,
          timestamp: DateTime.now().subtract(Duration(minutes: random.nextInt(120))),
        ));
      }
      
      // Événements de pénalité
      for (int i = 0; i < random.nextInt(5) + 2; i++) {
        events.add(MatchEvent(
          id: uuid.v4(),
          matchId: matchId,
          type: 'penalty',
          description: 'Pénalité de 2 minutes',
          playerName: 'Joueur ${i + 1}',
          teamId: random.nextBool() ? match.homeTeamId : match.awayTeamId,
          minute: random.nextInt(60) + 1,
          period: random.nextInt(3) + 1,
          timestamp: DateTime.now().subtract(Duration(minutes: random.nextInt(120))),
        ));
      }
      
      // Événements de début/fin de période
      for (int period = 1; period <= 3; period++) {
        events.add(MatchEvent(
          id: uuid.v4(),
          matchId: matchId,
          type: 'period_start',
          description: 'Début de la ${period}e période',
          minute: 0,
          period: period,
          timestamp: DateTime.now().subtract(Duration(minutes: random.nextInt(120))),
        ));
        
        events.add(MatchEvent(
          id: uuid.v4(),
          matchId: matchId,
          type: 'period_end',
          description: 'Fin de la ${period}e période',
          minute: 20,
          period: period,
          timestamp: DateTime.now().subtract(Duration(minutes: random.nextInt(120))),
        ));
      }
    }
    
    // Trier les événements par minute
    events.sort((a, b) => a.minute.compareTo(b.minute));
    
    _matchEvents[matchId] = events;
    _saveMatchEvents();
    
    return events;
  }

  // Méthodes pour les réactions aux événements
  Future<Map<String, List<EventReaction>>> getEventReactions(String matchId) async {
    try {
      if (!_isOfflineMode) {
        final reactions = await _supabaseService.getEventReactions(matchId);
        _eventReactions = reactions;
        await _saveEventReactions();
        return reactions;
      }
    } catch (e) {
      print('Erreur lors de la récupération des réactions: $e');
    }
    
    // Fallback sur les données locales
    await _loadEventReactions();
    return _eventReactions;
  }

  Future<void> _loadEventReactions() async {
    final prefs = await SharedPreferences.getInstance();
    final reactionsJson = prefs.getString(_eventReactionsKey);
    
    if (reactionsJson != null) {
      final Map<String, dynamic> reactionsMap = json.decode(reactionsJson);
      _eventReactions = reactionsMap.map((key, value) {
        return MapEntry(key, (value as List).map((e) => EventReaction.fromJson(e)).toList());
      });
    }
  }

  Future<void> _saveEventReactions() async {
    final prefs = await SharedPreferences.getInstance();
    final reactionsMap = _eventReactions.map((key, value) {
      return MapEntry(key, value.map((e) => e.toJson()).toList());
    });
    await prefs.setString(_eventReactionsKey, json.encode(reactionsMap));
  }

  Future<void> addEventReaction(String eventId, String emoji) async {
    final uuid = const Uuid();
    final reaction = EventReaction(
      id: uuid.v4(),
      eventId: eventId,
      userId: 'current_user_id',
      username: _userProfile?.username ?? 'Utilisateur',
      emoji: emoji,
      timestamp: DateTime.now(),
    );

    try {
      if (!_isOfflineMode) {
        await _supabaseService.addEventReaction(reaction);
      }
    } catch (e) {
      print('Erreur lors de l\'ajout de la réaction: $e');
    }
    
    // Ajouter localement
    if (!_eventReactions.containsKey(eventId)) {
      _eventReactions[eventId] = [];
    }
    _eventReactions[eventId]!.add(reaction);
    await _saveEventReactions();
  }

  // Getters pour le mode
  bool get isOfflineMode => _isOfflineMode;
  bool get isOnlineMode => !_isOfflineMode;
}
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/team.dart';
import '../models/match.dart';
import '../models/user_profile.dart';
import '../models/bet.dart';


class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  static const String _teamsKey = 'teams_data';
  static const String _matchesKey = 'matches_data';
  static const String _userProfileKey = 'user_profile_data';
  static const String _betsKey = 'bets_data';
  static const String _dailyQuoteKey = 'daily_quote';
  static const String _lastQuoteDate = 'last_quote_date';

  List<Team> _teams = [];
  List<Match> _matches = [];
  UserProfile? _userProfile;
  List<Bet> _bets = [];
  String _dailyQuote = '';

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

  // Initialize data
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load existing data
    await _loadTeams();
    await _loadMatches();
    await _loadUserProfile();
    await _loadBets();
    await _loadDailyQuote();
    
    // Initialize with sample data if needed
    if (_teams.isEmpty) {
      await _initializeTeams();
    }
    if (_matches.isEmpty) {
      await _initializeMatches();
    }
    if (_userProfile == null) {
      await _initializeUserProfile();
    }
    
    // Update daily login
    await _updateDailyLogin();
  }

  // Teams methods
  Future<void> _loadTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final String? teamsJson = prefs.getString(_teamsKey);
    if (teamsJson != null) {
      final List<dynamic> teamsList = jsonDecode(teamsJson);
      _teams = teamsList.map((json) => Team.fromJson(json)).toList();
    }
  }

  Future<void> _saveTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final String teamsJson = jsonEncode(_teams.map((team) => team.toJson()).toList());
    await prefs.setString(_teamsKey, teamsJson);
  }

  Future<void> _initializeTeams() async {
    final List<String> teamNames = [
      'Grenoble Brûleurs de Loups', 'Rouen Dragons', 'Amiens Gothiques',
      'Angers Ducs', 'Bordeaux Boxers', 'Chamonix Pionniers',
      'Cergy-Pontoise Jokers', 'Gap Rapaces', 'Mulhouse Scorpions',
      'Nice Aiglons', 'Strasbourg Étoile Noire', 'Briançon Diables Rouges',
      'Anglet Hormadi', 'Mont-Blanc Yétis'
    ];

    final Random random = Random();
    
    for (int i = 0; i < teamNames.length; i++) {
      final teamName = teamNames[i];
      final city = teamName.split(' ')[0];
      
      _teams.add(Team(
        id: 'team_$i',
        name: teamName,
        city: city,
        arena: 'Patinoire de $city',
        logoUrl: "https://pixabay.com/get/gf5d1b3728915096e80d153900dd775b496db4f15e6d554096f53fe6939f02638255193ffc9a33fa56d044c946e7378e7171347805ce2782c0dfd1ac253546848_1280.jpg",
        points: random.nextInt(60) + 20,
        wins: random.nextInt(25) + 5,
        losses: random.nextInt(20) + 3,
        overtimeLosses: random.nextInt(8) + 1,
        goalsFor: random.nextInt(100) + 80,
        goalsAgainst: random.nextInt(100) + 70,
        players: List.generate(20, (index) => 'Joueur ${index + 1}'),
        staff: ['Entraîneur Principal', 'Entraîneur Adjoint', 'Préparateur Physique'],
        description: 'Une équipe historique de la Ligue Magnus française.',
      ));
    }
    
    await _saveTeams();
  }

  List<Team> get teams => _teams;
  
  Team? getTeamById(String id) => _teams.firstWhere((team) => team.id == id);

  // Matches methods
  Future<void> _loadMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final String? matchesJson = prefs.getString(_matchesKey);
    if (matchesJson != null) {
      final List<dynamic> matchesList = jsonDecode(matchesJson);
      _matches = matchesList.map((json) => Match.fromJson(json)).toList();
    }
  }

  Future<void> _saveMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final String matchesJson = jsonEncode(_matches.map((match) => match.toJson()).toList());
    await prefs.setString(_matchesKey, matchesJson);
  }

  Future<void> _initializeMatches() async {
    final Random random = Random();
    final now = DateTime.now();
    
    for (int i = 0; i < 50; i++) {
      final homeTeam = _teams[random.nextInt(_teams.length)];
      Team awayTeam;
      do {
        awayTeam = _teams[random.nextInt(_teams.length)];
      } while (awayTeam.id == homeTeam.id);
      
      final matchDate = now.add(Duration(days: random.nextInt(60) - 30));
      
      String status;
      int? homeScore, awayScore;
      
      if (matchDate.isBefore(now.subtract(const Duration(days: 1)))) {
        status = 'finished';
        homeScore = random.nextInt(8);
        awayScore = random.nextInt(8);
      } else if (matchDate.isAfter(now.add(const Duration(days: 1)))) {
        status = 'scheduled';
      } else {
        status = random.nextBool() ? 'live' : 'scheduled';
        if (status == 'live') {
          homeScore = random.nextInt(5);
          awayScore = random.nextInt(5);
        }
      }
      
      _matches.add(Match(
        id: 'match_$i',
        homeTeamId: homeTeam.id,
        awayTeamId: awayTeam.id,
        date: matchDate,
        status: status,
        homeScore: homeScore,
        awayScore: awayScore,
        venue: homeTeam.arena,
        period: status == 'live' ? random.nextInt(3) + 1 : null,
        timeRemaining: status == 'live' ? '${random.nextInt(20)}:${random.nextInt(60).toString().padLeft(2, '0')}' : null,
        attendance: random.nextInt(5000) + 1000,
      ));
    }
    
    _matches.sort((a, b) => a.date.compareTo(b.date));
    await _saveMatches();
  }

  List<Match> get matches => _matches;
  
  List<Match> getMatchesByTeam(String teamId) => _matches.where((match) => 
    match.homeTeamId == teamId || match.awayTeamId == teamId
  ).toList();

  List<Match> getUpcomingMatches() => _matches.where((match) => 
    match.status == 'scheduled' && match.date.isAfter(DateTime.now())
  ).take(5).toList();

  // User profile methods
  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString(_userProfileKey);
    if (profileJson != null) {
      _userProfile = UserProfile.fromJson(jsonDecode(profileJson));
    }
  }

  Future<void> _saveUserProfile() async {
    if (_userProfile == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String profileJson = jsonEncode(_userProfile!.toJson());
    await prefs.setString(_userProfileKey, profileJson);
  }

  Future<void> _initializeUserProfile() async {
    final Random random = Random();
    _userProfile = UserProfile(
      username: 'HockeyFan${random.nextInt(1000)}',
      favoriteTeamId: _teams[random.nextInt(_teams.length)].id,
      totalPucks: 100,
      successfulBets: 15,
      totalBets: 25,
      currentStreak: 3,
      ranking: random.nextInt(500) + 1,
      avatarUrl: "https://pixabay.com/get/g1998397dc0abee53288df0f3d66e8f1b34a6c8b3dd2033718ff14c34fd233b915cf90a8b81f7e87d11daae618d78790d0d5c34be89db54b56daef35b4b8a353c_1280.jpg",
      lastLoginDate: DateTime.now(),
      totalLoginDays: 1,
    );
    await _saveUserProfile();
  }

  UserProfile? get userProfile => _userProfile;

  Future<void> updateUserProfile(UserProfile newProfile) async {
    _userProfile = newProfile;
    await _saveUserProfile();
  }

  Future<void> _updateDailyLogin() async {
    if (_userProfile == null) return;
    
    final now = DateTime.now();
    final lastLogin = _userProfile!.lastLoginDate;
    
    if (!_isSameDay(now, lastLogin)) {
      final isConsecutive = _isConsecutiveDay(now, lastLogin);
      _userProfile = _userProfile!.copyWith(
        lastLoginDate: now,
        totalLoginDays: _userProfile!.totalLoginDays + 1,
        currentStreak: isConsecutive ? _userProfile!.currentStreak + 1 : 1,
        totalPucks: _userProfile!.totalPucks + 5, // Daily bonus
      );
      await _saveUserProfile();
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _isConsecutiveDay(DateTime today, DateTime lastLogin) {
    final yesterday = today.subtract(const Duration(days: 1));
    return _isSameDay(yesterday, lastLogin);
  }

  // Bets methods
  Future<void> _loadBets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? betsJson = prefs.getString(_betsKey);
    if (betsJson != null) {
      final List<dynamic> betsList = jsonDecode(betsJson);
      _bets = betsList.map((json) => Bet.fromJson(json)).toList();
    }
  }

  Future<void> _saveBets() async {
    final prefs = await SharedPreferences.getInstance();
    final String betsJson = jsonEncode(_bets.map((bet) => bet.toJson()).toList());
    await prefs.setString(_betsKey, betsJson);
  }

  List<Bet> get bets => _bets;

  Future<void> placeBet(Bet bet) async {
    if (_userProfile == null || _userProfile!.totalPucks < bet.pucksWagered) {
      throw Exception('Pas assez de pucks');
    }
    
    _bets.add(bet);
    _userProfile = _userProfile!.copyWith(
      totalPucks: _userProfile!.totalPucks - bet.pucksWagered,
      totalBets: _userProfile!.totalBets + 1,
    );
    
    await _saveBets();
    await _saveUserProfile();
  }

  // Daily quote methods
  Future<void> _loadDailyQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final String? quote = prefs.getString(_dailyQuoteKey);
    final String? lastDate = prefs.getString(_lastQuoteDate);
    
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    
    if (quote != null && lastDate == todayString) {
      _dailyQuote = quote;
    } else {
      final Random random = Random();
      _dailyQuote = _hockeyQuotes[random.nextInt(_hockeyQuotes.length)];
      
      await prefs.setString(_dailyQuoteKey, _dailyQuote);
      await prefs.setString(_lastQuoteDate, todayString);
    }
  }

  String get dailyQuote => _dailyQuote;

  // Statistics methods
  List<Team> getTopTeams() {
    final sortedTeams = List<Team>.from(_teams);
    sortedTeams.sort((a, b) => b.points.compareTo(a.points));
    return sortedTeams.take(5).toList();
  }

  Map<String, dynamic> getTrendingStats() {
    final Random random = Random();
    return {
      'mostBettedTeam': _teams[random.nextInt(_teams.length)].name,
      'biggestWin': random.nextInt(500) + 100,
      'hotMatch': _matches.where((m) => m.status == 'scheduled').isNotEmpty 
        ? _matches.where((m) => m.status == 'scheduled').first.id
        : null,
      'topBettor': 'HockeyPro${random.nextInt(100)}',
    };
  }
}
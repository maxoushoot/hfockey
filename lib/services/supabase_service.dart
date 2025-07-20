import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/team.dart';
import '../models/match.dart';
import '../models/user_profile.dart';
import '../models/bet.dart';
import '../models/match_event.dart';
import '../models/event_reaction.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  // Méthodes pour les équipes
  Future<List<Team>> getTeams() async {
    try {
      final response = await _client
          .from(SupabaseConfig.teamsTable)
          .select()
          .order('points', ascending: false);
      
      return (response as List)
          .map((teamData) => Team.fromJson(teamData))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des équipes: $e');
    }
  }

  Future<Team?> getTeamById(String id) async {
    try {
      final response = await _client
          .from('teams')
          .select()
          .eq('id', id)
          .single();
      
      return Team.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> insertTeam(Team team) async {
    try {
      await _client.from('teams').insert(team.toJson());
    } catch (e) {
      throw Exception('Erreur lors de l\'insertion de l\'équipe: $e');
    }
  }

  Future<void> updateTeam(Team team) async {
    try {
      await _client
          .from('teams')
          .update(team.toJson())
          .eq('id', team.id);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'équipe: $e');
    }
  }

  // Méthodes pour les matchs
  Future<List<Match>> getMatches() async {
    try {
      final response = await _client
          .from('matches')
          .select()
          .order('date', ascending: true);
      
      return (response as List)
          .map((matchData) => Match.fromJson(matchData))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des matchs: $e');
    }
  }

  Future<List<Match>> getMatchesByTeam(String teamId) async {
    try {
      final response = await _client
          .from('matches')
          .select()
          .or('home_team_id.eq.$teamId,away_team_id.eq.$teamId')
          .order('date', ascending: true);
      
      return (response as List)
          .map((matchData) => Match.fromJson(matchData))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des matchs: $e');
    }
  }

  Future<List<Match>> getUpcomingMatches() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _client
          .from('matches')
          .select()
          .eq('status', 'scheduled')
          .gte('date', now)
          .order('date', ascending: true)
          .limit(10);
      
      return (response as List)
          .map((matchData) => Match.fromJson(matchData))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des prochains matchs: $e');
    }
  }

  Future<void> insertMatch(Match match) async {
    try {
      await _client.from('matches').insert(match.toJson());
    } catch (e) {
      throw Exception('Erreur lors de l\'insertion du match: $e');
    }
  }

  Future<void> updateMatch(Match match) async {
    try {
      await _client
          .from('matches')
          .update(match.toJson())
          .eq('id', match.id);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du match: $e');
    }
  }

  // Méthodes pour les profils utilisateurs
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> insertUserProfile(UserProfile profile) async {
    try {
      await _client.from('user_profiles').insert(profile.toJson());
    } catch (e) {
      throw Exception('Erreur lors de l\'insertion du profil: $e');
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _client
          .from('user_profiles')
          .update(profile.toJson())
          .eq('username', profile.username);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  // Méthodes pour les paris
  Future<List<Bet>> getUserBets(String userId) async {
    try {
      final response = await _client
          .from('bets')
          .select()
          .eq('user_id', userId)
          .order('placed_at', ascending: false);
      
      return (response as List)
          .map((betData) => Bet.fromJson(betData))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des paris: $e');
    }
  }

  Future<void> placeBet(Bet bet, String userId) async {
    try {
      final betData = bet.toJson();
      betData['user_id'] = userId;
      await _client.from('bets').insert(betData);
    } catch (e) {
      throw Exception('Erreur lors du placement du pari: $e');
    }
  }

  Future<void> updateBet(Bet bet) async {
    try {
      await _client
          .from('bets')
          .update(bet.toJson())
          .eq('id', bet.id);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du pari: $e');
    }
  }

  // Méthodes pour les classements
  Future<List<Map<String, dynamic>>> getTopBettors() async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .order('successful_bets', ascending: false)
          .limit(50);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du classement: $e');
    }
  }

  // Méthodes pour les statistiques
  Future<Map<String, dynamic>> getGlobalStats() async {
    try {
      final response = await _client
          .from('global_stats')
          .select()
          .single();
      
      return response;
    } catch (e) {
      return {
        'total_bets': 0,
        'total_pucks': 0,
        'active_users': 0,
        'top_team': '',
      };
    }
  }

  // Méthodes d'authentification
  Future<User?> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  // Méthodes pour les événements de match
  Future<List<MatchEvent>> getMatchEvents(String matchId) async {
    try {
      final response = await _client
          .from('match_events')
          .select()
          .eq('match_id', matchId)
          .order('minute', ascending: true);

      return response.map((event) => MatchEvent.fromJson({
        'id': event['id'],
        'matchId': event['match_id'],
        'type': event['type'],
        'description': event['description'],
        'playerId': event['player_id'],
        'playerName': event['player_name'],
        'teamId': event['team_id'],
        'minute': event['minute'],
        'period': event['period'],
        'timestamp': DateTime.parse(event['created_at']).millisecondsSinceEpoch,
        'details': event['details'],
      })).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des événements: $e');
    }
  }

  Future<void> insertMatchEvent(MatchEvent event) async {
    try {
      await _client.from('match_events').insert({
        'id': event.id,
        'match_id': event.matchId,
        'type': event.type,
        'description': event.description,
        'player_id': event.playerId,
        'player_name': event.playerName,
        'team_id': event.teamId,
        'minute': event.minute,
        'period': event.period,
        'details': event.details,
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'insertion de l\'événement: $e');
    }
  }

  // Méthodes pour les réactions aux événements
  Future<Map<String, List<EventReaction>>> getEventReactions(String matchId) async {
    try {
      final response = await _client
          .from('event_reactions')
          .select('*, match_events!inner(match_id)')
          .eq('match_events.match_id', matchId);

      final Map<String, List<EventReaction>> reactions = {};
      
      for (final reaction in response) {
        final eventId = reaction['event_id'];
        final eventReaction = EventReaction.fromJson({
          'id': reaction['id'],
          'eventId': eventId,
          'userId': reaction['user_id'],
          'username': reaction['username'],
          'emoji': reaction['emoji'],
          'timestamp': DateTime.parse(reaction['created_at']).millisecondsSinceEpoch,
        });
        
        if (!reactions.containsKey(eventId)) {
          reactions[eventId] = [];
        }
        reactions[eventId]!.add(eventReaction);
      }
      
      return reactions;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réactions: $e');
    }
  }

  Future<void> addEventReaction(EventReaction reaction) async {
    try {
      await _client.from('event_reactions').insert({
        'id': reaction.id,
        'event_id': reaction.eventId,
        'user_id': reaction.userId,
        'username': reaction.username,
        'emoji': reaction.emoji,
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la réaction: $e');
    }
  }

  User? get currentUser => _client.auth.currentUser;
  
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
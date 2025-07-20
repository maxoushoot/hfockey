class Team {
  final String id;
  final String name;
  final String city;
  final String arena;
  final String logoUrl;
  final int points;
  final int wins;
  final int losses;
  final int overtimeLosses;
  final int goalsFor;
  final int goalsAgainst;
  final List<String> players;
  final List<String> staff;
  final String description;

  Team({
    required this.id,
    required this.name,
    required this.city,
    required this.arena,
    required this.logoUrl,
    required this.points,
    required this.wins,
    required this.losses,
    required this.overtimeLosses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.players,
    required this.staff,
    required this.description,
  });

  int get totalGames => wins + losses + overtimeLosses;
  
  double get winPercentage => totalGames > 0 ? (wins / totalGames) * 100 : 0;
  
  int get goalDifference => goalsFor - goalsAgainst;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'city': city,
    'arena': arena,
    'logoUrl': logoUrl,
    'points': points,
    'wins': wins,
    'losses': losses,
    'overtimeLosses': overtimeLosses,
    'goalsFor': goalsFor,
    'goalsAgainst': goalsAgainst,
    'players': players,
    'staff': staff,
    'description': description,
  };

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: json['id'],
    name: json['name'],
    city: json['city'],
    arena: json['arena'],
    logoUrl: json['logoUrl'],
    points: json['points'],
    wins: json['wins'],
    losses: json['losses'],
    overtimeLosses: json['overtimeLosses'],
    goalsFor: json['goalsFor'],
    goalsAgainst: json['goalsAgainst'],
    players: List<String>.from(json['players']),
    staff: List<String>.from(json['staff']),
    description: json['description'],
  );
}
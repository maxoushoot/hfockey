class UserProfile {
  final String username;
  final String favoriteTeamId;
  final int totalPucks;
  final int successfulBets;
  final int totalBets;
  final int currentStreak;
  final int ranking;
  final String avatarUrl;
  final DateTime lastLoginDate;
  final int totalLoginDays;

  UserProfile({
    required this.username,
    required this.favoriteTeamId,
    required this.totalPucks,
    required this.successfulBets,
    required this.totalBets,
    required this.currentStreak,
    required this.ranking,
    required this.avatarUrl,
    required this.lastLoginDate,
    required this.totalLoginDays,
  });

  double get successRate => totalBets > 0 ? (successfulBets / totalBets) * 100 : 0;
  
  int get totalPucksEarned => successfulBets * 10 + totalLoginDays * 5;
  
  String get rankingTitle {
    if (ranking <= 10) return 'Légende du Hockey';
    if (ranking <= 50) return 'Pro Player';
    if (ranking <= 100) return 'Joueur Expérimenté';
    if (ranking <= 500) return 'Amateur Passionné';
    return 'Débutant';
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'favoriteTeamId': favoriteTeamId,
    'totalPucks': totalPucks,
    'successfulBets': successfulBets,
    'totalBets': totalBets,
    'currentStreak': currentStreak,
    'ranking': ranking,
    'avatarUrl': avatarUrl,
    'lastLoginDate': lastLoginDate.millisecondsSinceEpoch,
    'totalLoginDays': totalLoginDays,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    username: json['username'],
    favoriteTeamId: json['favoriteTeamId'],
    totalPucks: json['totalPucks'],
    successfulBets: json['successfulBets'],
    totalBets: json['totalBets'],
    currentStreak: json['currentStreak'],
    ranking: json['ranking'],
    avatarUrl: json['avatarUrl'],
    lastLoginDate: DateTime.fromMillisecondsSinceEpoch(json['lastLoginDate']),
    totalLoginDays: json['totalLoginDays'],
  );

  UserProfile copyWith({
    String? username,
    String? favoriteTeamId,
    int? totalPucks,
    int? successfulBets,
    int? totalBets,
    int? currentStreak,
    int? ranking,
    String? avatarUrl,
    DateTime? lastLoginDate,
    int? totalLoginDays,
  }) => UserProfile(
    username: username ?? this.username,
    favoriteTeamId: favoriteTeamId ?? this.favoriteTeamId,
    totalPucks: totalPucks ?? this.totalPucks,
    successfulBets: successfulBets ?? this.successfulBets,
    totalBets: totalBets ?? this.totalBets,
    currentStreak: currentStreak ?? this.currentStreak,
    ranking: ranking ?? this.ranking,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    lastLoginDate: lastLoginDate ?? this.lastLoginDate,
    totalLoginDays: totalLoginDays ?? this.totalLoginDays,
  );
}
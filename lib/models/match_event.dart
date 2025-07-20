class MatchEvent {
  final String id;
  final String matchId;
  final String type; // 'goal', 'penalty', 'save', 'period_start', 'period_end'
  final String description;
  final String? playerId;
  final String? playerName;
  final String? teamId;
  final int minute;
  final int? period;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  MatchEvent({
    required this.id,
    required this.matchId,
    required this.type,
    required this.description,
    this.playerId,
    this.playerName,
    this.teamId,
    required this.minute,
    this.period,
    required this.timestamp,
    this.details,
  });

  String get eventIcon {
    switch (type) {
      case 'goal':
        return '🥅';
      case 'penalty':
        return '⚠️';
      case 'save':
        return '🛡️';
      case 'period_start':
        return '▶️';
      case 'period_end':
        return '⏸️';
      case 'timeout':
        return '⏱️';
      case 'substitution':
        return '🔄';
      default:
        return '🏒';
    }
  }

  String get eventLabel {
    switch (type) {
      case 'goal':
        return 'But';
      case 'penalty':
        return 'Pénalité';
      case 'save':
        return 'Arrêt';
      case 'period_start':
        return 'Début de période';
      case 'period_end':
        return 'Fin de période';
      case 'timeout':
        return 'Temps mort';
      case 'substitution':
        return 'Changement';
      default:
        return 'Événement';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'matchId': matchId,
    'type': type,
    'description': description,
    'playerId': playerId,
    'playerName': playerName,
    'teamId': teamId,
    'minute': minute,
    'period': period,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'details': details,
  };

  factory MatchEvent.fromJson(Map<String, dynamic> json) => MatchEvent(
    id: json['id'],
    matchId: json['matchId'],
    type: json['type'],
    description: json['description'],
    playerId: json['playerId'],
    playerName: json['playerName'],
    teamId: json['teamId'],
    minute: json['minute'],
    period: json['period'],
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    details: json['details'],
  );

  MatchEvent copyWith({
    String? id,
    String? matchId,
    String? type,
    String? description,
    String? playerId,
    String? playerName,
    String? teamId,
    int? minute,
    int? period,
    DateTime? timestamp,
    Map<String, dynamic>? details,
  }) => MatchEvent(
    id: id ?? this.id,
    matchId: matchId ?? this.matchId,
    type: type ?? this.type,
    description: description ?? this.description,
    playerId: playerId ?? this.playerId,
    playerName: playerName ?? this.playerName,
    teamId: teamId ?? this.teamId,
    minute: minute ?? this.minute,
    period: period ?? this.period,
    timestamp: timestamp ?? this.timestamp,
    details: details ?? this.details,
  );
}
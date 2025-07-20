class Match {
  final String id;
  final String homeTeamId;
  final String awayTeamId;
  final DateTime date;
  final String status; // scheduled, live, finished
  final int? homeScore;
  final int? awayScore;
  final String venue;
  final int? period;
  final String? timeRemaining;
  final bool isPlayoffs;
  final int attendance;

  Match({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.date,
    required this.status,
    this.homeScore,
    this.awayScore,
    required this.venue,
    this.period,
    this.timeRemaining,
    this.isPlayoffs = false,
    this.attendance = 0,
  });

  bool get isFinished => status == 'finished';
  bool get isLive => status == 'live';
  bool get isScheduled => status == 'scheduled';
  
  String get result {
    if (!isFinished) return '';
    if (homeScore == null || awayScore == null) return '';
    return '$homeScore - $awayScore';
  }

  String? get winner {
    if (!isFinished || homeScore == null || awayScore == null) return null;
    if (homeScore! > awayScore!) return homeTeamId;
    if (awayScore! > homeScore!) return awayTeamId;
    return null; // Draw (shouldn't happen in hockey)
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'homeTeamId': homeTeamId,
    'awayTeamId': awayTeamId,
    'date': date.millisecondsSinceEpoch,
    'status': status,
    'homeScore': homeScore,
    'awayScore': awayScore,
    'venue': venue,
    'period': period,
    'timeRemaining': timeRemaining,
    'isPlayoffs': isPlayoffs,
    'attendance': attendance,
  };

  factory Match.fromJson(Map<String, dynamic> json) => Match(
    id: json['id'],
    homeTeamId: json['homeTeamId'],
    awayTeamId: json['awayTeamId'],
    date: DateTime.fromMillisecondsSinceEpoch(json['date']),
    status: json['status'],
    homeScore: json['homeScore'],
    awayScore: json['awayScore'],
    venue: json['venue'],
    period: json['period'],
    timeRemaining: json['timeRemaining'],
    isPlayoffs: json['isPlayoffs'] ?? false,
    attendance: json['attendance'] ?? 0,
  );
}
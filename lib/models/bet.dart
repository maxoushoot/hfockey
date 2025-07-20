class Bet {
  final String id;
  final String matchId;
  final String prediction; // 'home', 'away', 'draw'
  final int pucksWagered;
  final String status; // 'pending', 'won', 'lost'
  final DateTime placedAt;
  final int? pucksWon;
  final double odds;

  Bet({
    required this.id,
    required this.matchId,
    required this.prediction,
    required this.pucksWagered,
    required this.status,
    required this.placedAt,
    this.pucksWon,
    required this.odds,
  });

  bool get isPending => status == 'pending';
  bool get isWon => status == 'won';
  bool get isLost => status == 'lost';

  int get potentialWin => (pucksWagered * odds).round();

  String get predictionText {
    switch (prediction) {
      case 'home':
        return 'Victoire Domicile';
      case 'away':
        return 'Victoire Extérieur';
      case 'draw':
        return 'Match Nul';
      default:
        return 'Inconnu';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'matchId': matchId,
    'prediction': prediction,
    'pucksWagered': pucksWagered,
    'status': status,
    'placedAt': placedAt.millisecondsSinceEpoch,
    'pucksWon': pucksWon,
    'odds': odds,
  };

  factory Bet.fromJson(Map<String, dynamic> json) => Bet(
    id: json['id'],
    matchId: json['matchId'],
    prediction: json['prediction'],
    pucksWagered: json['pucksWagered'],
    status: json['status'],
    placedAt: DateTime.fromMillisecondsSinceEpoch(json['placedAt']),
    pucksWon: json['pucksWon'],
    odds: json['odds'].toDouble(),
  );

  Bet copyWith({
    String? id,
    String? matchId,
    String? prediction,
    int? pucksWagered,
    String? status,
    DateTime? placedAt,
    int? pucksWon,
    double? odds,
  }) => Bet(
    id: id ?? this.id,
    matchId: matchId ?? this.matchId,
    prediction: prediction ?? this.prediction,
    pucksWagered: pucksWagered ?? this.pucksWagered,
    status: status ?? this.status,
    placedAt: placedAt ?? this.placedAt,
    pucksWon: pucksWon ?? this.pucksWon,
    odds: odds ?? this.odds,
  );
}
class EventReaction {
  final String id;
  final String eventId;
  final String userId;
  final String username;
  final String emoji;
  final DateTime timestamp;

  EventReaction({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.username,
    required this.emoji,
    required this.timestamp,
  });

  static const List<String> availableEmojis = [
    '🔥', // Impressionnant
    '💪', // Fort
    '😱', // Choquant
    '👏', // Applaudissements
    '⚡', // Rapide
    '🎯', // Précis
    '😍', // Adorable
    '🤩', // Émerveillé
    '🙌', // Célébration
    '👀', // Intéressant
    '💯', // Parfait
    '🚀', // Explosif
    '⭐', // Étoile
    '🎉', // Fête
    '❤️', // Amour
  ];

  static String getEmojiName(String emoji) {
    switch (emoji) {
      case '🔥':
        return 'Impressionnant';
      case '💪':
        return 'Fort';
      case '😱':
        return 'Choquant';
      case '👏':
        return 'Applaudissements';
      case '⚡':
        return 'Rapide';
      case '🎯':
        return 'Précis';
      case '😍':
        return 'Adorable';
      case '🤩':
        return 'Émerveillé';
      case '🙌':
        return 'Célébration';
      case '👀':
        return 'Intéressant';
      case '💯':
        return 'Parfait';
      case '🚀':
        return 'Explosif';
      case '⭐':
        return 'Étoile';
      case '🎉':
        return 'Fête';
      case '❤️':
        return 'Amour';
      default:
        return emoji;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'eventId': eventId,
    'userId': userId,
    'username': username,
    'emoji': emoji,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };

  factory EventReaction.fromJson(Map<String, dynamic> json) => EventReaction(
    id: json['id'],
    eventId: json['eventId'],
    userId: json['userId'],
    username: json['username'],
    emoji: json['emoji'],
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
  );

  EventReaction copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? username,
    String? emoji,
    DateTime? timestamp,
  }) => EventReaction(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    userId: userId ?? this.userId,
    username: username ?? this.username,
    emoji: emoji ?? this.emoji,
    timestamp: timestamp ?? this.timestamp,
  );
}
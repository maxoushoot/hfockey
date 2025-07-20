import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../models/match_event.dart';
import '../models/event_reaction.dart';
import '../services/hybrid_data_service.dart';
import '../theme.dart';


class MatchSheetPage extends StatefulWidget {
  final Match match;
  final Team homeTeam;
  final Team awayTeam;

  const MatchSheetPage({
    super.key,
    required this.match,
    required this.homeTeam,
    required this.awayTeam,
  });

  @override
  State<MatchSheetPage> createState() => _MatchSheetPageState();
}

class _MatchSheetPageState extends State<MatchSheetPage> {
  final HybridDataService _dataService = HybridDataService();
  List<MatchEvent> _events = [];
  Map<String, List<EventReaction>> _eventReactions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatchData();
  }

  Future<void> _loadMatchData() async {
    setState(() => _isLoading = true);
    
    try {
      final events = await _dataService.getMatchEvents(widget.match.id);
      final reactions = await _dataService.getEventReactions(widget.match.id);
      
      setState(() {
        _events = events;
        _eventReactions = reactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Feuille de match',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMatchData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildMatchHeader()),
                  SliverToBoxAdapter(child: _buildMatchInfo()),
                  SliverToBoxAdapter(child: _buildScoreSection()),
                  if (_events.isNotEmpty) ...[
                    SliverToBoxAdapter(child: _buildEventsHeader()),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildEventCard(_events[index]),
                        childCount: _events.length,
                      ),
                    ),
                  ] else
                    SliverToBoxAdapter(child: _buildNoEvents()),
                ],
              ),
            ),
    );
  }

  Widget _buildMatchHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.lightGray,
                      backgroundImage: NetworkImage(
                        "https://pixabay.com/get/g190548ac5e6aaf0e4de5e87dd2fbdca648d2a6c99126f1876dfba8e0d3622aa91ed9d53f6f0787c8f2a77751a37020a3757de8201006f1bdd45caec6bc03c3d4_1280.png",
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.homeTeam.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      widget.homeTeam.city,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor()),
                ),
                child: Text(
                  _getStatusText(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.lightGray,
                      backgroundImage: NetworkImage(
                        "https://pixabay.com/get/g1c34cc77b9e01f346784f87fa895ab786262424a00fc373da63e6774695079efab792febcfc861734b64c3e7d3d895265e2233d05650ad2a0291e6f0508608a2_1280.png",
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.awayTeam.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      widget.awayTeam.city,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 20, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(widget.match.date),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 20, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                DateFormat('HH:mm').format(widget.match.date),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                widget.match.venue,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          if (widget.match.isLive && widget.match.period != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.sports_hockey, size: 20, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  '${widget.match.period}e période',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (widget.match.timeRemaining != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    widget.match.timeRemaining!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                widget.homeTeam.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.match.homeScore?.toString() ?? '-',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'VS',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Column(
            children: [
              Text(
                widget.awayTeam.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.match.awayScore?.toString() ?? '-',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventsHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.timeline,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Événements du match',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '${_events.length} événements',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(MatchEvent event) {
    final reactions = _eventReactions[event.id] ?? [];
    final isHomeTeam = event.teamId == widget.homeTeam.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isHomeTeam 
                          ? AppColors.primaryBlue.withOpacity(0.1)
                          : AppColors.lightBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.eventIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              event.eventLabel,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${event.minute}\'',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (event.playerName != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: AppColors.gray),
                              const SizedBox(width: 4),
                              Text(
                                event.playerName!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildReactionSection(event, reactions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReactionSection(MatchEvent event, List<EventReaction> reactions) {
    final reactionCounts = <String, int>{};
    for (final reaction in reactions) {
      reactionCounts[reaction.emoji] = (reactionCounts[reaction.emoji] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Existing reactions
        if (reactionCounts.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: reactionCounts.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(entry.key, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      entry.value.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
        // Add reaction button
        if (widget.match.isLive || widget.match.isFinished) ...[
          GestureDetector(
            onTap: () => _showReactionPicker(event),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryBlue),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_reaction, size: 16, color: AppColors.primaryBlue),
                  const SizedBox(width: 4),
                  Text(
                    'Réagir',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNoEvents() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.timeline_outlined,
            size: 64,
            color: AppColors.gray,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun événement',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.match.isScheduled 
                ? 'Les événements apparaîtront une fois le match commencé'
                : 'Aucun événement enregistré pour ce match',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.gray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showReactionPicker(MatchEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Réagir à l\'événement',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${event.eventIcon} ${event.eventLabel} - ${event.description}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: EventReaction.availableEmojis.map((emoji) {
                return GestureDetector(
                  onTap: () => _addReaction(event, emoji),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _addReaction(MatchEvent event, String emoji) async {
    Navigator.pop(context);
    
    try {
      await _dataService.addEventReaction(event.id, emoji);
      await _loadMatchData(); // Refresh reactions
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Réaction $emoji ajoutée !'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout de la réaction: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _getStatusColor() {
    switch (widget.match.status) {
      case 'live':
        return AppColors.error;
      case 'finished':
        return AppColors.success;
      default:
        return AppColors.warning;
    }
  }

  String _getStatusText() {
    switch (widget.match.status) {
      case 'live':
        return 'EN DIRECT';
      case 'finished':
        return 'TERMINÉ';
      default:
        return 'PROGRAMMÉ';
    }
  }
}
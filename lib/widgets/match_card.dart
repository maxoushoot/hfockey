import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../theme.dart';
import '../pages/match_sheet_page.dart';

class MatchCard extends StatelessWidget {
  final Match match;
  final Team homeTeam;
  final Team awayTeam;
  final VoidCallback? onTap;

  const MatchCard({
    super.key,
    required this.match,
    required this.homeTeam,
    required this.awayTeam,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM');
    final timeFormat = DateFormat('HH:mm');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.lightBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap ?? () => _navigateToMatchSheet(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Match status and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusChip(context),
                  Text(
                    '${dateFormat.format(match.date)} • ${timeFormat.format(match.date)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Teams and score
              Row(
                children: [
                  // Home team
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            Icons.sports_hockey,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          homeTeam.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Score or VS
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getScoreBackgroundColor(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: match.isFinished 
                      ? Text(
                          '${match.homeScore} - ${match.awayScore}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : match.isLive
                        ? Column(
                            children: [
                              Text(
                                '${match.homeScore} - ${match.awayScore}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'P${match.period} • ${match.timeRemaining}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'VS',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  
                  // Away team
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            Icons.sports_hockey,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          awayTeam.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Venue
              if (match.venue.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      match.venue,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;
    
    switch (match.status) {
      case 'live':
        backgroundColor = AppColors.error;
        textColor = AppColors.white;
        text = '🔴 EN DIRECT';
        break;
      case 'finished':
        backgroundColor = AppColors.lightBlue.withValues(alpha: 0.2);
        textColor = AppColors.darkGray;
        text = 'TERMINÉ';
        break;
      default:
        backgroundColor = AppColors.primaryBlue.withValues(alpha: 0.1);
        textColor = AppColors.primaryBlue;
        text = 'À VENIR';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getScoreBackgroundColor(BuildContext context) {
    if (match.isLive) return Colors.red;
    if (match.isFinished) return Theme.of(context).colorScheme.outline;
    return Theme.of(context).colorScheme.primary;
  }

  void _navigateToMatchSheet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchSheetPage(
          match: match,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
        ),
      ),
    );
  }
}
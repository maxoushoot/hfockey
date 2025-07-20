import 'package:flutter/material.dart';
import '../theme.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Adaptation responsive pour différentes tailles d'écran
            final isSmallScreen = constraints.maxWidth < 360;
            final itemPadding = isSmallScreen ? 8.0 : 16.0;
            final containerHeight = isSmallScreen ? 65.0 : 70.0;
            
            return Container(
              height: containerHeight,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                _buildNavItem(
                  context,
                  Icons.home_outlined,
                  Icons.home,
                  'Accueil',
                  0,
                  isSmallScreen,
                ),
                _buildNavItem(
                  context,
                  Icons.calendar_today_outlined,
                  Icons.calendar_today,
                  'Calendrier',
                  1,
                  isSmallScreen,
                ),
                _buildNavItem(
                  context,
                  Icons.trending_up_outlined,
                  Icons.trending_up,
                  'Tendances',
                  2,
                  isSmallScreen,
                ),
                _buildNavItem(
                  context,
                  Icons.leaderboard_outlined,
                  Icons.leaderboard,
                  'Classement',
                  3,
                  isSmallScreen,
                ),
                _buildNavItem(
                  context,
                  Icons.person_outline,
                  Icons.person,
                  'Profil',
                  4,
                  isSmallScreen,
                ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
    bool isSmallScreen,
  ) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12, 
          vertical: isSmallScreen ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primaryBlue : AppColors.gray,
              size: isSmallScreen ? 20 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? AppColors.primaryBlue : AppColors.gray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: isSmallScreen ? 9 : 10,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
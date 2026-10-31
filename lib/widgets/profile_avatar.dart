import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final String fullName;
  final double radius;
  final bool hasGlow;
  final bool showBadge;
  final Color? badgeColor;
  final IconData? badgeIcon;

  const ProfileAvatar({
    Key? key,
    required this.imageUrl,
    required this.fullName,
    this.radius = 28.0,
    this.hasGlow = false,
    this.showBadge = false,
    this.badgeColor,
    this.badgeIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String initials = fullName.isNotEmpty
        ? fullName.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
        : '?';

    Widget avatarCore;
    if (imageUrl.isNotEmpty) {
      avatarCore = CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl),
      );
    } else {
      avatarCore = CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary.withOpacity(0.15),
        child: Text(
          initials,
          style: TextStyle(
            fontSize: radius * 0.7,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      );
    }

    Widget child = avatarCore;

    if (hasGlow) {
      child = Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: avatarCore,
      );
    }

    if (showBadge) {
      return Stack(
        children: [
          child,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor ?? AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: Icon(
                badgeIcon ?? Icons.verified_user_rounded,
                size: radius * 0.45,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    return child;
  }
}

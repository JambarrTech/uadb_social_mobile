import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const String interFont = 'Inter';
  static const String figtreeFont = 'Figtree';
  static const String spaceGroteskFont = 'SpaceGrotesk';
  static const String jetbrainsMonoFont = 'JetBrainsMono';

  static const TextStyle splashTagline = TextStyle(
    fontFamily: interFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.lightBlueText,
  );

  static const TextStyle onboardingTitle = TextStyle(
    fontFamily: interFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlue,
    height: 1.3,
  );

  static const TextStyle onboardingTitleLarge = TextStyle(
    fontFamily: interFont,
    fontSize: 25,
    fontWeight: FontWeight.w700,
    color: AppColors.darkBlue,
    height: 1.2,
  );

  static const TextStyle onboardingSubtitle = TextStyle(
    fontFamily: interFont,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
    height: 1.4,
  );

  static const TextStyle registerTitle = TextStyle(
    fontFamily: interFont,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.darkBlue,
    height: 1.2,
  );

  static const TextStyle registerSubtitle = TextStyle(
    fontFamily: interFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: 1.4,
  );

  static const TextStyle loginWelcome = TextStyle(
    fontFamily: interFont,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.darkBlue,
    height: 1.2,
  );

  static const TextStyle loginSubtitle = TextStyle(
    fontFamily: interFont,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: 1.4,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontFamily: interFont,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  static const TextStyle fieldPlaceholder = TextStyle(
    fontFamily: interFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: interFont,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle buttonPrimaryLarge = TextStyle(
    fontFamily: interFont,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: interFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.green,
  );

  static const TextStyle linkText = TextStyle(
    fontFamily: interFont,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.linkBlue,
  );

  static const TextStyle linkTextMuted = TextStyle(
    fontFamily: interFont,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  static const TextStyle forgotPasswordTitle = TextStyle(
    fontFamily: interFont,
    fontSize: 25,
    fontWeight: FontWeight.w600,
    color: AppColors.darkBlue,
  );

  static const TextStyle forgotPasswordSubtitle = TextStyle(
    fontFamily: interFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: 1.4,
  );

  static const TextStyle postAuthorName = TextStyle(
    fontFamily: spaceGroteskFont,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle postAuthorRole = TextStyle(
    fontFamily: figtreeFont,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
  );

  static const TextStyle postTime = TextStyle(
    fontFamily: figtreeFont,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle postContent = TextStyle(
    fontFamily: figtreeFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.4,
  );

  static const TextStyle interactionCount = TextStyle(
    fontFamily: jetbrainsMonoFont,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textMedium,
  );

  static const TextStyle createPostHint = TextStyle(
    fontFamily: figtreeFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle createPostLabel = TextStyle(
    fontFamily: figtreeFont,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMedium,
  );

  static const TextStyle createPostTitle = TextStyle(
    fontFamily: spaceGroteskFont,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle explorerSectionTitle = TextStyle(
    fontFamily: spaceGroteskFont,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.green,
  );

  static const TextStyle explorerCardTitle = TextStyle(
    fontFamily: spaceGroteskFont,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle explorerCardSubtitle = TextStyle(
    fontFamily: figtreeFont,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle explorerCardContent = TextStyle(
    fontFamily: figtreeFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
  );

  static const TextStyle suggestedPersonName = TextStyle(
    fontFamily: spaceGroteskFont,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle suggestedPersonRole = TextStyle(
    fontFamily: figtreeFont,
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle communityName = TextStyle(
    fontFamily: spaceGroteskFont,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle communityDesc = TextStyle(
    fontFamily: figtreeFont,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
  );

  static const TextStyle communityMembers = TextStyle(
    fontFamily: jetbrainsMonoFont,
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: AppColors.orangeRed,
  );

  static const TextStyle eventDay = TextStyle(
    fontFamily: spaceGroteskFont,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.orangeRed,
  );

  static const TextStyle eventDate = TextStyle(
    fontFamily: spaceGroteskFont,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.orangeRed,
  );

  static const TextStyle eventTitle = TextStyle(
    fontFamily: spaceGroteskFont,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle eventLocation = TextStyle(
    fontFamily: figtreeFont,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
  );

  static const TextStyle bottomNavLabelActive = TextStyle(
    fontFamily: figtreeFont,
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle bottomNavLabelInactive = TextStyle(
    fontFamily: figtreeFont,
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle badgeText = TextStyle(
    fontFamily: jetbrainsMonoFont,
    fontSize: 8,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle officialBadge = TextStyle(
    fontFamily: jetbrainsMonoFont,
    fontSize: 8,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle headerTitle = TextStyle(
    fontFamily: interFont,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.darkBlue,
  );

  static const TextStyle statusBarTime = TextStyle(
    fontFamily: figtreeFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );
}
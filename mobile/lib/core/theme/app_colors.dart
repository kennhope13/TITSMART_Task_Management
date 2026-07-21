import 'package:flutter/material.dart';

/// System color tokens matching TITSMART Industrial Brand Identity
class AppColors {
  // Brand Primary & Secondary
  static const Color primary = Color(0xFF00236F);
  static const Color primaryContainer = Color(0xFF1E3A8A);
  static const Color primaryFixedDim = Color(0xFFB6C4FF);
  static const Color onPrimary = Colors.white;

  static const Color secondary = Color(0xFF006A61);
  static const Color secondaryContainer = Color(0xFF86F2E4);
  static const Color onSecondaryContainer = Color(0xFF006F66);

  // Neutral Background & Surface
  static const Color background = Color(0xFFFAF8FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFEEEDF4);
  static const Color surfaceContainerLow = Color(0xFFF4F3FA);
  static const Color surfaceContainerHigh = Color(0xFFE9E7EF);
  static const Color surfaceContainerHighest = Color(0xFFE3E1E9);

  // Text & Border Colors
  static const Color onSurface = Color(0xFF1A1B21);
  static const Color onSurfaceVariant = Color(0xFF444651);
  static const Color outline = Color(0xFF757682);
  static const Color outlineVariant = Color(0xFFC5C5D3);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // Exact Status Colors specified in requirements:
  // - Chờ giao: Grey (#757682)
  // - Đã giao: Blue (#00236F / #1E3A8A)
  // - Đang làm: Orange (#F39461)
  // - Chờ duyệt: Purple (#7E22CE)
  // - Hoàn thành: Green (#059669)
  // - Cần sửa: Red (#BA1A1A)
  // - Hủy: Dark Grey (#2F3036)

  static const Color statusPendingBg = Color(0xFFE3E1E9);
  static const Color statusPendingFg = Color(0xFF757682);

  static const Color statusAssignedBg = Color(0xFFDCE1FF);
  static const Color statusAssignedFg = Color(0xFF00236F);

  static const Color statusInProgressBg = Color(0xFFFFDBCB);
  static const Color statusInProgressFg = Color(0xFFF39461);

  static const Color statusApprovalBg = Color(0xFFF3E8FF);
  static const Color statusApprovalFg = Color(0xFF7E22CE);

  static const Color statusCompletedBg = Color(0xD1D1FAE5);
  static const Color statusCompletedFg = Color(0xFF059669);

  static const Color statusRevisionBg = Color(0xFFFFDAD6);
  static const Color statusRevisionFg = Color(0xFFBA1A1A);

  static const Color statusCancelledBg = Color(0xFFE3E1E9);
  static const Color statusCancelledFg = Color(0xFF2F3036);

  /// Helper to return background color based on status string
  static Color getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'chờ giao':
        return statusPendingBg;
      case 'assigned_worker':
      case 'đã giao':
      case 'chờ làm':
        return statusAssignedBg;
      case 'in_progress':
      case 'đang làm':
        return statusInProgressBg;
      case 'pending_approval':
      case 'chờ duyệt':
        return statusApprovalBg;
      case 'completed':
      case 'hoàn thành':
        return statusCompletedBg;
      case 'needs_revision':
      case 'cần sửa':
        return statusRevisionBg;
      case 'cancelled':
      case 'hủy':
        return statusCancelledBg;
      default:
        return statusPendingBg;
    }
  }

  /// Helper to return foreground/accent color based on status string
  static Color getStatusFg(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'chờ giao':
        return statusPendingFg;
      case 'assigned_worker':
      case 'đã giao':
      case 'chờ làm':
        return statusAssignedFg;
      case 'in_progress':
      case 'đang làm':
        return statusInProgressFg;
      case 'pending_approval':
      case 'chờ duyệt':
        return statusApprovalFg;
      case 'completed':
      case 'hoàn thành':
        return statusCompletedFg;
      case 'needs_revision':
      case 'cần sửa':
        return statusRevisionFg;
      case 'cancelled':
      case 'hủy':
        return statusCancelledFg;
      default:
        return statusPendingFg;
    }
  }

  /// Helper to translate backend status string to Vietnamese UI label
  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'CHỜ GIAO';
      case 'assigned_worker':
        return 'ĐÃ GIAO';
      case 'in_progress':
        return 'ĐANG LÀM';
      case 'pending_approval':
        return 'CHỜ DUYỆT';
      case 'completed':
        return 'HOÀN THÀNH';
      case 'needs_revision':
        return 'CẦN SỬA';
      case 'cancelled':
        return 'ĐÃ HỦY';
      default:
        return status.toUpperCase();
    }
  }
}

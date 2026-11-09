class AppConstants {
  static const String appName = 'CleanSpot';
  static const String appTagline = 'Cleaner Toilets, Healthier Communities';
  static const String appVersion = '1.0.0';

  // Storage
  static const String toiletPhotosBucket = 'toilet-photos';

  // Complaint Categories
  static const List<String> issueCategories = [
    'Dirty Surfaces',
    'Bad Odour',
    'Lack of Water',
    'Lack of Soap',
    'Overflowing Bins',
    'Damaged Facilities',
    'Poor Accessibility',
    'Other',
  ];

  // Complaint Statuses
  static const String statusPending = 'pending';
  static const String statusInProgress = 'in_progress';
  static const String statusResolved = 'resolved';
  static const String statusRejected = 'rejected';

  // User Roles
  static const String roleCitizen = 'citizen';
  static const String roleAdmin = 'admin';

  // SDG 6 Metadata
  static const String sdg6Title = 'UN SDG 6: Clean Water & Sanitation';
  static const String sdg6Subtitle =
      'Ensuring availability and sustainable management of sanitation for everyone.';
  static const String sdg6Description =
      'Target 6.2 aims to achieve access to adequate and equitable sanitation and hygiene for all. '
      'CleanSpot empowers community-driven inspection, real-time maintenance accountability, '
      'and open hygiene metrics for public dignity.';

  // Status Display Helpers
  static String formatStatus(String status) {
    switch (status.toLowerCase()) {
      case statusPending:
        return 'Pending';
      case statusInProgress:
        return 'In Progress';
      case statusResolved:
        return 'Resolved';
      case statusRejected:
        return 'Rejected';
      default:
        return status;
    }
  }
}

/// Resolution outcome types for emergencies
enum ResolutionOutcome {
  admitted,    // Patient admitted to facility
  referred,     // Patient referred to another facility
  stabilized,   // Patient stabilized and discharged
  deceased,     // Patient deceased (critical for healthcare records)
}

/// Extension to convert to/from string
extension ResolutionOutcomeExtension on ResolutionOutcome {
  String get displayName {
    switch (this) {
      case ResolutionOutcome.admitted:
        return 'Admitted';
      case ResolutionOutcome.referred:
        return 'Referred';
      case ResolutionOutcome.stabilized:
        return 'Stabilized';
      case ResolutionOutcome.deceased:
        return 'Deceased';
    }
  }

  String get value => toString().split('.').last;

  static ResolutionOutcome? fromString(String value) {
    try {
      return ResolutionOutcome.values.firstWhere(
        (e) => e.value == value,
      );
    } catch (e) {
      return null;
    }
  }
}


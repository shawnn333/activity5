enum NetworkHealthTier { excellent, fair, poor, degraded }

extension NetworkHealthTierX on NetworkHealthTier {
  String get label {
    switch (this) {
      case NetworkHealthTier.excellent:
        return 'Excellent';
      case NetworkHealthTier.fair:
        return 'Fair';
      case NetworkHealthTier.poor:
        return 'Poor';
      case NetworkHealthTier.degraded:
        return 'Degraded';
    }
  }

  String get description {
    switch (this) {
      case NetworkHealthTier.excellent:
        return 'Fast and stable. Full-quality media is safe to load.';
      case NetworkHealthTier.fair:
        return 'Usable but inconsistent. Standard-quality media recommended.';
      case NetworkHealthTier.poor:
        return 'Slow connection. Switching to lightweight placeholders.';
      case NetworkHealthTier.degraded:
        return 'Heavy packet loss or timeouts. Minimizing data usage.';
    }
  }
}

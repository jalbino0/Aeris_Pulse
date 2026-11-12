class AirQualityReading {
  final String location;
  final String referenceTime;
  final double? pm25;
  final double? pm10;
  final double? ozone;

  const AirQualityReading({
    required this.location,
    required this.referenceTime,
    required this.pm25,
    required this.pm10,
    required this.ozone,
  });

  String get formattedTime {
    final date = DateTime.tryParse(referenceTime);

    if (date == null) {
      return referenceTime;
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month às $hour:$minute';
  }
}

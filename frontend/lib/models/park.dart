class Park {
  final String id;
  final String title;
  final String city;

  final String? address;
  final String? description;

  final double? lat;
  final double? lon;

  final double? hourlyPrice;
  final int? capacity;
  final int? available;


  final double? distanceKm;

  Park({
    required this.id,
    required this.title,
    required this.city,
    this.address,
    this.description,
    this.lat,
    this.lon,
    this.hourlyPrice,
    this.capacity,
    this.available,
    this.distanceKm,
  });

  factory Park.fromJson(Map<String, dynamic> j) {
    double? _d(dynamic v) => v == null ? null : (v as num?)?.toDouble();
    int? _i(dynamic v) => v == null ? null : (v as num?)?.toInt();

    return Park(
      id: (j['id'] ?? '').toString(),
      title: (j['title'] ?? j['park_title'] ?? 'Park').toString(),
      city: (j['city'] ?? j['park_city'] ?? '').toString(),
      address: (j['address'] ?? '').toString().isEmpty ? null : (j['address'] ?? '').toString(),
      description: (j['description'] ?? '').toString().isEmpty ? null : (j['description'] ?? '').toString(),
      lat: _d(j['lat']),
      lon: _d(j['lon']),
      hourlyPrice: _d(j['hourly_price']),
      capacity: _i(j['capacity']),
      available: _i(j['available']),
      distanceKm: _d(j['distance_km']),
    );
  }

  bool get hasLocation => lat != null && lon != null;
}

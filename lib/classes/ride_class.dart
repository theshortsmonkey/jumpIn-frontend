enum SeatsLabel {
  one('1', 1),
  two('2', 2),
  three('3', 3),
  four('4', 4),
  five('5', 5),
  six('6', 6),
  seven('7', 7),
  eight('8', 8);

  final String label;
  final int seats;
  
  const SeatsLabel(this.label, this.seats);

  factory SeatsLabel.fromInt(int seats) {
    return values.firstWhere((e) => e.seats == seats);
  }
}

enum RegionsLabel {
  one('North West', 'North West'),
  two('North East', 'North East'),
  three('Yorkshire', 'Yorkshire'),
  four('Midlands', 'Midlands'),
  five('South', 'South'),
  six('Scotland', 'Scotland');

  final String label;
  final String region;

  const RegionsLabel(this.label, this.region);

  factory RegionsLabel.fromString(String region) {
    return values.firstWhere((e) => e.region == region);
  }
}

class Ride {
  final String? id;
  final String? to;
  final RegionsLabel? toRegion;
  final String? from;
  final RegionsLabel? fromRegion;
  final String driverUsername;
  final List<dynamic> riderUsernames;
  final List<dynamic> jumpInRequests;
  final SeatsLabel? postAvailableSeats;
  final int getAvailableSeats;
  final int? carbonEmissions;
  final int? distance;
  final int price;
  final dynamic map;
  final DateTime? setDateTime; 
  final String getDateTime;
  final dynamic chats;
  final int? driverRating;

  Ride({
    this.id,
    this.to,
    this.toRegion,
    this.from,
    this.fromRegion,
    this.driverUsername = '',
    this.driverRating,
    this.riderUsernames = const [],
    this.jumpInRequests = const [],
    this.postAvailableSeats,
    this.getAvailableSeats = 0,
    this.carbonEmissions,
    this.distance,
    this.price = 0,
    this.map = const {},
    this.setDateTime,
    this.getDateTime = '2024-01-01T00:00:01.000Z',
    this.chats = const [],
  });

  Map<String, dynamic> toJson() => {
        "to" : to,
        "to_region": toRegion?.region,
        "from" : from,
        'from_region': fromRegion?.region,
        "driver_username" : driverUsername,
        "rider_usernames": riderUsernames,
        "jumpin_requests": jumpInRequests,
        "available_seats": postAvailableSeats?.seats,
        "carbon_emissions": carbonEmissions,
        "distance": distance,
        "price": price,
        "map": map,
        "date_and_time": setDateTime?.toIso8601String(),
        "chats": chats
      };
  
  factory Ride.fromJson(Map<String, dynamic> json) {
    RegionsLabel getToRegion = RegionsLabel.fromString(json['to_region'] as String);
    RegionsLabel getFromRegion = RegionsLabel.fromString(json['from_region'] as String);
    return Ride( 
      id: json['id'] as String,
      driverUsername: json['driver_username'] as String,
      to: json['to'] as String,
      toRegion: getToRegion,
      from: json['from'] as String,
      fromRegion: getFromRegion,
      riderUsernames: json['rider_usernames'] as List<dynamic>,
      jumpInRequests: json['jumpin_requests'] as List<dynamic>,
      carbonEmissions: json['carbon_emissions'] as int,
      distance: json['distance'] as int,
      price: json['price'] as int,
      driverRating: json['driver_rating'] as int,
      getDateTime: json['date_and_time'] as String,
      getAvailableSeats: json['available_seats'] as int,
      map: json['map'] as Map<String, dynamic>,
      chats: json['chats'] as List<dynamic>
    );
  }
  static List<Ride> fromJsonList(List<Map<String, dynamic>> jsonList) { 
  return jsonList.map<Ride>((json) => Ride.fromJson(json)).toList(); 
  }
}
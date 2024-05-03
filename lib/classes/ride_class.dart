enum SeatsLabel {
  one('1', 1),
  two('2', 2),
  three('3', 3),
  four('4', 4),
  five('5', 5);

  const SeatsLabel(this.label, this.seats);
  final String label;
  final int seats;
}

enum RegionsLabel {
  one('North West', 'North West'),
  two('North East', 'North East'),
  three('Yorkshire', 'Yorkshire'),
  four('Midlands', 'Midlands'),
  five('South', 'South');

  const RegionsLabel(this.label, this.region);
  final String label;
  final String region;
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
  final String? getDateTime;
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
    this.map,
    this.setDateTime,
    this.getDateTime,
    this.chats = const [],
  });

  Map<String, dynamic> toJson() => {
        "to" : to,
        "to_region": toRegion?.region,
        "from" : from,
        'from_region': fromRegion?.region,
        "driver_username" : driverUsername,
        "rider_usernames": riderUsernames,
        "available_seats": postAvailableSeats?.seats,
        "carbon_emissions": carbonEmissions,
        "distance": distance,
        "price": price,
        "map": map,
        "date_and_time": setDateTime?.toIso8601String(),
        "chats": chats
      };
  
  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride( 
      id: json['id'] as String,
      driverUsername: json['driver_username'] as String,
      to: json['to'] as String,
      from: json['from'] as String,
      riderUsernames: json['rider_usernames'] as List<dynamic>,
      jumpInRequests: json['jumpin_requests'] as List<dynamic>,
      carbonEmissions: json['carbon_emissions'] as int,
      distance: json['distance'] as int,
      price: json['price'] as int,
      driverRating: json['driver_rating'] as int,
      getDateTime: json['date_and_time'] as String,
      getAvailableSeats: json['available_seats'] as int,
    );
  }
  static List<Ride> fromJsonList(List<Map<String, dynamic>> jsonList) { 
  return jsonList.map<Ride>((json) => Ride.fromJson(json)).toList(); 
  }
}
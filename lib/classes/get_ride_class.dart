class Ride { 
  final String? id;
  final String? driverUsername;
  final String? to;
  final String? from;
  final List<dynamic>? riderUsernames;
  final int? carbonEmissions;
  final int? distance;
  final int price;
  final int? driverRating;
  final String? dateTime;
  final int? availableSeats;
  
  const Ride ({ 
    this.id,
    this.driverUsername,
    this.to,
    this.from,
    this.riderUsernames,
    this.carbonEmissions,
    this.distance,
    this.price = 0,
    this.driverRating,
    this.dateTime,
    this.availableSeats
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride( 
      id: json['id'] as String,
      driverUsername: json['driver_username'] as String,
      to: json['to'] as String,
      from: json['from'] as String,
      riderUsernames: json['rider_usernames'] as List<dynamic>?,
      carbonEmissions: json['carbon_emissions'] as int,
      distance: json['distance'] as int,
      price: json['price'] as int,
      driverRating: json['driver_rating'] as int,
      dateTime: json['date_and_time'] as String,
      availableSeats: json['available_seats'] as int
    );
  }
  static List<Ride> fromJsonList(List<Map<String, dynamic>> jsonList) { 
  return jsonList.map<Ride>((json) => Ride.fromJson(json)).toList(); 
  }
}
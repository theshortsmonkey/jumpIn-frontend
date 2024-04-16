//this is a class for submitting the ridedata 

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

class PostRideClass {
  final String? to;
  final RegionsLabel? to_region;
  final String? from;
  final RegionsLabel? from_region;
  final String? driver_username;
  final SeatsLabel? available_seats;
  final int? carbon_emissions;
  final int? distance;
  final int? price;
  final map;
  final DateTime? date_and_time; //NB you are using calendar, are you inputting a DateTime? How are you handling that

  PostRideClass({
    this.to,
    this.to_region,
    this.from,
    this.from_region,
    this.driver_username,
    this.available_seats,
    this.carbon_emissions,
    this.distance,
    this.price,
    this.map = null,
    this.date_and_time
  });

  Map<String, dynamic> toJson() => {
        "to" : to,
        "to_region": to_region?.region,
        "from" : from,
        'from_region': from_region?.region,
        "driver_username" : driver_username,
        "available_seats": available_seats?.seats,
        "carbon_emissions": carbon_emissions,
        "distance": distance,
        "price": price,
        "map": map,
        "date_and_time": date_and_time?.toIso8601String()
      };
}
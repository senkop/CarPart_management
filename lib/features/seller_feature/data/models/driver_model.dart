import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String id;
  final String name;
  final String phoneNumber;
  final List<Trip> trips;

  Driver({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.trips,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      trips: (json['trips'] as List<dynamic>? ?? []).map((e) => Trip.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'trips': trips.map((e) => e.toJson()).toList(),
    };
  }

  double getTotalCost() {
    return trips.fold(0.0, (sum, trip) => sum + trip.cost);
  }

  int getTotalTrips() {
    return trips.length;
  }

  double getMonthlyCost() {
    final now = DateTime.now();
    return trips
        .where((trip) => trip.date.year == now.year && trip.date.month == now.month)
        .fold(0.0, (sum, trip) => sum + trip.cost);
  }
}

class Trip {
  final String id;
  final String from;
  final String to;
  final dynamic cost;
  final DateTime date;

  Trip({
    required this.id,
    required this.from,
    required this.to,
    required this.cost,
    required this.date,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['date']);
    } catch (e) {
      parsedDate = DateTime.now(); // Default to current date if parsing fails
    }

    return Trip(
      id: json['id'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      cost: json['cost'] ?? 0,
      date: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'cost': cost,
      'date': date.toIso8601String(),
    };
  }
}
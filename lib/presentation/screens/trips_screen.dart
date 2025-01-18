import 'package:elshaf3y_store/presentation/cubit/driver_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_cubit.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/driver_model.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class TripScreen extends StatelessWidget {
  final Driver driver;

  TripScreen({required this.driver});

  final TextEditingController tripFromController = TextEditingController();
  final TextEditingController tripToController = TextEditingController();
  final TextEditingController tripCostController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trips for ${driver.name}'),
      ),
      body: BlocBuilder<DriverCubit, DriverState>(
        builder: (context, state) {
          final updatedDriver = (state as DriverLoaded).drivers.firstWhere((d) => d.id == driver.id);
          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: updatedDriver.trips.length,
            itemBuilder: (context, index) {
              final trip = updatedDriver.trips[index];
              final formattedDate = DateFormat('yyyy-MM-dd').format(trip.date);
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(8.0),
                  leading: Icon(Icons.directions_car, color: Colors.blue),
                  title: Text('${trip.from} to ${trip.to}'),
                  subtitle: Text('Cost: \$${trip.cost.toStringAsFixed(2)}\nDate: $formattedDate'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditTripDialog(context, trip);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          context.read<DriverCubit>().deleteTrip(driver.id, trip.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTripDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddTripDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Trip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tripFromController,
                decoration: InputDecoration(labelText: 'From'),
              ),
              TextField(
                controller: tripToController,
                decoration: InputDecoration(labelText: 'To'),
              ),
              TextField(
                controller: tripCostController,
                decoration: InputDecoration(labelText: 'Cost'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final tripId = Uuid().v4();
                final tripFrom = tripFromController.text;
                final tripTo = tripToController.text;
                final tripCost = double.parse(tripCostController.text);

                final trip = Trip(
                  id: tripId,
                  from: tripFrom,
                  to: tripTo,
                  cost: tripCost,
                  date: DateTime.now(),
                );

                context.read<DriverCubit>().addTrip(driver.id, trip);

                tripFromController.clear();
                tripToController.clear();
                tripCostController.clear();

                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTripDialog(BuildContext context, Trip trip) {
    tripFromController.text = trip.from;
    tripToController.text = trip.to;
    tripCostController.text = trip.cost.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Trip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tripFromController,
                decoration: InputDecoration(labelText: 'From'),
              ),
              TextField(
                controller: tripToController,
                decoration: InputDecoration(labelText: 'To'),
              ),
              TextField(
                controller: tripCostController,
                decoration: InputDecoration(labelText: 'Cost'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final tripFrom = tripFromController.text;
                final tripTo = tripToController.text;
                final tripCost = double.parse(tripCostController.text);

                final updatedTrip = Trip(
                  id: trip.id,
                  from: tripFrom,
                  to: tripTo,
                  cost: tripCost,
                  date: trip.date,
                );

                context.read<DriverCubit>().updateTrip(driver.id, updatedTrip);

                tripFromController.clear();
                tripToController.clear();
                tripCostController.clear();

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
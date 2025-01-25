import 'package:elshaf3y_store/presentation/cubit/driver_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_cubit.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/driver_model.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class TripScreen extends StatefulWidget {
  final Driver driver;

  TripScreen({super.key, required this.driver});

  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  final TextEditingController tripFromController = TextEditingController();
  final TextEditingController tripToController = TextEditingController();
  final TextEditingController tripCostController = TextEditingController();
  bool isGridView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        backgroundColor: Colors.white,
      appBar: AppBar(
                backgroundColor: Colors.white,

        title: Text('Trips for ${widget.driver.name}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showAddTripDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Add Trip'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showSortOptionsDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Sort'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isGridView = !isGridView;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Grid View'),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<DriverCubit, DriverState>(
              builder: (context, state) {
                if (state is DriverLoaded) {
                  final updatedDriver = state.drivers.firstWhere((d) => d.id == widget.driver.id);
                  return isGridView
                      ? GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2 / 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: updatedDriver.trips.length,
                          itemBuilder: (context, index) {
                            final trip = updatedDriver.trips[index];
                            final formattedDate = DateFormat('yyyy-MM-dd').format(trip.date);
                            return Card(
                               elevation: 0,
                                          color: Colors.white,

                                   shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.directions_car, size: 50, color: Colors.blue),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${trip.from} to ${trip.to}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 5),
                                    Text('Cost: \$${trip.cost.toStringAsFixed(2)}'),
                                    Text('Date: $formattedDate'),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.orange),
                                          onPressed: () {
                                            _showEditTripDialog(context, trip);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            context.read<DriverCubit>().deleteTrip(widget.driver.id, trip.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                             ) );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: updatedDriver.trips.length,
                          itemBuilder: (context, index) {
                            final trip = updatedDriver.trips[index];
                            final formattedDate = DateFormat('yyyy-MM-dd').format(trip.date);
                            return Card(
                                elevation: 0,
                                          color: Colors.white,

                                   shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(8.0),
                                leading: const Icon(Icons.directions_car, color: Colors.blue),
                                title: Text('${trip.from} to ${trip.to}'),
                                subtitle: Text('Cost: \$${trip.cost.toStringAsFixed(2)}\nDate: $formattedDate'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        _showEditTripDialog(context, trip);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        context.read<DriverCubit>().deleteTrip(widget.driver.id, trip.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                             ) );
                          },
                        );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    
    );
  }

  void _showAddTripDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Trip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tripFromController,
                decoration: const InputDecoration(labelText: 'From'),
              ),
              TextField(
                controller: tripToController,
                decoration: const InputDecoration(labelText: 'To'),
              ),
              TextField(
                controller: tripCostController,
                decoration: const InputDecoration(labelText: 'Cost'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final tripId = const Uuid().v4();
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

                context.read<DriverCubit>().addTrip(widget.driver.id, trip);

                tripFromController.clear();
                tripToController.clear();
                tripCostController.clear();

                Navigator.of(context).pop();
              },
              child: const Text('Add'),
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
          title: const Text('Edit Trip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tripFromController,
                decoration: const InputDecoration(labelText: 'From'),
              ),
              TextField(
                controller: tripToController,
                decoration: const InputDecoration(labelText: 'To'),
              ),
              TextField(
                controller: tripCostController,
                decoration: const InputDecoration(labelText: 'Cost'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
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

                context.read<DriverCubit>().updateTrip(widget.driver.id, updatedTrip);

                tripFromController.clear();
                tripToController.clear();
                tripCostController.clear();

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showSortOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sort Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('By Cost'),
                onTap: () {
                  _sortByCost();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('By Date'),
                onTap: () {
                  _sortByDate();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _sortByCost() {
    setState(() {
      context.read<DriverCubit>().sortTripsByCost(widget.driver.id);
    });
  }

  void _sortByDate() {
    setState(() {
      context.read<DriverCubit>().sortTripsByDate(widget.driver.id);
    });
  }
}